import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/prova.dart';
import '../../domain/entities/disciplina.dart';
import '../services/prova_service.dart';
import '../services/disciplina_service.dart';

class AdicionarProvaScreen extends StatefulWidget {
  const AdicionarProvaScreen({super.key});

  @override
  State<AdicionarProvaScreen> createState() => _AdicionarProvaScreenState();
}

class _AdicionarProvaScreenState extends State<AdicionarProvaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  DateTime _dataProva = DateTime.now().add(const Duration(days: 7));
  Disciplina? _disciplinaSelecionada;
  List<Disciplina> _disciplinas = [];
  bool _isLoadingDisciplinas = true;

  @override
  void initState() {
    super.initState();
    _carregarDisciplinas();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarDisciplinas() async {
    final disciplinas = await DisciplinaService.carregarDisciplinas();
    setState(() {
      _disciplinas = disciplinas;
      _isLoadingDisciplinas = false;
    });
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataProva,
      firstDate: DateTime.now(),
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
        _dataProva = data;
      });
    }
  }

  Future<void> _salvarProva() async {
    if (_formKey.currentState!.validate() && _disciplinaSelecionada != null) {
      try {
        final prova = Prova(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nome: _nomeController.text.trim(),
          disciplinaId: _disciplinaSelecionada!.id,
          disciplinaNome: _disciplinaSelecionada!.nome,
          dataProva: _dataProva,
          descricao: _descricaoController.text.trim(),
          revisoes: Prova.gerarRevisoes(_dataProva),
          cor: _disciplinaSelecionada!.cor,
        );

        await ProvaService.adicionarProva(prova);
        
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prova adicionada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar prova: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Prova'),
        actions: [
          TextButton(
            onPressed: _salvarProva,
            child: const Text(
              'Salvar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nome da prova
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome da Prova',
                hintText: 'Ex: Prova A, Exame Final, etc.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.quiz),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome da prova é obrigatório';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Seleção de Disciplina
            DropdownButtonFormField<Disciplina>(
              initialValue: _disciplinaSelecionada,
              decoration: const InputDecoration(
                labelText: 'Disciplina *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              hint: _isLoadingDisciplinas 
                  ? const Text('Carregando disciplinas...', style: TextStyle(color: Colors.black54))
                  : const Text('Selecione uma disciplina', style: TextStyle(color: Colors.black54)),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              items: _disciplinas.map((disciplina) {
                return DropdownMenuItem<Disciplina>(
                  value: disciplina,
                  child: Text(
                    disciplina.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (disciplina) {
                setState(() {
                  _disciplinaSelecionada = disciplina;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Selecione uma disciplina';
                }
                return null;
              },
            ),
            
            if (_disciplinas.isEmpty && !_isLoadingDisciplinas) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nenhuma disciplina cadastrada. Cadastre uma disciplina primeiro.',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Exibição da disciplina selecionada
            if (_disciplinaSelecionada != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(_disciplinaSelecionada!.cor).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(_disciplinaSelecionada!.cor).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(_disciplinaSelecionada!.cor).withValues(alpha: 0.2),
                      child: Icon(
                        Icons.school,
                        size: 20,
                        color: Color(_disciplinaSelecionada!.cor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _disciplinaSelecionada!.nome,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(_disciplinaSelecionada!.cor),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Professor: ${_disciplinaSelecionada!.professor}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Período: ${_disciplinaSelecionada!.periodo}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Data da prova
            InkWell(
              onTap: _selecionarData,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data da Prova',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(_dataProva),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Descrição (opcional)
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Detalhes adicionais sobre a prova...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            
            const SizedBox(height: 32),
            
            // Preview do plano de revisão
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Plano de Revisão (7 dias)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Serão criadas automaticamente 3 revisões distribuídas nos 7 dias antes da prova:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    ...Prova.gerarRevisoes(_dataProva).map((revisao) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.book,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${DateFormat('dd/MM').format(revisao.data)} - ${revisao.descricao}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

