import 'package:flutter/material.dart';

/// Diálogo de edição de Disciplina
/// 
/// Este diálogo permite editar os campos de uma disciplina.
/// O diálogo é não-dismissable (não pode ser fechado tocando fora).
class DisciplinaEditDialog extends StatefulWidget {
  final String? disciplinaId;
  final String? nomeInicial;
  final String? professorInicial;
  final String? periodoInicial;
  final String? descricaoInicial;

  const DisciplinaEditDialog({
    super.key,
    this.disciplinaId,
    this.nomeInicial,
    this.professorInicial,
    this.periodoInicial,
    this.descricaoInicial,
  });

  static Future<Map<String, String>?> show(
    BuildContext context, {
    String? disciplinaId,
    String? nomeInicial,
    String? professorInicial,
    String? periodoInicial,
    String? descricaoInicial,
  }) {
    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false, // Não pode fechar tocando fora
      builder: (context) => DisciplinaEditDialog(
        disciplinaId: disciplinaId,
        nomeInicial: nomeInicial,
        professorInicial: professorInicial,
        periodoInicial: periodoInicial,
        descricaoInicial: descricaoInicial,
      ),
    );
  }

  @override
  State<DisciplinaEditDialog> createState() => _DisciplinaEditDialogState();
}

class _DisciplinaEditDialogState extends State<DisciplinaEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _professorController;
  late TextEditingController _periodoController;
  late TextEditingController _descricaoController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nomeInicial ?? '');
    _professorController = TextEditingController(text: widget.professorInicial ?? '');
    _periodoController = TextEditingController(text: widget.periodoInicial ?? '');
    _descricaoController = TextEditingController(text: widget.descricaoInicial ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _professorController.dispose();
    _periodoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'id': widget.disciplinaId ?? '',
        'nome': _nomeController.text.trim(),
        'professor': _professorController.text.trim(),
        'periodo': _periodoController.text.trim(),
        'descricao': _descricaoController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.disciplinaId != null ? 'Editar Disciplina' : 'Nova Disciplina'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Disciplina',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _professorController,
                decoration: const InputDecoration(
                  labelText: 'Professor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O professor é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _periodoController,
                decoration: const InputDecoration(
                  labelText: 'Período',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O período é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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

