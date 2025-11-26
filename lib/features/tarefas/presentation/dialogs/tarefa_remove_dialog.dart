import 'package:flutter/material.dart';

class TarefaRemoveDialog extends StatelessWidget {
  final String tarefaTitulo;

  const TarefaRemoveDialog({super.key, required this.tarefaTitulo});

  static Future<bool> show(BuildContext context, {required String tarefaTitulo}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TarefaRemoveDialog(tarefaTitulo: tarefaTitulo),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar Remoção'),
      content: Text(
        'Tem certeza que deseja remover a tarefa "$tarefaTitulo"?\n\nEsta ação não pode ser desfeita.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('NÃO'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('SIM, REMOVER'),
        ),
      ],
    );
  }
}

