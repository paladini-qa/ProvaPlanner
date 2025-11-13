import 'package:flutter/material.dart';

enum PrioridadeMeta {
  baixa,
  media,
  alta,
}

class DailyGoal {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime data;
  final bool concluida;
  final PrioridadeMeta prioridade;

  DailyGoal({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
    this.concluida = false,
    this.prioridade = PrioridadeMeta.media,
  });

  DailyGoal copyWith({
    String? id,
    String? titulo,
    String? descricao,
    DateTime? data,
    bool? concluida,
    PrioridadeMeta? prioridade,
  }) {
    return DailyGoal(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      data: data ?? this.data,
      concluida: concluida ?? this.concluida,
      prioridade: prioridade ?? this.prioridade,
    );
  }

  Color get corPrioridade {
    switch (prioridade) {
      case PrioridadeMeta.alta:
        return Colors.red;
      case PrioridadeMeta.media:
        return Colors.orange;
      case PrioridadeMeta.baixa:
        return Colors.green;
    }
  }

  String get prioridadeTexto {
    switch (prioridade) {
      case PrioridadeMeta.alta:
        return 'Alta';
      case PrioridadeMeta.media:
        return 'Média';
      case PrioridadeMeta.baixa:
        return 'Baixa';
    }
  }
}

