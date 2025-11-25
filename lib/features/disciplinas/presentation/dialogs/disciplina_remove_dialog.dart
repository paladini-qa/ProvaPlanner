import 'package:flutter/material.dart';

/// Diálogo de confirmação de remoção de Disciplina
/// 
/// Este diálogo solicita confirmação antes de remover uma disciplina.
/// O diálogo é não-dismissable (não pode ser fechado tocando fora).
class DisciplinaRemoveDialog extends StatelessWidget {
  final String disciplinaNome;

  const DisciplinaRemoveDialog({
    super.key,
    required this.disciplinaNome,
  });

  static Future<bool> show(
    BuildContext context, {
    required String disciplinaNome,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Não pode fechar tocando fora
      builder: (context) => DisciplinaRemoveDialog(
        disciplinaNome: disciplinaNome,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar Remoção'),
      content: Text(
        'Tem certeza que deseja remover a disciplina "$disciplinaNome"?\n\nEsta ação não pode ser desfeita.',
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

