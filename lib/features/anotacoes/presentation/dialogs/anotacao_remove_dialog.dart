import 'package:flutter/material.dart';

class AnotacaoRemoveDialog extends StatelessWidget {
  final String anotacaoTitulo;
  const AnotacaoRemoveDialog({super.key, required this.anotacaoTitulo});

  static Future<bool> show(BuildContext context, {required String anotacaoTitulo}) async {
    final result = await showDialog<bool>(context: context, barrierDismissible: false, builder: (context) => AnotacaoRemoveDialog(anotacaoTitulo: anotacaoTitulo));
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(title: const Text('Confirmar Remoção'), content: Text('Tem certeza que deseja remover a anotação "$anotacaoTitulo"?\n\nEsta ação não pode ser desfeita.'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('NÃO')), TextButton(onPressed: () => Navigator.of(context).pop(true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('SIM, REMOVER'))]);
  }
}

