import 'package:flutter/material.dart';

class Disciplina {
  final String id;
  final String nome;
  final String professor;
  final String periodo;
  final String descricao;
  final Color cor;
  final DateTime dataCriacao;

  Disciplina({
    required this.id,
    required this.nome,
    required this.professor,
    required this.periodo,
    this.descricao = '',
    this.cor = Colors.blue,
    required this.dataCriacao,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'professor': professor,
      'periodo': periodo,
      'descricao': descricao,
      'cor': cor.toARGB32(),
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory Disciplina.fromJson(Map<String, dynamic> json) {
    return Disciplina(
      id: json['id'],
      nome: json['nome'],
      professor: json['professor'],
      periodo: json['periodo'],
      descricao: json['descricao'] ?? '',
      cor: Color(json['cor']),
      dataCriacao: DateTime.parse(json['dataCriacao']),
    );
  }

  Disciplina copyWith({
    String? id,
    String? nome,
    String? professor,
    String? periodo,
    String? descricao,
    Color? cor,
    DateTime? dataCriacao,
  }) {
    return Disciplina(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      professor: professor ?? this.professor,
      periodo: periodo ?? this.periodo,
      descricao: descricao ?? this.descricao,
      cor: cor ?? this.cor,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}
