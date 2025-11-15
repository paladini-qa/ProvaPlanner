import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prova.dart';

class RevisaoCard extends StatelessWidget {
  final Revisao revisao;
  final Function(bool) onToggle;

  const RevisaoCard({
    super.key,
    required this.revisao,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: revisao.concluida,
        onChanged: (value) {
          if (value != null) {
            onToggle(value);
          }
        },
        title: Text(
          revisao.descricao,
          style: TextStyle(
            decoration: revisao.concluida ? TextDecoration.lineThrough : null,
            color: revisao.concluida ? Colors.grey[600] : null,
          ),
        ),
        subtitle: Text(
          DateFormat('dd/MM/yyyy').format(revisao.data),
          style: TextStyle(
            color: revisao.concluida ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: revisao.concluida 
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.amber.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            revisao.concluida ? Icons.check_circle : Icons.book,
            color: revisao.concluida ? Colors.green : Colors.amber,
            size: 20,
          ),
        ),
        activeColor: Colors.green,
      ),
    );
  }
}

