import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TutorialStep {
  none,
  navigateToDisciplinas,  // Passo 0: Navegar para tela de disciplinas
  addDisciplina,          // Passo 1: Adicionar disciplina
  addProva,              // Passo 2: Adicionar prova
  viewCalendar,          // Passo 3: Ver calendário
  addDailyGoal,          // Passo 4: Adicionar meta diária
  completed,             // Tutorial concluído
}

class TutorialService {
  static const String _key = 'tutorial_step';
  static const String _keyCompleted = 'tutorial_completed';

  // Obter passo atual do tutorial
  static Future<TutorialStep> getCurrentStep() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_keyCompleted) ?? false;
      
      if (completed) {
        return TutorialStep.completed;
      }

      final stepIndex = prefs.getInt(_key);
      if (stepIndex == null) {
        // Se não há passo salvo, retornar none (primeira vez)
        return TutorialStep.none;
      }
      
      if (stepIndex >= 0 && stepIndex < TutorialStep.values.length) {
        return TutorialStep.values[stepIndex];
      }
      
      return TutorialStep.none;
    } catch (e) {
      debugPrint('Erro ao obter passo do tutorial: $e');
      return TutorialStep.none;
    }
  }

  // Definir passo atual do tutorial
  static Future<void> setCurrentStep(TutorialStep step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, step.index);
    
    if (step == TutorialStep.completed) {
      await prefs.setBool(_keyCompleted, true);
    }
  }

  // Avançar para o próximo passo
  static Future<void> nextStep() async {
    final currentStep = await getCurrentStep();
    
    if (currentStep == TutorialStep.completed) {
      return;
    }

    final nextIndex = currentStep.index + 1;
    if (nextIndex < TutorialStep.completed.index) {
      await setCurrentStep(TutorialStep.values[nextIndex]);
    } else {
      await setCurrentStep(TutorialStep.completed);
    }
  }

  // Pular tutorial
  static Future<void> skipTutorial() async {
    await setCurrentStep(TutorialStep.completed);
  }

  // Reiniciar tutorial (útil para testes)
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_keyCompleted);
  }

  // Verificar se tutorial está ativo
  static Future<bool> isTutorialActive() async {
    final step = await getCurrentStep();
    return step != TutorialStep.none && step != TutorialStep.completed;
  }

  // Verificar se tutorial foi concluído
  static Future<bool> isTutorialCompleted() async {
    final step = await getCurrentStep();
    return step == TutorialStep.completed;
  }
}

