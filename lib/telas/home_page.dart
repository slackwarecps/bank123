import 'package:bank123/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: colorScheme.primary,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.account_balance, color: colorScheme.onPrimary),
                  Text(
                    'Bank123',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: colorScheme.onPrimary),
                    onSelected: (value) {
                      if (value == 'perfil') {
                        Get.toNamed('/perfil');
                      } else if (value == 'configuracoes') {
                        Get.toNamed('/configuracoes');
                      } else if (value == 'sair') {
                        Get.offAllNamed('/login');
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'perfil', child: Text('Perfil')),
                      const PopupMenuItem(
                        value: 'configuracoes',
                        child: Text('Configurações'),
                      ),
                      const PopupMenuItem(value: 'sair', child: Text('Sair')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Bem vindo!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Obx(() => FilledButton(
                      onPressed: controller.isLoading.value ? null : () {
                        controller.consultarSaldo();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (controller.isLoading.value) ...[
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          const Text(
                            'Consultar saldo',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Obx(() => FilledButton(
                      onPressed: controller.isLoading.value ? null : () {
                        controller.consultarExtrato();
                      },
                      child: const Text(
                        'Consultar extrato',
                        style: TextStyle(fontSize: 16),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () {
                        controller.irParaTransferencia();
                      },
                      child: const Text(
                        'Realizar transação',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}