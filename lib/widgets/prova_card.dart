import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prova.dart';

class ProvaCard extends StatelessWidget {
  final Prova prova;
  final VoidCallback? onTap;

  const ProvaCard({
    super.key,
    required this.prova,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final diasRestantes = prova.dataProva.difference(hoje).inDays;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: prova.cor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.quiz,
            color: prova.cor,
            size: 24,
          ),
        ),
        title: Text(
          prova.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(prova.disciplina),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(prova.dataProva),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _getDiasRestantesText(diasRestantes),
                  style: TextStyle(
                    color: _getDiasRestantesColor(diasRestantes),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  String _getDiasRestantesText(int dias) {
    if (dias < 0) {
      return 'Atrasada';
    } else if (dias == 0) {
      return 'Hoje';
    } else if (dias == 1) {
      return 'Amanhã';
    } else {
      return '$dias dias';
    }
  }

  Color _getDiasRestantesColor(int dias) {
    if (dias < 0) {
      return Colors.red;
    } else if (dias <= 1) {
      return Colors.orange;
    } else if (dias <= 3) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }
}

