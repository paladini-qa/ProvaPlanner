import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para gerenciar consentimento e versionamento de políticas
class ConsentService {
  static const String _keyPolicyVersion = 'policy_version';
  static const String _keyAcceptedVersion = 'accepted_policy_version';
  static const String _keyAcceptedTimestamp = 'accepted_policy_timestamp';
  static const String _keyHasAcceptedPolicies = 'has_accepted_policies';
  static const String _keyConsentRevoked = 'consent_revoked';
  static const String _keyPreviousConsent = 'previous_consent_data';

  /// Versão atual das políticas
  static const String currentPolicyVersion = '1.0.0';

  /// Verificar se o usuário aceitou as políticas
  static Future<bool> hasAcceptedPolicies() async {
    final prefs = await SharedPreferences.getInstance();
    final result = prefs.getBool(_keyHasAcceptedPolicies) ?? false;
    debugPrint('ConsentService.hasAcceptedPolicies: $result');
    return result;
  }

  /// Verificar se a versão aceita é a atual
  static Future<bool> isPolicyVersionCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    final acceptedVersion = prefs.getString(_keyAcceptedVersion);
    final result = acceptedVersion == currentPolicyVersion;
    debugPrint('ConsentService.isPolicyVersionCurrent: acceptedVersion=$acceptedVersion, currentVersion=$currentPolicyVersion, result=$result');
    return result;
  }

  /// Verificar se precisa aceitar novas políticas
  static Future<bool> needsPolicyAcceptance() async {
    final hasAccepted = await hasAcceptedPolicies();
    debugPrint('ConsentService.needsPolicyAcceptance: hasAccepted=$hasAccepted');
    if (!hasAccepted) {
      debugPrint('ConsentService.needsPolicyAcceptance: Retornando true (não aceitou)');
      return true;
    }

    final isCurrent = await isPolicyVersionCurrent();
    final result = !isCurrent;
    debugPrint('ConsentService.needsPolicyAcceptance: isCurrent=$isCurrent, result=$result');
    return result;
  }

  /// Aceitar políticas com versionamento
  static Future<void> acceptPolicies({
    bool acceptedTerms = false,
    bool acceptedPrivacy = false,
    bool acceptedDataProcessing = false,
    bool acceptedNotifications = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Salvar dados do consentimento anterior para possível desfazer
    final previousData = {
      'hasAccepted': prefs.getBool(_keyHasAcceptedPolicies) ?? false,
      'version': prefs.getString(_keyAcceptedVersion),
      'timestamp': prefs.getInt(_keyAcceptedTimestamp),
      'terms': acceptedTerms,
      'privacy': acceptedPrivacy,
      'dataProcessing': acceptedDataProcessing,
      'notifications': acceptedNotifications,
    };
    await prefs.setString(_keyPreviousConsent, _encodeConsentData(previousData));

    // Salvar novo consentimento
    await prefs.setBool(_keyHasAcceptedPolicies, true);
    await prefs.setString(_keyAcceptedVersion, currentPolicyVersion);
    await prefs.setInt(_keyAcceptedTimestamp, DateTime.now().millisecondsSinceEpoch);
    await prefs.setBool('notifications_enabled', acceptedNotifications);
    await prefs.setBool(_keyConsentRevoked, false);
    
    debugPrint('ConsentService.acceptPolicies: Políticas aceitas e salvas');
    debugPrint('ConsentService.acceptPolicies: has_accepted_policies=${prefs.getBool(_keyHasAcceptedPolicies)}');
    debugPrint('ConsentService.acceptPolicies: accepted_version=${prefs.getString(_keyAcceptedVersion)}');
  }

  /// Revogar consentimento
  static Future<Map<String, dynamic>?> revokeConsent() async {
    final prefs = await SharedPreferences.getInstance();

    // Salvar dados atuais para possível desfazer
    final currentData = {
      'hasAccepted': prefs.getBool(_keyHasAcceptedPolicies) ?? false,
      'version': prefs.getString(_keyAcceptedVersion),
      'timestamp': prefs.getInt(_keyAcceptedTimestamp),
      'notifications': prefs.getBool('notifications_enabled') ?? false,
    };

    // Revogar consentimento
    await prefs.setBool(_keyHasAcceptedPolicies, false);
    await prefs.setBool(_keyConsentRevoked, true);
    await prefs.remove(_keyAcceptedVersion);
    await prefs.remove(_keyAcceptedTimestamp);

    return currentData;
  }

  /// Desfazer revogação de consentimento
  static Future<void> undoRevocation(Map<String, dynamic> previousData) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyHasAcceptedPolicies, previousData['hasAccepted'] as bool? ?? false);
    if (previousData['version'] != null) {
      await prefs.setString(_keyAcceptedVersion, previousData['version'] as String);
    }
    if (previousData['timestamp'] != null) {
      await prefs.setInt(_keyAcceptedTimestamp, previousData['timestamp'] as int);
    }
    if (previousData['notifications'] != null) {
      await prefs.setBool('notifications_enabled', previousData['notifications'] as bool);
    }
    await prefs.setBool(_keyConsentRevoked, false);
  }

  /// Verificar se consentimento foi revogado
  static Future<bool> isConsentRevoked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyConsentRevoked) ?? false;
  }

  /// Obter versão aceita das políticas
  static Future<String?> getAcceptedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAcceptedVersion);
  }

  /// Obter timestamp do aceite
  static Future<DateTime?> getAcceptedTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_keyAcceptedTimestamp);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Obter dados do consentimento anterior (para desfazer)
  static Future<Map<String, dynamic>?> getPreviousConsentData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyPreviousConsent);
    if (data == null) return null;
    return _decodeConsentData(data);
  }

  /// Limpar todos os dados de consentimento
  static Future<void> clearConsentData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasAcceptedPolicies);
    await prefs.remove(_keyAcceptedVersion);
    await prefs.remove(_keyAcceptedTimestamp);
    await prefs.remove(_keyConsentRevoked);
    await prefs.remove(_keyPreviousConsent);
  }

  /// Codificar dados de consentimento para armazenamento
  static String _encodeConsentData(Map<String, dynamic> data) {
    // Simples codificação JSON (em produção, considere criptografia)
    return data.toString();
  }

  /// Decodificar dados de consentimento
  static Map<String, dynamic> _decodeConsentData(String data) {
    // Decodificação simples (em produção, considere descriptografia)
    // Por simplicidade, retornamos um mapa vazio aqui
    // Em produção, use JSON.decode apropriado
    return {};
  }
}

