import 'dart:math';
import 'package:dio/dio.dart';
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
  final String _baseUrl = 'https://bank123-main-297cd30.d2.zuplo.dev';

  BffService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Configura o Interceptor para injetar headers em TODAS as requisições
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          // 1. Obter o Token do Firebase
          final User? user = _auth.currentUser;
          if (user == null) {
            // Se não tiver usuário, tenta seguir, mas provavelmente vai falhar no backend
            // ou podemos rejeitar aqui. Vamos tentar logar o que temos.
             if (kDebugMode) print('AVISO: Usuário não autenticado no Firebase.');
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
            if (kDebugMode) print('Erro ao ler Secure Storage: $e');
          }

          // 4. Injetar Headers (Garantindo que o Map existe)
          options.headers['Authorization'] = 'Bearer $token';
          options.headers['x-account-id'] = accountId;
          options.headers['x-correlation-id'] = correlationId;

          // LOG DETALHADO
          if (kDebugMode) {
            print('\n---------------------------------------------------\n');
            print('🚀 HTTP REQUEST: ${options.method} ${options.uri}');
            print('---------------------------------------------------');
            print('HEADERS ENVIADOS:');
            options.headers.forEach((key, value) {
              print('   $key: $value');
            });
            print('---------------------------------------------------');
            if (options.data != null) {
              print('PAYLOAD: ${options.data}');
              print('---------------------------------------------------');
            }
            print('\n');
          }

          return handler.next(options);
        } catch (e) {
          if (kDebugMode) {
            print('❌ Erro Fatal no Interceptor: $e');
          }
          // Mesmo com erro, tenta passar a requisição adiante para não travar o app,
          // mas loga o erro.
          return handler.next(options);
        }
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('\n✅ HTTP RESPONSE: ${response.statusCode} [${response.requestOptions.uri}]');
          print('Payload: ${response.data}');
          print('---------------------------------------------------\n');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          print('\n🔥 HTTP ERROR: ${e.response?.statusCode} [${e.requestOptions.uri}]');
          print('Erro: ${e.message}');
          if (e.response != null) {
            print('Payload Erro: ${e.response?.data}');
          }
          print('---------------------------------------------------\n');
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
}