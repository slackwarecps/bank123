import 'package:bank123/services/bff_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final BffService _bffService = BffService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();
  var isLoading = false.obs;

  Future<bool> _sessaoValida() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Ler o TTL da sessão do storage
      final ttlString = await _storage.read(key: 'ttl_sessao');
      
      if (ttlString == null) {
        // Se não tiver TTL salvo, assume expirado por segurança
        _mostrarAlertaSessaoExpirada();
        return false;
      }

      final exp = DateTime.parse(ttlString);
      final agora = DateTime.now();

      // Verifica se o tempo limite foi atingido (agora >= exp)
      if (agora.isAfter(exp) || agora.isAtSameMomentAs(exp)) {
        _mostrarAlertaSessaoExpirada();
        return false;
      }
      
      return true;
    } catch (e) {
      // Se der erro ao ler/parsear, considera expirado
      _mostrarAlertaSessaoExpirada();
      return false;
    }
  }

  void _mostrarAlertaSessaoExpirada() {
    Get.defaultDialog(
      title: "Sessão Expirada",
      middleText: "O tempo de sessão expirou. É necessário fazer o login novamente.",
      barrierDismissible: false,
      actions: [
        FilledButton(
          onPressed: () async {
            await _auth.signOut();
            Get.offAllNamed('/login');
          },
          child: const Text("Ir para Login"),
        )
      ],
    );
  }

  Future<void> consultarSaldo() async {
    if (!await _sessaoValida()) return;

    try {
      isLoading.value = true;
      final dados = await _bffService.getSaldo();
      
      // Formatar valor para BRL
      final saldo = dados['saldo'];
      final saldoFormatado = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(saldo);
      final conta = dados['numeroConta'];

      Get.defaultDialog(
        title: "Saldo Atual",
        middleText: "Conta: $conta\n\n$saldoFormatado",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    } catch (e) {
      Get.snackbar(
        "Erro", 
        "Não foi possível consultar o saldo: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white
      );
    } finally {
      isLoading.value = false;
    }
  }

  void consultarExtrato() async {
    if (!await _sessaoValida()) return;
    Get.toNamed('/extrato');
  }

  void irParaTransferencia() async {
    if (!await _sessaoValida()) return;
    Get.toNamed('/transferencia');
  }
}
