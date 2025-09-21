// lib/pages/contatos_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/contato_controller.dart';
import '../models/contato_model.dart';

class ContatosPage extends StatelessWidget {
  const ContatosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ContatoController controller = Get.put(ContatoController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Contatos'),
      ),
      body: controller.obx(
        (state) {
          if (state == null || state.isEmpty) {
            return const Center(child: Text('Nenhum contato encontrado.'));
          }

          return ListView.builder(
            itemCount: state.length,
            itemBuilder: (context, index) {
              final ContatoModel contato = state[index];
              return ListTile(
                title: Text(contato.nome),
                subtitle: Text('${contato.chavePix.tipo}: ${contato.chavePix.valor}'),
              );
            },
          );
        },
        onLoading: const Center(child: CircularProgressIndicator()),
        onError: (error) => Center(child: Text('Erro: $error')),
      ),
    );
  }
}