import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/disciplina.dart';
import '../models/prova.dart';
import '../services/prova_service.dart';

class DetalhesDisciplinaScreen extends StatefulWidget {
  final Disciplina disciplina;

  const DetalhesDisciplinaScreen({super.key, required this.disciplina});

  @override
  State<DetalhesDisciplinaScreen> createState() => _DetalhesDisciplinaScreenState();
}

class _DetalhesDisciplinaScreenState extends State<DetalhesDisciplinaScreen> {
  List<Prova> _provas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarProvas();
  }

  Future<void> _carregarProvas() async {
    setState(() => _isLoading = true);
    
    final todasProvas = await ProvaService.carregarProvas();
    final provasDisciplina = todasProvas
        .where((prova) => prova.disciplinaId == widget.disciplina.id)
        .toList();
    
    // Ordenar por data
    provasDisciplina.sort((a, b) => a.dataProva.compareTo(b.dataProva));
    
    setState(() {
      _provas = provasDisciplina;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.disciplina.nome),
        backgroundColor: widget.disciplina.cor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informações da disciplina
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: widget.disciplina.cor.withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.school,
                                  color: widget.disciplina.cor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.disciplina.nome,
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Professor: ${widget.disciplina.professor}',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      'Período: ${widget.disciplina.periodo}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          if (widget.disciplina.descricao.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              'Descrição',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.disciplina.descricao,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                          
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          
                          // Estatísticas
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                'Total de Provas',
                                _provas.length.toString(),
                                Icons.quiz,
                              ),
                              _buildStatCard(
                                'Provas Concluídas',
                                _provas.where((p) => p.dataProva.isBefore(DateTime.now())).length.toString(),
                                Icons.check_circle,
                              ),
                              _buildStatCard(
                                'Próximas Provas',
                                _provas.where((p) => p.dataProva.isAfter(DateTime.now())).length.toString(),
                                Icons.schedule,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Histórico de provas
                  Text(
                    'Histórico de Provas',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (_provas.isEmpty)
                    _buildEmptyProvas()
                  else
                    _buildProvasList(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: widget.disciplina.cor,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: widget.disciplina.cor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyProvas() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma prova cadastrada',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'As provas desta disciplina aparecerão aqui',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvasList() {
    return Column(
      children: _provas.map((prova) {
        final isConcluida = prova.dataProva.isBefore(DateTime.now());
        final isProxima = prova.dataProva.isAfter(DateTime.now()) && 
                         prova.dataProva.difference(DateTime.now()).inDays <= 7;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isConcluida 
                  ? Colors.green.withValues(alpha: 0.1)
                  : isProxima 
                      ? Colors.orange.withValues(alpha: 0.1)
                      : widget.disciplina.cor.withValues(alpha: 0.1),
              child: Icon(
                isConcluida 
                    ? Icons.check_circle
                    : isProxima 
                        ? Icons.schedule
                        : Icons.quiz,
                color: isConcluida 
                    ? Colors.green
                    : isProxima 
                        ? Colors.orange
                        : widget.disciplina.cor,
              ),
            ),
            title: Text(
              prova.nome,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isConcluida ? Colors.grey[600] : null,
                decoration: isConcluida ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy - HH:mm').format(prova.dataProva),
                  style: TextStyle(
                    color: isConcluida ? Colors.grey[500] : null,
                  ),
                ),
                if (prova.descricao.isNotEmpty)
                  Text(
                    prova.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${prova.revisoes.length} revisões',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: isConcluida
                ? const Icon(Icons.check_circle, color: Colors.green)
                : isProxima
                    ? const Icon(Icons.schedule, color: Colors.orange)
                    : null,
            onTap: () {
              _mostrarDetalhesProva(prova);
            },
          ),
        );
      }).toList(),
    );
  }

  void _mostrarDetalhesProva(Prova prova) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(prova.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data: ${DateFormat('dd/MM/yyyy - HH:mm').format(prova.dataProva)}'),
            const SizedBox(height: 8),
            if (prova.descricao.isNotEmpty) ...[
              Text('Descrição: ${prova.descricao}'),
              const SizedBox(height: 8),
            ],
            Text(
              'Revisões:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...prova.revisoes.map((revisao) => ListTile(
              leading: Icon(
                revisao.concluida ? Icons.check_circle : Icons.radio_button_unchecked,
                color: revisao.concluida ? Colors.green : Colors.grey,
              ),
              title: Text(revisao.descricao),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(revisao.data)),
              dense: true,
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
