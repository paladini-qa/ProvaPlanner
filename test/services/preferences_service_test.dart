import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prova_planner/services/preferences_service.dart';

void main() {
  group('PreferencesService', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    tearDown(() async {
      await prefs.clear();
    });

    group('UserName', () {
      test('deve retornar nome padrão quando não há valor salvo', () async {
        final name = await PreferencesService.getUserName();
        expect(name, equals('Usuário'));
      });

      test('deve salvar e recuperar nome do usuário', () async {
        const testName = 'João Silva';
        await PreferencesService.setUserName(testName);
        
        final retrievedName = await PreferencesService.getUserName();
        expect(retrievedName, equals(testName));
      });
    });

    group('UserEmail', () {
      test('deve retornar email padrão quando não há valor salvo', () async {
        final email = await PreferencesService.getUserEmail();
        expect(email, equals('usuario@exemplo.com'));
      });

      test('deve salvar e recuperar email do usuário', () async {
        const testEmail = 'joao@exemplo.com';
        await PreferencesService.setUserEmail(testEmail);
        
        final retrievedEmail = await PreferencesService.getUserEmail();
        expect(retrievedEmail, equals(testEmail));
      });
    });

    group('UserPhotoPath', () {
      test('deve retornar null quando não há foto salva', () async {
        final photoPath = await PreferencesService.getUserPhotoPath();
        expect(photoPath, isNull);
      });

      test('deve salvar e recuperar caminho da foto', () async {
        const testPath = '/path/to/avatar.jpg';
        await PreferencesService.setUserPhotoPath(testPath);
        
        final retrievedPath = await PreferencesService.getUserPhotoPath();
        expect(retrievedPath, equals(testPath));
      });

      test('deve remover caminho da foto quando passado null', () async {
        const testPath = '/path/to/avatar.jpg';
        await PreferencesService.setUserPhotoPath(testPath);
        await PreferencesService.setUserPhotoPath(null);
        
        final retrievedPath = await PreferencesService.getUserPhotoPath();
        expect(retrievedPath, isNull);
      });
    });

    group('UserPhotoUpdatedAt', () {
      test('deve retornar null quando não há timestamp salvo', () async {
        final timestamp = await PreferencesService.getUserPhotoUpdatedAt();
        expect(timestamp, isNull);
      });

      test('deve salvar e recuperar timestamp da foto', () async {
        const testTimestamp = 1234567890;
        await PreferencesService.setUserPhotoUpdatedAt(testTimestamp);
        
        final retrievedTimestamp = await PreferencesService.getUserPhotoUpdatedAt();
        expect(retrievedTimestamp, equals(testTimestamp));
      });

      test('deve remover timestamp quando passado null', () async {
        const testTimestamp = 1234567890;
        await PreferencesService.setUserPhotoUpdatedAt(testTimestamp);
        await PreferencesService.setUserPhotoUpdatedAt(null);
        
        final retrievedTimestamp = await PreferencesService.getUserPhotoUpdatedAt();
        expect(retrievedTimestamp, isNull);
      });
    });

    group('NotificationsEnabled', () {
      test('deve retornar true como padrão quando não há valor salvo', () async {
        final enabled = await PreferencesService.getNotificationsEnabled();
        expect(enabled, isTrue);
      });

      test('deve salvar e recuperar status das notificações', () async {
        await PreferencesService.setNotificationsEnabled(false);
        
        final enabled = await PreferencesService.getNotificationsEnabled();
        expect(enabled, isFalse);
      });
    });

    group('clearProfileData', () {
      test('deve limpar todos os dados do perfil', () async {
        // Salvar dados de teste
        await PreferencesService.setUserName('Test User');
        await PreferencesService.setUserEmail('test@example.com');
        await PreferencesService.setUserPhotoPath('/test/path.jpg');
        await PreferencesService.setUserPhotoUpdatedAt(1234567890);
        await PreferencesService.setNotificationsEnabled(false);

        // Limpar dados
        await PreferencesService.clearProfileData();

        // Verificar se foram limpos
        expect(await PreferencesService.getUserName(), equals('Usuário'));
        expect(await PreferencesService.getUserEmail(), equals('usuario@exemplo.com'));
        expect(await PreferencesService.getUserPhotoPath(), isNull);
        expect(await PreferencesService.getUserPhotoUpdatedAt(), isNull);
        expect(await PreferencesService.getNotificationsEnabled(), isTrue);
      });
    });

    group('clearAllData', () {
      test('deve limpar todos os dados do SharedPreferences', () async {
        // Salvar dados de teste
        await PreferencesService.setUserName('Test User');
        await PreferencesService.setUserEmail('test@example.com');

        // Limpar todos os dados
        await PreferencesService.clearAllData();

        // Verificar se foram limpos (volta aos valores padrão)
        expect(await PreferencesService.getUserName(), equals('Usuário'));
        expect(await PreferencesService.getUserEmail(), equals('usuario@exemplo.com'));
      });
    });
  });
}

