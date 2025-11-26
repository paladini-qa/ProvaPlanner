import 'package:flutter/material.dart';

class CursoActionsDialog extends StatelessWidget {
  final String cursoNome;
  final String? cursoId;
  final String? descricao;
  final int? cargaHoraria;
  final VoidCallback? onEditar;
  final VoidCallback? onRemover;

  const CursoActionsDialog({super.key, required this.cursoNome, this.cursoId, this.descricao, this.cargaHoraria, this.onEditar, this.onRemover});

  static Future<void> show(BuildContext context, {required String cursoNome, String? cursoId, String? descricao, int? cargaHoraria, VoidCallback? onEditar, VoidCallback? onRemover}) {
    return showDialog<void>(context: context, barrierDismissible: false, builder: (context) => CursoActionsDialog(cursoNome: cursoNome, cursoId: cursoId, descricao: descricao, cargaHoraria: cargaHoraria, onEditar: onEditar, onRemover: onRemover));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detalhes do Curso'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildDetailRow('Nome', cursoNome),
          if (descricao != null && descricao!.isNotEmpty) _buildDetailRow('Descrição', descricao!),
          if (cargaHoraria != null) _buildDetailRow('Carga Horária', '${cargaHoraria}h'),
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

