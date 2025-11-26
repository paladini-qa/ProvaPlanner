import 'package:flutter/material.dart';

class AnotacaoEditDialog extends StatefulWidget {
  final String? anotacaoId;
  final String? tituloInicial;
  final String? descricaoInicial;

  const AnotacaoEditDialog({super.key, this.anotacaoId, this.tituloInicial, this.descricaoInicial});

  static Future<Map<String, String>?> show(BuildContext context, {String? anotacaoId, String? tituloInicial, String? descricaoInicial}) {
    return showDialog<Map<String, String>>(context: context, barrierDismissible: false, builder: (context) => AnotacaoEditDialog(anotacaoId: anotacaoId, tituloInicial: tituloInicial, descricaoInicial: descricaoInicial));
  }

  @override
  State<AnotacaoEditDialog> createState() => _AnotacaoEditDialogState();
}

class _AnotacaoEditDialogState extends State<AnotacaoEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.tituloInicial ?? '');
    _descricaoController = TextEditingController(text: widget.descricaoInicial ?? '');
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({'id': widget.anotacaoId ?? '', 'titulo': _tituloController.text.trim(), 'descricao': _descricaoController.text.trim()});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.anotacaoId != null ? 'Editar Anotação' : 'Nova Anotação'),
      content: SingleChildScrollView(
        child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: _tituloController, decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()), validator: (value) => value == null || value.trim().isEmpty ? 'O título é obrigatório' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _descricaoController, decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()), maxLines: 5),
        ])),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('CANCELAR')), ElevatedButton(onPressed: _salvar, child: const Text('SALVAR'))],
    );
  }
}

