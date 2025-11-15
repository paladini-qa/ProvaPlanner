import 'package:flutter/material.dart';

class Prova {
  final String id;
  final String nome;
  final String disciplinaId;
  final String disciplinaNome;
  final DateTime dataProva;
  final String descricao;
  final List<Revisao> revisoes;
  final Color cor;

  Prova({
    required this.id,
    required this.nome,
    required this.disciplinaId,
    required this.disciplinaNome,
    required this.dataProva,
    this.descricao = '',
    required this.revisoes,
    this.cor = Colors.blue,
  });

  // Gera automaticamente 3 revisões distribuídas nos 7 dias antes da prova
  static List<Revisao> gerarRevisoes(DateTime dataProva) {
    final revisoes = <Revisao>[];
    final hoje = DateTime.now();
    
    // Calcula os dias restantes até a prova
    final diasRestantes = dataProva.difference(hoje).inDays;
    
    if (diasRestantes >= 7) {
      // Se há 7+ dias, distribui as revisões nos últimos 7 dias
      final dataInicio = dataProva.subtract(const Duration(days: 7));
      revisoes.add(Revisao(
        id: '${dataProva.millisecondsSinceEpoch}_1',
        data: dataInicio.add(const Duration(days: 1)),
        concluida: false,
        descricao: 'Primeira revisão - Conceitos básicos',
      ));
      revisoes.add(Revisao(
        id: '${dataProva.millisecondsSinceEpoch}_2',
        data: dataInicio.add(const Duration(days: 4)),
        concluida: false,
        descricao: 'Segunda revisão - Exercícios práticos',
      ));
      revisoes.add(Revisao(
        id: '${dataProva.millisecondsSinceEpoch}_3',
        data: dataInicio.add(const Duration(days: 6)),
        concluida: false,
        descricao: 'Terceira revisão - Revisão geral',
      ));
    } else if (diasRestantes >= 3) {
      // Se há 3-6 dias, distribui as revisões nos dias restantes
      final intervalos = diasRestantes ~/ 3;
      for (int i = 0; i < 3; i++) {
        final dataRevisao = hoje.add(Duration(days: (i + 1) * intervalos));
        if (dataRevisao.isBefore(dataProva)) {
          revisoes.add(Revisao(
            id: '${dataProva.millisecondsSinceEpoch}_${i + 1}',
            data: dataRevisao,
            concluida: false,
            descricao: 'Revisão ${i + 1}',
          ));
        }
      }
    } else {
      // Se há menos de 3 dias, cria revisões para os dias restantes
      for (int i = 1; i <= diasRestantes && i <= 3; i++) {
        final dataRevisao = hoje.add(Duration(days: i));
        if (dataRevisao.isBefore(dataProva)) {
          revisoes.add(Revisao(
            id: '${dataProva.millisecondsSinceEpoch}_$i',
            data: dataRevisao,
            concluida: false,
            descricao: 'Revisão $i',
          ));
        }
      }
    }
    
    return revisoes;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'disciplinaId': disciplinaId,
      'disciplinaNome': disciplinaNome,
      'dataProva': dataProva.toIso8601String(),
      'descricao': descricao,
      'revisoes': revisoes.map((r) => r.toJson()).toList(),
      'cor': cor.toARGB32(),
    };
  }

  factory Prova.fromJson(Map<String, dynamic> json) {
    return Prova(
      id: json['id'],
      nome: json['nome'],
      disciplinaId: json['disciplinaId'] ?? json['disciplina'] ?? '',
      disciplinaNome: json['disciplinaNome'] ?? json['disciplina'] ?? '',
      dataProva: DateTime.parse(json['dataProva']),
      descricao: json['descricao'] ?? '',
      revisoes: (json['revisoes'] as List)
          .map((r) => Revisao.fromJson(r))
          .toList(),
      cor: Color(json['cor']),
    );
  }
}

class Revisao {
  final String id;
  final DateTime data;
  final bool concluida;
  final String descricao;

  Revisao({
    required this.id,
    required this.data,
    required this.concluida,
    required this.descricao,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data.toIso8601String(),
      'concluida': concluida,
      'descricao': descricao,
    };
  }

  factory Revisao.fromJson(Map<String, dynamic> json) {
    return Revisao(
      id: json['id'],
      data: DateTime.parse(json['data']),
      concluida: json['concluida'],
      descricao: json['descricao'],
    );
  }

  Revisao copyWith({
    String? id,
    DateTime? data,
    bool? concluida,
    String? descricao,
  }) {
    return Revisao(
      id: id ?? this.id,
      data: data ?? this.data,
      concluida: concluida ?? this.concluida,
      descricao: descricao ?? this.descricao,
    );
  }
}

