import 'package:flutter/material.dart';
import '../../domain/entities/daily_goal.dart';
import '../../domain/entities/prioridade_meta.dart';

extension DailyGoalExtension on DailyGoal {
  Color get corPrioridade {
    switch (prioridade) {
      case PrioridadeMeta.alta:
        return Colors.red;
      case PrioridadeMeta.media:
        return Colors.orange;
      case PrioridadeMeta.baixa:
        return Colors.green;
    }
  }
}

