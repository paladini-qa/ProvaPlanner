import 'package:flutter/material.dart';
import '../../domain/entities/disciplina.dart';
import '../services/disciplina_service.dart';
import '../../theme/app_theme.dart';

class AdicionarDisciplinaScreen extends StatefulWidget {
  final Disciplina? disciplina;

  const AdicionarDisciplinaScreen({super.key, this.disciplina});

  @override
  State<AdicionarDisciplinaScreen> createState() => _AdicionarDisciplinaScreenState();
}

class _AdicionarDisciplinaScreenState extends State<AdicionarDisciplinaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _professorController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  String _periodoSelecionado = '1º Período';
  int _corSelecionada = AppTheme.indigo.value;
  bool _isLoading = false;

  final List<String> _periodos = [
    '1º Período',
    '2º Período',
    '3º Período',
    '4º Período',
    '5º Período',
    '6º Período',
    '7º Período',
    '8º Período',
  ];

  final List<int> _cores = [
    AppTheme.indigo.value,
    AppTheme.amber.value,
    Colors.red.value,
    Colors.green.value,
    Colors.purple.value,
    Colors.orange.value,
    Colors.teal.value,
    Colors.pink.value,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.disciplina != null) {
      _carregarDadosDisciplina();
    }
  }

  void _carregarDadosDisciplina() {
    final disciplina = widget.disciplina!;
    _nomeController.text = disciplina.nome;
    _professorController.text = disciplina.professor;
    _descricaoController.text = disciplina.descricao;
    _periodoSelecionado = disciplina.periodo;
    _corSelecionada = disciplina.cor;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _professorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarDisciplina() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final disciplina = Disciplina(
        id: widget.disciplina?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text.trim(),
        professor: _professorController.text.trim(),
        periodo: _periodoSelecionado,
        descricao: _descricaoController.text.trim(),
        cor: _corSelecionada,
        dataCriacao: widget.disciplina?.dataCriacao ?? DateTime.now(),
      );

      if (widget.disciplina != null) {
        await DisciplinaService.atualizarDisciplina(disciplina);
      } else {
        await DisciplinaService.adicionarDisciplina(disciplina);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar disciplina: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.disciplina != null ? 'Editar Disciplina' : 'Nova Disciplina'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _salvarDisciplina,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome da disciplina
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Disciplina *',
                  hintText: 'Ex: Matemática, Física, Química',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 16),
              
              // Professor
              TextFormField(
                controller: _professorController,
                decoration: const InputDecoration(
                  labelText: 'Professor *',
                  hintText: 'Nome do professor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Professor é obrigatório';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 16),
              
              // Período
              DropdownButtonFormField<String>(
                initialValue: _periodoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Período *',
                  border: OutlineInputBorder(),
                ),
                items: _periodos.map((periodo) {
                  return DropdownMenuItem(
                    value: periodo,
                    child: Text(periodo),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _periodoSelecionado = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Descrição
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Informações adicionais sobre a disciplina',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              
              const SizedBox(height: 24),
              
              // Seleção de cor
              Text(
                'Cor da Disciplina',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _cores.map((cor) {
                  final isSelected = _corSelecionada == cor;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _corSelecionada = cor;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(cor),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Botão salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvarDisciplina,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.disciplina != null ? 'Atualizar Disciplina' : 'Criar Disciplina',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
