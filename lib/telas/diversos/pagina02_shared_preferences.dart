import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:math';
import 'dart:async';


import 'package:shared_preferences/shared_preferences.dart';
// #docregion migrate
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';
// #enddocregion migrate

// Create storage



class Pagina02SharedPref extends StatefulWidget {
  const Pagina02SharedPref({super.key});

  @override
  State<Pagina02SharedPref> createState() => _Pagina02SharedPrefState();
}

class _Pagina02SharedPrefState extends State<Pagina02SharedPref> {

    //ESTADO 

      final Future<SharedPreferencesWithCache> _prefs =
      SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(
              // This cache will only accept the key 'counter'.
              allowList: <String>{'counter'}));

              

    /// Completes when the preferences have been initialized, which happens after
  /// legacy preferences have been migrated.
  final Completer<void> _preferencesReady = Completer<void>();


  
  final TextEditingController _accountNameController =
      TextEditingController(text: 'flutter_secure_storage_service');

@override
  void initState() {
    super.initState();
    developer.log("Inicio da pagina 1 segura");
    _lerValorDoStorage();

  }

  Future<void> _lerValorDoStorage() async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Try reading data from  key. If it doesn't exist, returns null.
final String? meuCpf = prefs.getString('cpfFabioShared');
    developer.log("cpf lido no shared preferences $meuCpf");
  }

   Future<void> _definirVariavelSegura() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
     
     await prefs.setString('cpfFabioShared', '26721993877');
     await prefs.setString('quemEhOBatman', 'Bruce Wayne');

     // AVISO DE SEGURANÇA:
     // 1. NÃO armazene senhas ou chaves em texto plano no código (Hardcoded).
     // 2. O Shared Preferences NÃO é seguro para dados sensíveis (senhas, tokens, PII).
     // Em produção, utilize variáveis de ambiente e FlutterSecureStorage.
     await prefs.setString('senhaSecreta', 'O codigo é 007');


   developer.log("cpf salvo no shared preferences");
  }

    Future<void> _removerVariavelSegura() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // Remove data for the 'counter' key.
      await prefs.remove('cpfFabioShared');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('PAGINA 2 Shared Preferences'),
            const Text('ola vovo'),
            const Text('ola papai'),
            const Divider(),

            ElevatedButton(onPressed: _definirVariavelSegura, child: const Text("Salvar CPF no SD")),
             const SizedBox(height: 20),
            ElevatedButton(onPressed: _lerValorDoStorage, child: const Text("Lerer CPF no SD CPF")),
           const SizedBox(height: 20),
            ElevatedButton(onPressed: _removerVariavelSegura, child: const Text("Apagar CPF")),

           ],
        ),
      ),
    );
  }






}