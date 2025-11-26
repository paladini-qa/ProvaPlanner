import 'package:flutter/material.dart';

class TarefaEditDialog extends StatefulWidget {
  final String? tarefaId;
  final String? tituloInicial;
  final String? descricaoInicial;
  final bool concluidaInicial;

  const TarefaEditDialog({
    super.key,
    this.tarefaId,
    this.tituloInicial,
    this.descricaoInicial,
    this.concluidaInicial = false,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    String? tarefaId,
    String? tituloInicial,
    String? descricaoInicial,
    bool concluidaInicial = false,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TarefaEditDialog(
        tarefaId: tarefaId,
        tituloInicial: tituloInicial,
        descricaoInicial: descricaoInicial,
        concluidaInicial: concluidaInicial,
      ),
    );
  }

  @override
  State<TarefaEditDialog> createState() => _TarefaEditDialogState();
}

class _TarefaEditDialogState extends State<TarefaEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late bool _concluida;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.tituloInicial ?? '');
    _descricaoController = TextEditingController(text: widget.descricaoInicial ?? '');
    _concluida = widget.concluidaInicial;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'id': widget.tarefaId ?? '',
        'titulo': _tituloController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'concluida': _concluida,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.tarefaId != null ? 'Editar Tarefa' : 'Nova Tarefa'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O título é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Concluída'),
                value: _concluida,
                onChanged: (value) => setState(() => _concluida = value ?? false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: _salvar,
          child: const Text('SALVAR'),
        ),
      ],
    );
  }
}

