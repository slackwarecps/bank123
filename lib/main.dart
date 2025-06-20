import 'package:bank123/telas/login.dart';
import 'package:bank123/telas/pagina_nao_encontrada.dart';
import 'package:bank123/telas/tela_de_erro.dart';
import 'package:bank123/telas/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      unknownRoute: GetPage(name: '/notfound', page: () => PaginaNaoEncontrada()),
      initialRoute: '/login',
            getPages: [
        GetPage(name: '/', page: () =>  LoginScreen()),
        GetPage(name: '/home-page', page: () => const HomePage()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/error-page', page: () => TelaDeErro()),
            ],
      title: 'Bank 123',
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
