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
  }

  @override
  void onReady() {
    super.onReady();
    _checkBiometricSettings();
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

      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

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
