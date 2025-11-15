import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/entities/daily_goal.dart';
import '../domain/entities/prioridade_meta.dart';
import '../presentation/extensions/daily_goal_extension.dart';

class DailyGoalDialog extends StatefulWidget {
  final DailyGoal? goal;
  final DateTime? dataInicial;

  const DailyGoalDialog({
    super.key,
    this.goal,
    this.dataInicial,
  });

  @override
  State<DailyGoalDialog> createState() => _DailyGoalDialogState();

  static Future<DailyGoal?> show(
    BuildContext context, {
    DailyGoal? goal,
    DateTime? dataInicial,
  }) async {
    return await showDialog<DailyGoal>(
      context: context,
      builder: (context) => DailyGoalDialog(
        goal: goal,
        dataInicial: dataInicial,
      ),
    );
  }
}

class _DailyGoalDialogState extends State<DailyGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  DateTime _data = DateTime.now();
  PrioridadeMeta _prioridade = PrioridadeMeta.media;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _tituloController.text = widget.goal!.titulo;
      _descricaoController.text = widget.goal!.descricao;
      _data = widget.goal!.data;
      _prioridade = widget.goal!.prioridade;
    } else if (widget.dataInicial != null) {
      _data = widget.dataInicial!;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (data != null) {
      setState(() {
        _data = data;
      });
    }
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final goal = DailyGoal(
        id: widget.goal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        data: _data,
        prioridade: _prioridade,
        concluida: widget.goal?.concluida ?? false,
      );

      Navigator.of(context).pop(goal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditando = widget.goal != null;

    return AlertDialog(
      title: Text(isEditando ? 'Editar Meta' : 'Nova Meta Diária'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ex: Revisar capítulo 5 de Matemática',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Título é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Detalhes adicionais...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selecionarData,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_data),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PrioridadeMeta>(
                initialValue: _prioridade,
                decoration: const InputDecoration(
                  labelText: 'Prioridade',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: PrioridadeMeta.values.map((prioridade) {
                  final goal = DailyGoal(
                    id: '',
                    titulo: '',
                    descricao: '',
                    data: DateTime.now(),
                    prioridade: prioridade,
                  );
                  return DropdownMenuItem<PrioridadeMeta>(
                    value: prioridade,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: goal.corPrioridade,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(goal.prioridadeTexto),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _prioridade = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvar,
          child: Text(isEditando ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }
}

