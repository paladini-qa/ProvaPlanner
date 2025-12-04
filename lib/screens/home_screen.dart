import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../domain/entities/prova.dart';
import '../domain/entities/revisao.dart';
import '../presentation/services/prova_service.dart';
import '../widgets/app_icon.dart';
import '../widgets/prova_card.dart';
import '../widgets/revisao_card.dart';
import 'adicionar_prova_screen.dart';

class ProvaDataSource extends CalendarDataSource {
  ProvaDataSource(List<Prova> provas) {
    appointments = provas
        .map((prova) => Appointment(
              startTime: prova.dataProva,
              endTime: prova.dataProva.add(const Duration(hours: 1)),
              subject: prova.nome,
              color: Color(prova.cor),
              notes: prova.descricao,
            ))
        .toList();
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime as DateTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime as DateTime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject as String;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color as Color;
  }

  @override
  String getNotes(int index) {
    return appointments![index].notes as String;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Prova> _provas = [];
  List<Revisao> _revisoes = [];
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    initializeDateFormatting('pt_BR', null);
    // Usar addPostFrameCallback para evitar chamar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDados();
    });
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _carregarDados() async {
    if (_isUpdating) return; // Evita múltiplas chamadas simultâneas
    _isUpdating = true;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    final provas = await ProvaService.carregarProvas();
    final List<Revisao> revisoes = _selectedDay != null
        ? await ProvaService.obterRevisoesPorData(_selectedDay!)
        : <Revisao>[];

    if (mounted) {
      setState(() {
        _provas = provas;
        _revisoes = revisoes;
        _isLoading = false;
        _isUpdating = false;
      });
    } else {
      _isUpdating = false;
    }
  }

  Future<void> _adicionarProva() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AdicionarProvaScreen(),
      ),
    );

    if (result == true) {
      _carregarDados();
    }
  }

  Future<void> _marcarRevisaoConcluida(String provaId, String revisaoId) async {
    await ProvaService.marcarRevisaoConcluida(provaId, revisaoId);
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            AppIcon(size: 32),
            SizedBox(width: 12),
            Text('ProvaPlanner'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              if (!_isUpdating) {
                setState(() {
                  _focusedDay = DateTime.now();
                  _selectedDay = DateTime.now();
                });
                _carregarDados();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Calendário
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 400,
                        child: SfCalendar(
                          view: CalendarView.month,
                          initialDisplayDate: _focusedDay,
                          initialSelectedDate: _selectedDay,
                          onSelectionChanged:
                              (CalendarSelectionDetails details) {
                            if (details.date != null) {
                              final newDate = details.date!;
                              // Só atualiza se a data realmente mudou
                              if (!isSameDay(_selectedDay, newDate)) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) async {
                                  if (mounted && !_isUpdating) {
                                    setState(() {
                                      _selectedDay = newDate;
                                      _focusedDay = newDate;
                                    });
                                    await _carregarDados();
                                  }
                                });
                              }
                            }
                          },
                          onViewChanged: (ViewChangedDetails details) {
                            final newFocusedDay = details.visibleDates.first;
                            // Só atualiza se o mês realmente mudou e não está atualizando
                            if ((_focusedDay.year != newFocusedDay.year ||
                                    _focusedDay.month != newFocusedDay.month) &&
                                !_isUpdating) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted && !_isUpdating) {
                                  setState(() {
                                    _focusedDay = newFocusedDay;
                                  });
                                }
                              });
                            }
                          },
                          dataSource: ProvaDataSource(_provas),
                          monthViewSettings: const MonthViewSettings(
                            showAgenda: false,
                            appointmentDisplayMode:
                                MonthAppointmentDisplayMode.appointment,
                          ),
                          headerStyle: const CalendarHeaderStyle(
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    // Data selecionada e eventos
                    Expanded(
                      child: _selectedDay == null
                          ? const Center(
                              child: Text(
                                  'Selecione uma data para ver os eventos'),
                            )
                          : _buildEventosLista(),
                    ),
                  ],
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab',
        onPressed: _adicionarProva,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventosLista() {
    final provasDoDia = _provas.where((prova) {
      return isSameDay(prova.dataProva, _selectedDay!);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Cabeçalho da data
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                DateFormat('EEEE, d MMMM y', 'pt_BR').format(_selectedDay!),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Provas do dia
        if (provasDoDia.isNotEmpty) ...[
          Text(
            'Provas',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          ...provasDoDia.map((prova) => ProvaCard(
                prova: prova,
                onTap: () => _mostrarDetalhesProva(prova),
              )),
          const SizedBox(height: 16),
        ],

        // Revisões do dia
        if (_revisoes.isNotEmpty) ...[
          Text(
            'Revisões',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          ..._revisoes.map((revisao) => RevisaoCard(
                revisao: revisao,
                onToggle: (concluida) {
                  // Encontrar a prova da revisão
                  for (final prova in _provas) {
                    final revisaoEncontrada = prova.revisoes.firstWhere(
                      (r) => r.id == revisao.id,
                      orElse: () => revisao,
                    );
                    if (revisaoEncontrada.id == revisao.id) {
                      _marcarRevisaoConcluida(prova.id, revisao.id);
                      break;
                    }
                  }
                },
              )),
        ],

        // Mensagem quando não há eventos
        if (provasDoDia.isEmpty && _revisoes.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_available,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum evento para esta data',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Toque no + para adicionar uma prova',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _mostrarDetalhesProva(Prova prova) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(prova.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Disciplina: ${prova.disciplinaNome}'),
            const SizedBox(height: 8),
            Text('Data: ${DateFormat('dd/MM/yyyy').format(prova.dataProva)}'),
            if (prova.descricao.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Descrição: ${prova.descricao}'),
            ],
            const SizedBox(height: 16),
            Text(
              'Revisões:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...prova.revisoes.map((revisao) => ListTile(
                  leading: Icon(
                    revisao.concluida
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
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
