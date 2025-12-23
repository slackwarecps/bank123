import 'dart:developer' as developer;
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class BffService {
  late Dio _dio;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();
  final _uuid = const Uuid();

  // URL Base do BFF
  final String _baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://dummy.com.dev');

  // Fingerprint SHA-256 do Certificado (Obtido via OpenSSL)
  // RNF04 - Segurança (Prevenção MITM)
  // DECISÃO DE DESIGN: O fingerprint é mantido hard-coded (constante binária) em vez de .env
  // por segurança. Arquivos .env em Flutter são empacotados como assets de texto claro,
  // facilitando o bypass via reempacotamento (repackaging). Mantendo no código nativo
  // compilado (AOT), o atacante precisaria realizar patch binário, elevando a complexidade do ataque.
  final String _expectedFingerprint = 
      'F9:14:B8:18:CA:D2:7D:D4:08:33:A8:4E:47:3D:27:AF:94:75:1D:2D:17:CE:1C:28:92:FB:21:0E:E4:C4:07:C6';

  BffService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Configuração do SSL Pinning (RNF04)
    if (!kIsWeb) {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (X509Certificate cert, String host, int port) {
            // Verifica se o host é o alvo esperado
            if (!host.contains('zuplo.dev')) {
              return false; // Rejeita outros hosts se necessário ou ajusta lógica
            }
            
            // Calcula o SHA-256 do DER (binário do certificado)
            final digest = sha256.convert(cert.der).bytes;
            final serverFingerprint = _bytesToHex(digest);
            
            final isValid = serverFingerprint == _expectedFingerprint;

            if (!isValid && kDebugMode) {
               developer.log('🚨 ALERTA DE SEGURANÇA (SSL PINNING) 🚨', name: 'BffService');
               developer.log('Esperado: $_expectedFingerprint', name: 'BffService');
               developer.log('Recebido: $serverFingerprint', name: 'BffService');
            }

            return isValid; 
          };
          return client;
        },
      );
    }

    // Configura o Interceptor para injetar headers em TODAS as requisições
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          // 1. Obter o Token do Firebase
          final User? user = _auth.currentUser;
          if (user == null) {
            // Se não tiver usuário, tenta seguir, mas provavelmente vai falhar no backend
            // ou podemos rejeitar aqui. Vamos tentar logar o que temos.
             if (kDebugMode) developer.log('AVISO: Usuário não autenticado no Firebase.', name: 'BffService');
          }
          final String? token = await user?.getIdToken();

          // 2. Gerar Correlation ID (UUID v4)
          final String correlationId = _uuid.v4();

          // 3. Obter Número da Conta do Secure Storage
          String accountId = '1'; // Valor padrão seguro
          try {
            final storedId = await _storage.read(key: 'NUMERO_CONTA');
            if (storedId != null && storedId.isNotEmpty) {
              accountId = storedId;
            }
          } catch (e) {
            if (kDebugMode) developer.log('Erro ao ler Secure Storage: $e', name: 'BffService');
          }

          // 4. Injetar Headers (Garantindo que o Map existe)
          options.headers['Authorization'] = 'Bearer $token';
          options.headers['x-account-id'] = accountId;
          options.headers['x-correlation-id'] = correlationId;

          // LOG DETALHADO
          if (kDebugMode) {
            developer.log('🚀 HTTP REQUEST: ${options.method} ${options.uri}', name: 'BffService');
            developer.log('HEADERS ENVIADOS: ${options.headers}', name: 'BffService');
            if (options.data != null) {
              developer.log('PAYLOAD: ${options.data}', name: 'BffService');
            }
          }

          return handler.next(options);
        } catch (e) {
          if (kDebugMode) {
            developer.log('❌ Erro Fatal no Interceptor: $e', name: 'BffService');
          }
          // Mesmo com erro, tenta passar a requisição adiante para não travar o app,
          // mas loga o erro.
          return handler.next(options);
        }
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          developer.log('✅ HTTP RESPONSE: ${response.statusCode} [${response.requestOptions.uri}]', name: 'BffService');
          developer.log('Payload: ${response.data}', name: 'BffService');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          developer.log('🔥 HTTP ERROR: ${e.response?.statusCode} [${e.requestOptions.uri}]', name: 'BffService');
          developer.log('Erro: ${e.message}', name: 'BffService');
          if (e.response != null) {
            developer.log('Payload Erro: ${e.response?.data}', name: 'BffService');
          }
        }
        return handler.next(e);
      },
    ));
  }

  // Métodos da API

  // 1. Perfil
  Future<dynamic> getPerfil() async {
    try {
      final response = await _dio.get('/bff-bank123/usuario/v1/perfil');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 2. Saldo
  Future<dynamic> getSaldo() async {
    try {
      // Agora chamamos direto, confiando 100% no Interceptor acima
      final response = await _dio.get('/bff-bank123/extrato/v1/saldo');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 3. Extrato
  Future<List<dynamic>> getExtrato() async {
    try {
      final response = await _dio.get('/bff-bank123/extrato/v1/listagem');
      if (response.data is List) {
        return response.data;
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  // 4. Transferência
  Future<Response> postTransferencia(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(
        '/bff-bank123/movimentacoes/v1/transferencia-conta',
        data: payload,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Helper para formatar o fingerprint
  String _bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase()).join(':');
  }
}