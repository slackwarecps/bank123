// lib/models/contato_model.dart

class ContatoModel {
  String nome;
  ChavePixModel chavePix;

  ContatoModel({
    required this.nome,
    required this.chavePix,
  });

  factory ContatoModel.fromJson(Map<String, dynamic> json) {
    return ContatoModel(
      nome: json['nome'],
      chavePix: ChavePixModel.fromJson(json['chavePix']),
    );
  }
}

class ChavePixModel {
  String tipo;
  String valor;

  ChavePixModel({
    required this.tipo,
    required this.valor,
  });

  factory ChavePixModel.fromJson(Map<String, dynamic> json) {
    return ChavePixModel(
      tipo: json['tipo'],
      valor: json['valor'],
    );
  }
}