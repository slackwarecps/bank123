import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();
  
  var isLoading = false.obs;
  var isBiometricAllowed = false.obs; // Controla se o botão aparece

  // Controllers for text fields
  final emailController = TextEditingController(text: 'teste@teste.com.br');
  final passwordController = TextEditingController(text: 'teste123');

  @override
  void onInit() {
    super.onInit();
    _checkBiometricSettings();
    _loadSavedCredentials();
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
      String? value = await _storage.read(key: 'biometric_enabled');
      isBiometricAllowed.value = value == 'true';
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
      
 
        print('\n======= LOGIN SUCCESS =======');
        print('Status: Autenticado com sucesso');
        print('User UID: ${userCredential.user?.uid}');
        print('Email: ${userCredential.user?.email}');
        print('Token: ${tokenResult?.token}');
        print('Claims: ${tokenResult?.claims}');
        print('==============================\n');
   

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
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (canCheckBiometrics || isDeviceSupported) {
        bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Por favor, autentique-se para entrar',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (didAuthenticate) {
          // Aqui, em um app real, você provavelmente usaria um token salvo
          // ou apenas permitiria o acesso se o usuário já tivesse logado uma vez.
          // Para este protótipo, vamos navegar para a home.
          Get.offAllNamed('/home-page');
        }
      } else {
        Get.snackbar(
          "Biometria",
          "Biometria não disponível neste dispositivo.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
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
