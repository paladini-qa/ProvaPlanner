import 'package:flutter/material.dart';

/// Diálogo de ações para Aluno
/// 
/// Exibe um diálogo com três ações: FECHAR, EDITAR e REMOVER.
/// Este diálogo é não-dismissable (não pode ser fechado tocando fora).
class AlunoActionsDialog extends StatelessWidget {
  final String alunoNome;
  final String? alunoId;
  final String? matricula;
  final String? email;

  final VoidCallback? onEditar;
  final VoidCallback? onRemover;

  const AlunoActionsDialog({
    super.key,
    required this.alunoNome,
    this.alunoId,
    this.matricula,
    this.email,
    this.onEditar,
    this.onRemover,
  });

  static Future<void> show(
    BuildContext context, {
    required String alunoNome,
    String? alunoId,
    String? matricula,
    String? email,
    VoidCallback? onEditar,
    VoidCallback? onRemover,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Não pode fechar tocando fora
      builder: (context) => AlunoActionsDialog(
        alunoNome: alunoNome,
        alunoId: alunoId,
        matricula: matricula,
        email: email,
        onEditar: onEditar,
        onRemover: onRemover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detalhes do Aluno'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nome', alunoNome),
            if (matricula != null) _buildDetailRow('Matrícula', matricula!),
            if (email != null) _buildDetailRow('Email', email!),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Selecione uma ação:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('FECHAR'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onEditar?.call();
          },
          child: const Text('EDITAR'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRemover?.call();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('REMOVER'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

