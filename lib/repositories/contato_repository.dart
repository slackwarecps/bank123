// lib/repositories/contato_repository.dart

import 'package:dio/dio.dart';
import '../models/contato_model.dart';

class ContatoRepository {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://192.168.1.100:8089/bank123/bl/contatos';

  Future<List<ContatoModel>> getContatos() async {
    try {
      final response = await _dio.get(
        _baseUrl,
        options: Options(
          headers: {
            'minha-conta': '123456',
            'Authentication': '{meutoken}', // Substitua por seu token real
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dados = response.data['dados'];
        return dados.map((json) => ContatoModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar os contatos');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}