import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'dart:async';


import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
// #docregion migrate
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';
// #enddocregion migrate

// Create storage



class Pagina03Biometric extends StatefulWidget {
  const Pagina03Biometric({super.key});

  @override
  State<Pagina03Biometric> createState() => _Pagina03BiometricState();
}

class _Pagina03BiometricState extends State<Pagina03Biometric> {
  // Instância do serviço de autenticação local.
  final LocalAuthentication auth = LocalAuthentication();



@override
  void initState() {
    super.initState();
    developer.log("Inicio da pagina 3 Biometria");
    _lerValorDoStorage();


  }


  // BIOMETRIA FUNCOES
  // **************************************************************************
    Future<void> canBiometria() async {
       final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    developer.log("Pode Biometria? ][auth.canCheckBiometrics]:  $canAuthenticateWithBiometrics");
  }

  Future<void> canDeviceSuportado() async {
   final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
   final bool isDeviceSupported =await auth.isDeviceSupported();
   final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    developer.log("canAuthenticateWithBiometrics? :  $canAuthenticateWithBiometrics");
    developer.log("isDeviceSupported? :  $isDeviceSupported");
    developer.log("Pode Autenticar? :  $canAuthenticate");
  }

  Future<void> listaBiometrias() async {
        final List<BiometricType> availableBiometrics =
            await auth.getAvailableBiometrics();
             developer.log("availableBiometrics. $availableBiometrics");

        if (availableBiometrics.isNotEmpty) {
          // Some biometrics are enrolled.
              developer.log("Some biometrics are enrolled.");
        }

        if (availableBiometrics.contains(BiometricType.strong) ||
            availableBiometrics.contains(BiometricType.face)) {
          // Specific types of biometrics are available.
          // Use checks like this with caution!
              developer.log(""" Specific types of biometrics are available.
            Use checks like this with caution!""");
        }
 
  }

  Future<void> doAutenticar() async {
    final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Você deve se autenticar para acessar, a partir de agora.');
    developer.log("Pode Autenticar? :  $didAuthenticate");
  }


    Future<void> doAutenticar2() async {
    final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Você deve se autenticar para acessar, a partir de agora.',
      authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Não,não nao! Tu vai precisar de biometria!',
            cancelButton: 'Nao agora, eu passo.',
          ),
          IOSAuthMessages(
            cancelButton: 'Nao, to fora!.',
          ),
        ],
      options: AuthenticationOptions(
        biometricOnly: true, //true: 5 tentativas e nao pede o pin
        useErrorDialogs: false, // Nao usar dialogos padrao do Android para cadastrar pin vai direto para o erro.
        stickyAuth: true
      ) // Mantém o prompt ativo se o app for para o background
      );
    developer.log("Pode Autenticar? :  $didAuthenticate");
  }

      Future<void> doAutenticar3() async {
    final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Você deve se autenticar para acessar, a partir de agora.',
      authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Não,não nao! Tu vai precisar de biometria!',
            cancelButton: 'Nao agora, eu passo.',
          ),
          IOSAuthMessages(
            cancelButton: 'Nao, to fora!.',
          ),
        ],
  
      );
    developer.log("Pode Autenticar? :  $didAuthenticate");
  }

  Future<void> doAutenticar4() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'permissao para continuar');
        developer.log("Pode Autenticar? :  $didAuthenticate");
      // ···
    } on PlatformException catch (e)  {
      // ...
      developer.log("erro [PlatformException]: ");
      if (e.code == auth_error.notAvailable) {
        // Add handling of no hardware here.
      } else if (e.code == auth_error.notEnrolled) {
        // ...
      } else {
        // ...
      }
    }

  }


  // BIOMETRIA FUNCOES
  // **************************************************************************


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
      appBar: AppBar(
        title: const Text('Biometria POC'),
      ),
      // Adicionado SingleChildScrollView para permitir a rolagem da tela.
      body: SingleChildScrollView(
        // Adicionado Padding para dar um espaçamento nas laterais e no topo/base.
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Página de Testes de Biometria',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: canBiometria, child: const Text("Pode Biometria?")),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: canDeviceSuportado,
                child: const Text("Dispositivo é compatível?")),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: listaBiometrias,
                child: const Text("Listar Biometrias Disponíveis")),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: doAutenticar, child: const Text("Autenticar (Padrão)")),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: doAutenticar2,
                child: const Text("Autenticar (Biometria Apenas)")),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: doAutenticar3,
                child: const Text("Autenticar (Personalizado)")),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: doAutenticar4,
                child: const Text("Autenticar (Com Try-Catch)")),
          ],
        ),
      ),
    );
  }
}