import 'package:flutter/material.dart';

/// Diálogo de edição de Aluno
/// 
/// Este diálogo permite editar os campos de um aluno.
/// O diálogo é não-dismissable (não pode ser fechado tocando fora).
class AlunoEditDialog extends StatefulWidget {
  final String? alunoId;
  final String? nomeInicial;
  final String? matriculaInicial;
  final String? emailInicial;

  const AlunoEditDialog({
    super.key,
    this.alunoId,
    this.nomeInicial,
    this.matriculaInicial,
    this.emailInicial,
  });

  static Future<Map<String, String>?> show(
    BuildContext context, {
    String? alunoId,
    String? nomeInicial,
    String? matriculaInicial,
    String? emailInicial,
  }) {
    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false, // Não pode fechar tocando fora
      builder: (context) => AlunoEditDialog(
        alunoId: alunoId,
        nomeInicial: nomeInicial,
        matriculaInicial: matriculaInicial,
        emailInicial: emailInicial,
      ),
    );
  }

  @override
  State<AlunoEditDialog> createState() => _AlunoEditDialogState();
}

class _AlunoEditDialogState extends State<AlunoEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _matriculaController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nomeInicial ?? '');
    _matriculaController = TextEditingController(text: widget.matriculaInicial ?? '');
    _emailController = TextEditingController(text: widget.emailInicial ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _matriculaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'id': widget.alunoId ?? '',
        'nome': _nomeController.text.trim(),
        'matricula': _matriculaController.text.trim(),
        'email': _emailController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.alunoId != null ? 'Editar Aluno' : 'Novo Aluno'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
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
                controller: _matriculaController,
                decoration: const InputDecoration(
                  labelText: 'Matrícula',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'A matrícula é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O email é obrigatório';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
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

