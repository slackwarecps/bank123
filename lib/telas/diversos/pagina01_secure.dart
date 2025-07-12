import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';

// Create storage
final storage = FlutterSecureStorage();

enum _Actions { deleteAll, isProtectedDataAvailable }

enum _ItemActions { delete, edit, containsKey, read }

class Pagina01Secure extends StatefulWidget {
  const Pagina01Secure({super.key});

  @override
  State<Pagina01Secure> createState() => _Pagina01SecureState();
}

class _Pagina01SecureState extends State<Pagina01Secure> {

  
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final TextEditingController _accountNameController =
      TextEditingController(text: 'flutter_secure_storage_service');

@override
  void initState() {
    super.initState();
    developer.log("Inicio da pagina 1 segura");
    _lerValorDoStorage();

  }

  Future<void> _lerValorDoStorage() async {
    String? value = await _storage.read(key: "meuCpf");
    if (value != null) {
      developer.log("Valor do Secure Storage:  $value");
    }else developer.log("meuCpf null");
  }

   Future<void> _definirVariavelSegura() async {
    final random = Random();
    final cpf =
        '${random.nextInt(999).toString().padLeft(3, '0')}.${random.nextInt(999).toString().padLeft(3, '0')}.${random.nextInt(999).toString().padLeft(3, '0')}-${random.nextInt(99).toString().padLeft(2, '0')}';
    await _storage.write(key: "meuCpf", value: cpf);
    developer.log("Variável 'meuCpf' salva com o valor: $cpf");
    _lerValorDoStorage();
  }

    Future<void> _removerVariavelSegura() async {
    await _storage.delete(key: "meuCpf");
    developer.log("Variável 'meuCpf' removida.");
    _lerValorDoStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('PAGINA 1 SEGURA'),
            const Text('ola vovo'),
            const Text('ola papai'),
            const Divider(),

            ElevatedButton(onPressed: _definirVariavelSegura, child: const Text("Salvar CPF Aleatório")),
             const SizedBox(height: 20),
            ElevatedButton(onPressed: _removerVariavelSegura, child: const Text("Remover CPF")),


           ],
        ),
      ),
    );
  }






}