import 'package:flutter/material.dart';

class CursoRemoveDialog extends StatelessWidget {
  final String cursoNome;
  const CursoRemoveDialog({super.key, required this.cursoNome});

  static Future<bool> show(BuildContext context, {required String cursoNome}) async {
    final result = await showDialog<bool>(context: context, barrierDismissible: false, builder: (context) => CursoRemoveDialog(cursoNome: cursoNome));
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(title: const Text('Confirmar Remoção'), content: Text('Tem certeza que deseja remover o curso "$cursoNome"?\n\nEsta ação não pode ser desfeita.'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('NÃO')), TextButton(onPressed: () => Navigator.of(context).pop(true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('SIM, REMOVER'))]);
  }
}

