import 'package:flutter/material.dart';

/// Diálogo de confirmação de remoção de Aluno
/// 
/// Este diálogo solicita confirmação antes de remover um aluno.
/// O diálogo é não-dismissable (não pode ser fechado tocando fora).
class AlunoRemoveDialog extends StatelessWidget {
  final String alunoNome;

  const AlunoRemoveDialog({
    super.key,
    required this.alunoNome,
  });

  static Future<bool> show(
    BuildContext context, {
    required String alunoNome,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Não pode fechar tocando fora
      builder: (context) => AlunoRemoveDialog(
        alunoNome: alunoNome,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar Remoção'),
      content: Text(
        'Tem certeza que deseja remover o aluno "$alunoNome"?\n\nEsta ação não pode ser desfeita.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('NÃO'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('SIM, REMOVER'),
        ),
      ],
    );
  }
}

