import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();
  
  var isLoading = false.obs;
  var isBiometricAllowed = false.obs; // Controla se o botão aparece

  // Controllers for text fields
  final emailController = TextEditingController(text: 'teste@teste.com.br');
  final passwordController = TextEditingController(text: 'teste123');
  final emailFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    _checkBiometricSettings();
    _loadSavedCredentials();
  }
  
  @override
  void onClose() {
    emailFocusNode.dispose();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    _checkBiometricSettings();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final savedEmail = await _storage.read(key: 'SAVED_EMAIL');
      final savedPassword = await _storage.read(key: 'SAVED_PASSWORD');

      if (savedEmail != null && savedEmail.isNotEmpty) {
        emailController.text = savedEmail;
      }
      if (savedPassword != null && savedPassword.isNotEmpty) {
        passwordController.text = savedPassword;
      }
    } catch (e) {
      print('Erro ao carregar credenciais: $e');
    }
  }

  Future<void> _checkBiometricSettings() async {
    try {
      // Verifica se o dispositivo suporta biometria
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      // Verifica se a biometria foi ativada pelo usuário (simulado ou salvo)
      String? biometricEnabledPref = await _storage.read(key: 'biometric_enabled');
      bool isEnabledByUser = biometricEnabledPref == 'true';

      // Mostra o botão se o hardware suportar E se estiver ativado
      isBiometricAllowed.value = (canCheckBiometrics || isDeviceSupported) && isEnabledByUser;
      
    } catch (e) {
      isBiometricAllowed.value = false;
    }
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Erro",
        "Por favor, preencha email e senha.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Logs de Retorno e Status do Login
      final tokenResult = await userCredential.user?.getIdTokenResult();
      final accessToken = tokenResult?.token;
      
 
        print('\n======= LOGIN SUCCESS =======');
        print('Status: Autenticado com sucesso');
        print('User UID: ${userCredential.user?.uid}');
        print('Email: ${userCredential.user?.email}');
        print('Token: $accessToken');
        print('Claims: ${tokenResult?.claims}');
        print('==============================\n');
   
      // Salvar o Token de acesso para validação biométrica futura
      if (accessToken != null) {
        await _storage.write(key: 'ACCESS_TOKEN', value: accessToken);
      }

      // Extrair numeroConta das claims e salvar no Secure Storage
      final claims = tokenResult?.claims;

      if (claims != null && claims.containsKey('bank123/jwt/claims')) {
        final bankClaims = claims['bank123/jwt/claims'];
        // Verifica se é um Map e tenta pegar 'numeroconta' (ou 'numeroConta' por garantia)
        if (bankClaims is Map) {
          final conta = bankClaims['numeroconta'] ?? bankClaims['numeroConta'];
          if (conta != null) {
            await _storage.write(
              key: 'NUMERO_CONTA', 
              value: conta.toString()
            );
          }
        }
      }

      // Salvar credenciais para o próximo login
      await _storage.write(key: 'SAVED_EMAIL', value: emailController.text.trim());
      await _storage.write(key: 'SAVED_PASSWORD', value: passwordController.text.trim());
      
      // _checkBiometricSettings(); // Atualiza a UI

      // Definir TTL da sessão (5 minutos a partir de agora)
      final ttl = DateTime.now().add(const Duration(minutes: 5)).toIso8601String();
      await _storage.write(key: 'ttl_sessao', value: ttl);

      // If successful, navigate to home
      Get.offAllNamed('/home-page');
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Erro ao realizar login.";

      if (e.code == 'user-not-found') {
        errorMessage = 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Senha incorreta.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'E-mail inválido.';
      }

      Get.snackbar(
        "Falha no Login",
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Ocorreu um erro inesperado: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithBiometrics() async {
    try {
      bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Por favor, autentique-se para entrar',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        // 1. Verificar TTL da Sessão
        final ttlString = await _storage.read(key: 'ttl_sessao');
        bool sessaoValidaTTL = false;

        if (ttlString != null) {
          final exp = DateTime.parse(ttlString);
          final agora = DateTime.now();
          if (agora.isBefore(exp)) {
            sessaoValidaTTL = true;
          }
        }

        if (!sessaoValidaTTL) {
            Get.snackbar(
            "Sessão Expirada",
            "Sua sessão expirou por segurança. Por favor, entre com sua senha novamente.",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          emailFocusNode.requestFocus();
          return;
        }

        // 2. Validação do Token JWT (Camada extra de segurança)
        final token = await _storage.read(key: 'ACCESS_TOKEN');

        if (token != null && !JwtDecoder.isExpired(token)) {
          // Token válido e TTL válido
          Get.offAllNamed('/home-page');
        } else {
          // Token expirado ou inexistente
          Get.snackbar(
            "Sessão Expirada",
            "Sua sessão expirou por segurança. Por favor, entre com sua senha novamente.",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          // Opcional: remover o token inválido
          await _storage.delete(key: 'ACCESS_TOKEN');
          emailFocusNode.requestFocus();
        }
      }
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Erro ao autenticar com biometria: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
