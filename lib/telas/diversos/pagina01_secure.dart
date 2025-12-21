import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';

// Create storage
final storage = FlutterSecureStorage();



class Pagina01Secure extends StatefulWidget {
  const Pagina01Secure({super.key});

  @override
  State<Pagina01Secure> createState() => _Pagina01SecureState();
}

class _Pagina01SecureState extends State<Pagina01Secure> {

  
  
  // 1. Instância única e configurada do storage.
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

@override
  void initState() {
    super.initState();
    developer.log("Inicio da pagina 1 segura");
    _lerValorDoStorage();

  }

  Future<void> _lerValorDoStorage() async {
    String? value = await _storage.read(key: "meuCpf");
    String? quemEhOBatman = await _storage.read(key: "quemEhOBatman");
    String? senhaSecreta = await _storage.read(key: "senhaSecreta");
    if (value != null) {
      developer.log("Valor do Secure Storage:  $value");

     developer.log("Variável 'meuCpf' salva com o valor: $value");
     developer.log("Variável 'quemEhOBatman' salva com o valor: $quemEhOBatman");
     developer.log("Variável 'senhaSecreta' salva com o valor: $senhaSecreta");


    }else developer.log("meuCpf null");
  }

   Future<void> _definirVariavelSegura() async {
    final random = Random();
    final cpf = '${random.nextInt(999).toString().padLeft(3, '0')}.${random.nextInt(999).toString().padLeft(3, '0')}.${random.nextInt(999).toString().padLeft(3, '0')}-${random.nextInt(99).toString().padLeft(2, '0')}';
   
    final identidadeDoBatman = 'Bruce Wayne';
    
    // AVISO DE SEGURANÇA:
    // Evite hardcoding de senhas/chaves no código fonte.
    // Em produção, esta string viria de um input seguro ou variável de ambiente.
    final senhaSecreta = 'A senha do Peixe';
   
      await _storage.write(key: "meuCpf", value: cpf);
      await _storage.write(key: "quemEhOBatman", value: identidadeDoBatman);
      await _storage.write(key: "senhaSecreta", value:  senhaSecreta);

     developer.log("Variável 'meuCpf' salva com o valor: $cpf");
     developer.log("Variável 'quemEhOBatman' salva com o valor: $identidadeDoBatman");
     developer.log("Variável 'senhaSecreta' salva com o valor: $senhaSecreta");

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
            const Text('Exemplos de uso do Secure Storage'),
            const Text('Veja as opçoes e investigue no Android Studio'),
            const Divider(),

            ElevatedButton(onPressed: _definirVariavelSegura, child: const Text("Salvar CPF e segredos")),
             const SizedBox(height: 20),
            ElevatedButton(onPressed: _lerValorDoStorage, child: const Text("Ler dados do Storage Local")),
             const SizedBox(height: 20),
            ElevatedButton(onPressed: _removerVariavelSegura, child: const Text("Remover CPF")),

           ],
        ),
      ),
    );
  }






}