// lib/controllers/contato_controller.dart

import 'package:get/get.dart';
import '../models/contato_model.dart';
import '../repositories/contato_repository.dart';

class ContatoController extends GetxController with StateMixin<List<ContatoModel>> {
  final ContatoRepository _repository = ContatoRepository();

  @override
  void onInit() {
    super.onInit();
    fetchContatos();
  }

  void fetchContatos() async {
    change(null, status: RxStatus.loading());
    try {
      final contatos = await _repository.getContatos();
      change(contatos, status: RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }
}