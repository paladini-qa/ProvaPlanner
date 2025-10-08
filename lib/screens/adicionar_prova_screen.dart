import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prova.dart';
import '../services/prova_service.dart';
import '../theme/app_theme.dart';

class AdicionarProvaScreen extends StatefulWidget {
  const AdicionarProvaScreen({super.key});

  @override
  State<AdicionarProvaScreen> createState() => _AdicionarProvaScreenState();
}

class _AdicionarProvaScreenState extends State<AdicionarProvaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _disciplinaController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  DateTime _dataProva = DateTime.now().add(const Duration(days: 7));
  Color _corSelecionada = AppTheme.indigo;
  
  final List<Color> _coresDisponiveis = [
    AppTheme.indigo,
    AppTheme.amber,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.orange,
    Colors.pink,
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _disciplinaController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataProva,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (data != null) {
      setState(() {
        _dataProva = data;
      });
    }
  }

  Future<void> _salvarProva() async {
    if (_formKey.currentState!.validate()) {
      try {
        final prova = Prova(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nome: _nomeController.text.trim(),
          disciplina: _disciplinaController.text.trim(),
          dataProva: _dataProva,
          descricao: _descricaoController.text.trim(),
          revisoes: Prova.gerarRevisoes(_dataProva),
          cor: _corSelecionada,
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
            
            // Disciplina
            TextFormField(
              controller: _disciplinaController,
              decoration: const InputDecoration(
                labelText: 'Disciplina',
                hintText: 'Ex: Matemática, Física, etc.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Disciplina é obrigatória';
                }
                return null;
              },
            ),
            
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
            
            // Seleção de cor
            Text(
              'Cor da Prova',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 12,
              children: _coresDisponiveis.map((cor) {
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
                      color: cor,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: cor.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
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
