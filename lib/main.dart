import 'package:bank123/pages/contatos_page.dart';
import 'package:bank123/telas/diversos/pagina01_secure.dart';
import 'package:bank123/bindings/auth_binding.dart';
import 'package:bank123/telas/diversos/pagina02_shared_preferences.dart';
import 'package:bank123/telas/diversos/pagina03_biometric%20copy.dart';
import 'package:bank123/telas/diversos/validaAutenticacao.dart';
import 'package:bank123/telas/cadastro_page.dart';
import 'package:bank123/telas/perfil_page.dart';
import 'package:bank123/telas/login.dart';
import 'package:bank123/telas/pagina_nao_encontrada.dart';
import 'package:bank123/telas/splash_screen.dart';
import 'package:bank123/telas/tela_de_erro.dart';
import 'package:bank123/telas/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bank123/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => PaginaNaoEncontrada(),
      ),
      initialBinding: AuthBinding(),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/', page: () => LoginScreen()),
        GetPage(name: '/valida-autenticacao', page: () => ValidaAutenticacao()),
        GetPage(name: '/home-page', page: () => const HomePage()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/cadastro', page: () => CadastroPage()),
        GetPage(name: '/perfil', page: () => const PerfilPage()),
        GetPage(name: '/error-page', page: () => TelaDeErro()),
        GetPage(name: '/pagina01-secure', page: () => Pagina01Secure()),
        GetPage(name: '/contatos-page', page: () => ContatosPage()),
        GetPage(
          name: '/pagina02-shared-preferences',
          page: () => Pagina02SharedPref(),
        ),
        GetPage(name: '/pagina03-biometric', page: () => Pagina03Biometric()),
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
