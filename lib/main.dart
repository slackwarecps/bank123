

import 'package:bank123/bindings/login_binding.dart';

import 'package:bank123/telas/cadastro_page.dart';
import 'package:bank123/telas/configuracao_page.dart';
import 'package:bank123/telas/perfil_page.dart';
import 'package:bank123/telas/login.dart';
import 'package:bank123/telas/pagina_nao_encontrada.dart';
import 'package:bank123/telas/tela_de_erro.dart';
import 'package:bank123/telas/transferencia_page.dart';
import 'package:bank123/telas/extrato_page.dart';
import 'package:bank123/telas/home_page.dart';
import 'package:bank123/telas/jailbreak_page.dart'; // Importação da tela de Jailbreak
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bank123/firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:safe_device/safe_device.dart'; // Importação do pacote safe_device
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  bool isJailBroken = false;
  try {
    isJailBroken = await SafeDevice.isJailBroken;
  } catch (e) {
    debugPrint("Erro ao verificar jailbreak: $e");
  }

  runApp(MainApp(isJailBroken: isJailBroken));
}

class MainApp extends StatelessWidget {
  final bool isJailBroken;
  const MainApp({super.key, this.isJailBroken = false});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => PaginaNaoEncontrada(),
      ),

      initialRoute: isJailBroken ? '/jailbreak' : '/',
      getPages: [
        GetPage(name: '/jailbreak', page: () => const JailbreakPage()),
        GetPage(name: '/', page: () => LoginScreen(), binding: LoginBinding()),
        GetPage(name: '/home-page', page: () => const HomePage()),
        GetPage(name: '/login', page: () => LoginScreen(), binding: LoginBinding()),
        GetPage(name: '/cadastro', page: () => CadastroPage()),
        GetPage(name: '/perfil', page: () => const PerfilPage()),
        GetPage(name: '/configuracoes', page: () => const ConfiguracaoPage()),
        GetPage(name: '/error-page', page: () => TelaDeErro()),
        GetPage(name: '/transferencia', page: () => const TransferenciaPage()),
        GetPage(name: '/extrato', page: () => const ExtratoPage()),
      ],
      title: 'Bank 123',
      theme: ThemeData(
        colorSchemeSeed: Colors.red,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
    );
  }
}
