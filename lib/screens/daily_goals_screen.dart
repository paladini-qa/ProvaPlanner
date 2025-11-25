import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/daily_goal.dart';
import '../presentation/services/daily_goal_service.dart';
import '../presentation/extensions/daily_goal_extension.dart';
import '../services/prova_service.dart';
import '../services/goal_suggestion_service.dart';
import '../services/gemini_service.dart';
import '../config/env.dart';
import '../widgets/daily_goal_dialog.dart';
import '../widgets/daily_summary_card.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icon.dart';

class DailyGoalsScreen extends StatefulWidget {
  const DailyGoalsScreen({super.key});

  @override
  State<DailyGoalsScreen> createState() => _DailyGoalsScreenState();
}

class _DailyGoalsScreenState extends State<DailyGoalsScreen>
    with TickerProviderStateMixin {
  List<DailyGoal> _goals = [];
  bool _isLoading = true;
  DateTime _dataSelecionada = DateTime.now();
  String _resumoDiario = '';
  bool _isLoadingResumo = false;

  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupFabAnimations();
    _carregarGoals();
  }

  void _setupFabAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fabRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _fabAnimationController.repeat(reverse: true);
  }


  Future<void> _carregarGoals() async {
    setState(() {
      _isLoading = true;
    });

    final goals = await DailyGoalService.obterGoalsPorData(_dataSelecionada);
    setState(() {
      _goals = goals;
      _isLoading = false;
    });

    // Carregar resumo diário se for hoje
    if (_dataSelecionada.year == DateTime.now().year &&
        _dataSelecionada.month == DateTime.now().month &&
        _dataSelecionada.day == DateTime.now().day) {
      _gerarResumoDiario();
    }
  }

  Future<void> _gerarResumoDiario() async {
    setState(() {
      _isLoadingResumo = true;
    });

    try {
      // Obter dados do dia
      final provasDoDia = await ProvaService.obterProvasPorData(_dataSelecionada);
      final revisoesDoDia = await ProvaService.obterRevisoesPorData(_dataSelecionada);
      final metasDoDia = _goals;

      // Preparar textos
      final provasTexto = provasDoDia.map((p) => '${p.nome} - ${p.disciplinaNome}').toList();
      final revisoesTexto = revisoesDoDia.map((r) => r.descricao).toList();
      final metasTexto = metasDoDia.map((m) => m.titulo).toList();

      // Verificar se a chave da API está configurada
      final apiKey = Env.geminiApiKey;
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(
          'Chave da API do Gemini não configurada. '
          'Por favor, configure a GEMINI_API_KEY no arquivo .env',
        );
      }

      // Criar serviço de IA
      final aiService = GeminiService();
      
      // Gerar resumo
      final resumo = await aiService.gerarResumoDiario(
        provas: provasTexto,
        revisoes: revisoesTexto,
        metas: metasTexto,
      );

      setState(() {
        _resumoDiario = resumo;
        _isLoadingResumo = false;
      });
    } catch (e) {
      String mensagemErro;
      final errorStr = e.toString();
      
      if (errorStr.contains('GEMINI_API_KEY não configurada') || 
          errorStr.contains('Chave da API do Gemini não configurada')) {
        mensagemErro = 'Chave da API não configurada.\n\n'
            'Por favor, configure a GEMINI_API_KEY no arquivo .env do projeto.';
      } else if (errorStr.contains('Modelo não disponível') || 
                 errorStr.contains('permission denied')) {
        mensagemErro = 'Erro ao acessar o modelo da IA.\n\n'
            'Verifique se sua chave da API tem acesso ao modelo gemini-2.0-flash. '
            'Acesse https://aistudio.google.com/ para verificar.';
      } else if (errorStr.contains('quota') || errorStr.contains('limit')) {
        mensagemErro = 'Limite de quota da API excedido.\n\n'
            'Verifique seu uso no Google AI Studio ou aguarde alguns minutos antes de tentar novamente.';
      } else if (errorStr.contains('api key') || errorStr.contains('authentication') ||
                 errorStr.contains('Chave da API inválida')) {
        mensagemErro = 'Chave da API inválida.\n\n'
            'Verifique se a GEMINI_API_KEY está correta no arquivo .env.';
      } else if (errorStr.contains('network') || errorStr.contains('connection') ||
                 errorStr.contains('timeout') || errorStr.contains('socket')) {
        mensagemErro = 'Erro de conexão com a API.\n\n'
            'Verifique sua conexão com a internet e tente novamente.';
      } else {
        mensagemErro = 'Erro ao gerar resumo.\n\n'
            'Detalhes: ${errorStr.length > 100 ? '${errorStr.substring(0, 100)}...' : errorStr}\n\n'
            'Verifique o console para mais informações.';
      }
      
      setState(() {
        _resumoDiario = mensagemErro;
        _isLoadingResumo = false;
      });
    }
  }

  Future<void> _sugerirMetas() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final sugestoes = await GoalSuggestionService.gerarSugestoes();

      if (!mounted) return;

      if (sugestoes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma sugestão disponível no momento.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Mostrar dialog para aceitar/rejeitar sugestões
      final sugestoesAceitas = await showDialog<List<DailyGoal>>(
        context: context,
        builder: (context) => _SugestoesDialog(sugestoes: sugestoes),
      );

      if (sugestoesAceitas != null && sugestoesAceitas.isNotEmpty) {
        for (final goal in sugestoesAceitas) {
          await DailyGoalService.adicionarGoal(goal);
        }
        await _carregarGoals();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${sugestoesAceitas.length} meta(s) adicionada(s)!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar sugestões: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _adicionarGoal() async {
    final goal = await DailyGoalDialog.show(
      context,
      dataInicial: _dataSelecionada,
    );

    if (goal != null) {
      await DailyGoalService.adicionarGoal(goal);
      await _carregarGoals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meta adicionada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _editarGoal(DailyGoal goal) async {
    final goalEditado = await DailyGoalDialog.show(
      context,
      goal: goal,
    );

    if (goalEditado != null) {
      await DailyGoalService.atualizarGoal(goalEditado);
      await _carregarGoals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meta atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _alternarConclusao(DailyGoal goal) async {
    final goalAtualizado = goal.copyWith(concluida: !goal.concluida);
    await DailyGoalService.atualizarGoal(goalAtualizado);
    await _carregarGoals();
  }

  Future<void> _removerGoal(DailyGoal goal) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a meta "${goal.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await DailyGoalService.removerGoal(goal.id);
      await _carregarGoals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meta removida com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
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
        _dataSelecionada = data;
        _resumoDiario = ''; // Limpar resumo ao mudar data
      });
      await _carregarGoals();
    }
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Icon(
              Icons.flag_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma meta para hoje',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Toque no botão + para criar sua primeira meta diária de estudo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
    );
  }

  Widget _buildTipBubble() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.amber.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppTheme.amber,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Dica: Crie metas específicas e mensuráveis para melhorar seu desempenho nos estudos!',
              style: TextStyle(
                color: AppTheme.slate,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(DailyGoal goal) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: goal.concluida,
          onChanged: (_) => _alternarConclusao(goal),
          activeColor: AppTheme.indigo,
        ),
        title: Text(
          goal.titulo,
          style: TextStyle(
            decoration: goal.concluida
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: goal.concluida ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (goal.descricao.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                goal.descricao,
                style: TextStyle(
                  color: goal.concluida ? Colors.grey : Colors.grey[700],
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: goal.corPrioridade.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    goal.prioridadeTexto,
                    style: TextStyle(
                      color: goal.corPrioridade,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'editar',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'excluir',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'editar') {
              _editarGoal(goal);
            } else if (value == 'excluir') {
              _removerGoal(goal);
            }
          },
        ),
      ),
    );
  }


  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            AppIcon(size: 32),
            SizedBox(width: 12),
            Text('Metas Diárias'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: _sugerirMetas,
            tooltip: 'Sugerir metas com IA',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selecionarData,
            tooltip: 'Selecionar data',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.indigo.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppTheme.indigo,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_dataSelecionada),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.indigo,
                      ),
                    ),
                  ],
                ),
              ),
              // Conteúdo scrollável
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _goals.isEmpty
                        ? SingleChildScrollView(
                            child: _buildEmptyState(),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Resumo diário (apenas para hoje)
                                if (_dataSelecionada.year == DateTime.now().year &&
                                    _dataSelecionada.month == DateTime.now().month &&
                                    _dataSelecionada.day == DateTime.now().day)
                                  DailySummaryCard(
                                    resumo: _resumoDiario,
                                    isLoading: _isLoadingResumo,
                                    onRefresh: _gerarResumoDiario,
                                  ),
                                _buildTipBubble(),
                                // Lista de metas
                                ..._goals.map((goal) => _buildGoalCard(goal)),
                                // Espaço extra no final para evitar overflow com FAB
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation.value,
              child: Transform.rotate(
              angle: _fabRotationAnimation.value,
              child: FloatingActionButton(
                onPressed: _adicionarGoal,
                child: const Icon(Icons.add),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SugestoesDialog extends StatefulWidget {
  final List<DailyGoal> sugestoes;

  const _SugestoesDialog({required this.sugestoes});

  @override
  State<_SugestoesDialog> createState() => _SugestoesDialogState();
}

class _SugestoesDialogState extends State<_SugestoesDialog> {
  final Set<String> _sugestoesSelecionadas = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.auto_awesome, color: AppTheme.indigo),
          SizedBox(width: 8),
          Text('Sugestões de Metas'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.sugestoes.length,
          itemBuilder: (context, index) {
            final goal = widget.sugestoes[index];
            final isSelecionada = _sugestoesSelecionadas.contains(goal.id);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: CheckboxListTile(
                value: isSelecionada,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _sugestoesSelecionadas.add(goal.id);
                    } else {
                      _sugestoesSelecionadas.remove(goal.id);
                    }
                  });
                },
                title: Text(goal.titulo),
                subtitle: goal.descricao.isNotEmpty
                    ? Text(
                        goal.descricao,
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
                secondary: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: goal.corPrioridade.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    goal.prioridadeTexto,
                    style: TextStyle(
                      color: goal.corPrioridade,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(<DailyGoal>[]),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final selecionadas = widget.sugestoes
                .where((g) => _sugestoesSelecionadas.contains(g.id))
                .toList();
            Navigator.of(context).pop(selecionadas);
          },
          child: Text('Adicionar (${_sugestoesSelecionadas.length})'),
        ),
      ],
    );
  }
}

