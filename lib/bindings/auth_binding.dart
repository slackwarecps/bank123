import 'package:bank123/controllers/login_controller.dart';
import 'package:bank123/telas/diversos/validaAutenticacao.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Usando Get.put() para criar a instância do AuthController
    // assim que o binding for carregado.
    Get.put<AuthController>(AuthController(auth: LocalAuthentication()));
    Get.put<LoginController>(LoginController());
  }
}
