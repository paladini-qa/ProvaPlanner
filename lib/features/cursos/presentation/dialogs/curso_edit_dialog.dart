import 'package:flutter/material.dart';

class CursoEditDialog extends StatefulWidget {
  final String? cursoId;
  final String? nomeInicial;
  final String? descricaoInicial;
  final int? cargaHorariaInicial;

  const CursoEditDialog({super.key, this.cursoId, this.nomeInicial, this.descricaoInicial, this.cargaHorariaInicial});

  static Future<Map<String, dynamic>?> show(BuildContext context, {String? cursoId, String? nomeInicial, String? descricaoInicial, int? cargaHorariaInicial}) {
    return showDialog<Map<String, dynamic>>(context: context, barrierDismissible: false, builder: (context) => CursoEditDialog(cursoId: cursoId, nomeInicial: nomeInicial, descricaoInicial: descricaoInicial, cargaHorariaInicial: cargaHorariaInicial));
  }

  @override
  State<CursoEditDialog> createState() => _CursoEditDialogState();
}

class _CursoEditDialogState extends State<CursoEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _cargaHorariaController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nomeInicial ?? '');
    _descricaoController = TextEditingController(text: widget.descricaoInicial ?? '');
    _cargaHorariaController = TextEditingController(text: widget.cargaHorariaInicial?.toString() ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _cargaHorariaController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({'id': widget.cursoId ?? '', 'nome': _nomeController.text.trim(), 'descricao': _descricaoController.text.trim(), 'cargaHoraria': int.tryParse(_cargaHorariaController.text.trim()) ?? 0});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.cursoId != null ? 'Editar Curso' : 'Novo Curso'),
      content: SingleChildScrollView(
        child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()), validator: (value) => value == null || value.trim().isEmpty ? 'O nome é obrigatório' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _descricaoController, decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()), maxLines: 3),
          const SizedBox(height: 16),
          TextFormField(controller: _cargaHorariaController, decoration: const InputDecoration(labelText: 'Carga Horária', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (value) => value == null || value.trim().isEmpty || int.tryParse(value) == null ? 'Carga horária inválida' : null),
        ])),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('CANCELAR')), ElevatedButton(onPressed: _salvar, child: const Text('SALVAR'))],
    );
  }
}

