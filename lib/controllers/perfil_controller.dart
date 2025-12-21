import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PerfilController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final email = ''.obs;
  final uid = ''.obs;
  final iat = ''.obs;
  final exp = ''.obs;
  final token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    carregarDadosUsuario();
  }

  Future<void> carregarDadosUsuario() async {
    User? user = _auth.currentUser;

    if (user != null) {
      email.value = user.email ?? 'Não disponível';
      uid.value = user.uid;

      // Obter o ID Token e seus claims
      IdTokenResult tokenResult = await user.getIdTokenResult();
      token.value = tokenResult.token ?? 'Erro ao obter token';
      
      // IAT e EXP (Issued At e Expiration Time)
      // O IdTokenResult já traz as datas processadas, mas podemos pegar do map de claims se necessário.
      // Geralmente, expirationTime e authTime (similar ao iat) estão disponíveis diretamente ou nos claims.
      
      DateTime? authTime = tokenResult.authTime;
      DateTime? expirationTime = tokenResult.expirationTime;

      iat.value = authTime != null ? authTime.toString() : 'N/A';
      exp.value = expirationTime != null ? expirationTime.toString() : 'N/A';
    }
  }

  void copiarToken() {
    if (token.value.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: token.value));
      Get.snackbar(
        'Sucesso',
        'Token copiado para a área de transferência!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
