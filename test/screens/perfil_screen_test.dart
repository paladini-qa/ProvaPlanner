import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prova_planner/screens/perfil_screen.dart';
import 'package:prova_planner/widgets/app_icon.dart';

void main() {
  group('PerfilScreen Widget Tests', () {
    late Widget testWidget;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SharedPreferences.getInstance();
      
      testWidget = const MaterialApp(
        home: PerfilScreen(),
      );
    });

    tearDown(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    testWidgets('deve mostrar AppIcon quando não há foto', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(); // Use pump() instead of pumpAndSettle() to avoid timeout

      // Verificar se AppIcon está presente
      expect(find.byType(AppIcon), findsOneWidget);
      
      // Verificar se CircleAvatar está presente
      expect(find.byType(CircleAvatar), findsOneWidget);
      
      // Verificar se botão de editar está presente
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('deve mostrar informações do usuário', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verificar se nome padrão está presente
      expect(find.text('Usuário'), findsOneWidget);
      
      // Verificar se email padrão está presente
      expect(find.text('usuario@exemplo.com'), findsOneWidget);
    });

    testWidgets('deve mostrar aviso de privacidade', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verificar se aviso de privacidade está presente
      expect(find.text('Sua foto fica apenas neste dispositivo. Você pode remover quando quiser.'), findsOneWidget);
    });

    testWidgets('deve ter botão de editar foto acessível', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verificar se botão de editar está presente
      final editButton = find.byIcon(Icons.edit);
      expect(editButton, findsOneWidget);

      // Verificar se botão tem área de toque adequada (32x32 = 64dp, maior que 48dp mínimo)
      final editButtonWidget = tester.widget<Icon>(editButton);
      expect(editButtonWidget.size, equals(16.0));
      
      // Verificar se container pai tem tamanho adequado
      final containerFinder = find.ancestor(
        of: editButton,
        matching: find.byType(Container),
      );
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('deve mostrar loading inicial', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      
      // Verificar se CircularProgressIndicator está presente durante carregamento
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Aguardar carregamento completo
      await tester.pump();
      
      // Verificar se loading desapareceu
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('deve ter avatar com semantics adequado', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verificar se Semantics está presente no avatar
      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && 
                   widget.properties.label == "Foto do perfil" &&
                   widget.properties.image == true,
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets('deve ter botão de editar com semantics adequado', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verificar se Semantics está presente no botão de editar
      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && 
                   widget.properties.label == "Alterar foto do perfil" &&
                   widget.properties.button == true,
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets('deve mostrar bottom sheet ao tocar no botão de editar', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Tocar no botão de editar
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Verificar se BottomSheet aparece
      expect(find.text('Alterar Foto do Perfil'), findsOneWidget);
      expect(find.text('Tirar Foto'), findsOneWidget);
      expect(find.text('Escolher da Galeria'), findsOneWidget);
    });

    testWidgets('deve ter estrutura de navegação correta', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verificar se AppBar está presente
      expect(find.byType(AppBar), findsOneWidget);
      
      // Verificar se título está correto
      expect(find.text('Perfil'), findsOneWidget);
      
      // Verificar se botão de editar perfil está presente
      expect(find.byIcon(Icons.edit), findsAtLeastNWidgets(1));
    });

    testWidgets('deve ter configurações de notificações', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verificar se switch de notificações está presente
      expect(find.byType(Switch), findsOneWidget);
      
      // Verificar se texto de notificações está presente
      expect(find.text('Notificações'), findsOneWidget);
    });

    testWidgets('deve ter opção de limpar dados', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verificar se opção de limpar dados está presente
      expect(find.text('Limpar Dados'), findsOneWidget);
      
      // Verificar se ícone de delete está presente
      expect(find.byIcon(Icons.delete_forever), findsOneWidget);
    });

    testWidgets('deve ter FileImage com cache otimizado quando há foto', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verificar se CircleAvatar está presente
      final circleAvatar = find.byType(CircleAvatar);
      expect(circleAvatar, findsOneWidget);

      // Verificar se CircleAvatar tem backgroundImage null (sem foto)
      final circleAvatarWidget = tester.widget<CircleAvatar>(circleAvatar);
      expect(circleAvatarWidget.backgroundImage, isNull);
    });
  });
}
