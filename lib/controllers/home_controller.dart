import 'package:bank123/services/bff_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final BffService _bffService = BffService();
  var isLoading = false.obs;

  Future<void> consultarSaldo() async {
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

  Future<void> consultarExtrato() async {
    try {
      isLoading.value = true;
      final lista = await _bffService.getExtrato();
      
      Get.bottomSheet(
        Container(
          color: Colors.white,
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Extrato Recente",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: lista.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = lista[index];
                    final valor = item['valorTransacao'];
                    final valorFormatado = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valor);
                    final data = item['dataTransacao'];
                    final operacao = item['operacao'];

                    return ListTile(
                      leading: Icon(
                        operacao == 'SAIDA' ? Icons.arrow_upward : Icons.arrow_downward,
                        color: operacao == 'SAIDA' ? Colors.red : Colors.green,
                      ),
                      title: Text(item['destino'] ?? 'Transação'),
                      subtitle: Text(data ?? ''),
                      trailing: Text(
                        valorFormatado,
                        style: TextStyle(
                          color: operacao == 'SAIDA' ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        isScrollControlled: true,
      );

    } catch (e) {
      Get.snackbar(
        "Erro", 
        "Não foi possível consultar o extrato: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white
      );
    } finally {
      isLoading.value = false;
    }
  }
}
