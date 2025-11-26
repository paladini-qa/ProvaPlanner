import 'package:flutter/material.dart';

class AnotacaoActionsDialog extends StatelessWidget {
  final String anotacaoTitulo;
  final String? anotacaoId;
  final String? descricao;
  final VoidCallback? onEditar;
  final VoidCallback? onRemover;

  const AnotacaoActionsDialog({super.key, required this.anotacaoTitulo, this.anotacaoId, this.descricao, this.onEditar, this.onRemover});

  static Future<void> show(BuildContext context, {required String anotacaoTitulo, String? anotacaoId, String? descricao, VoidCallback? onEditar, VoidCallback? onRemover}) {
    return showDialog<void>(context: context, barrierDismissible: false, builder: (context) => AnotacaoActionsDialog(anotacaoTitulo: anotacaoTitulo, anotacaoId: anotacaoId, descricao: descricao, onEditar: onEditar, onRemover: onRemover));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detalhes da Anotação'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildDetailRow('Título', anotacaoTitulo),
          if (descricao != null && descricao!.isNotEmpty) _buildDetailRow('Descrição', descricao!),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Selecione uma ação:', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('FECHAR')),
        TextButton(onPressed: () { Navigator.of(context).pop(); onEditar?.call(); }, child: const Text('EDITAR')),
        TextButton(onPressed: () { Navigator.of(context).pop(); onRemover?.call(); }, style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('REMOVER')),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 80, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))), Expanded(child: Text(value))]));
  }
}

