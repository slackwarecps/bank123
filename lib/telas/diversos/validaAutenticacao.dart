import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:async';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

/// Controller para gerenciar o estado da tela de autenticação.
class AuthController extends GetxController {
  // A variável `isLoading` é reativa (.obs) e controla a UI.
  // Inicia como `true` para mostrar o indicador de progresso.
  var isLoading = true.obs;
  final LocalAuthentication auth;

  RxBool  isAuthenticated  = RxBool( false );



  AuthController({ required this.auth});


  @override
  void onInit() {
    super.onInit();
    developer.log("[AuthController] Iniciando a tela de validação de autenticação.");
    // Inicia a tentativa de autenticação assim que a tela é carregada.
    _autenticar();
  }

/// Tenta realizar a autenticação.
  Future<void> _autenticar() async {
    try {
      // Notifica a UI para mostrar o indicador de progresso.
      isLoading.value = true;
      developer.log("Verificando se a biometria está disponível...");

      if (await isBiometricAvailable()) {
        developer.log("Biometria disponível. Solicitando autenticação...");
        final bool didAuthenticate = await authenticate();
        if (didAuthenticate) {
          developer.log("Autenticação bem-sucedida!");
          isAuthenticated.value = true;
          Get.offAllNamed('/home-page'); // Navega para a home e remove as telas anteriores
        } else {
          developer.log("Autenticação falhou ou foi cancelada pelo usuário.");
          isAuthenticated.value = false;
          isLoading.value = false; // Mostra o botão para tentar novamente
        }
      } else {
        developer.log("Biometria não disponível. Não é possível autenticar.");
        isLoading.value = false; // Mostra o botão para tentar novamente (ou poderia ir para outra tela)
      }
    } catch (e) {
      developer.log("Ocorreu um erro durante a autenticação: $e");
      isAuthenticated.value = false;
      isLoading.value = false;
    }
  }

  /// Verifica se o dispositivo tem capacidade de autenticação biométrica.
  Future<bool> isBiometricAvailable() async {
    return await auth.canCheckBiometrics || await auth.isDeviceSupported();
  }

  /// Dispara o prompt de autenticação do sistema.
  Future<bool> authenticate() async {
    return await auth.authenticate(
        localizedReason: "Por favor, autentique-se para acessar o app");
  }
}

//CONTROLLER. GETX /\









class ValidaAutenticacao extends StatelessWidget {
  const ValidaAutenticacao({super.key});

  @override
  Widget build(BuildContext context) {
    // O controller é recuperado com Get.find(), pois ele já foi
    // injetado na memória pelo AuthBinding no início do app.
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        // O widget Obx reconstrói seu filho automaticamente quando
        // uma variável reativa (.obs) dentro dele é alterada.
        child: Obx(() {
          // Se `isLoading` for true, mostra o indicador de progresso.
          if (authController.isLoading.value) {
            return const CircularProgressIndicator(color: Colors.white);
          } else {
            // Se for false, mostra o botão para tentar novamente.
            return ElevatedButton(
              onPressed: authController._autenticar,
              child: const Text("Tentar autenticar novamente"),
            );
          }
        }),
      ),
    );
  }
}