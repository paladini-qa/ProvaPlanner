import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

class AuthService {
  static SupabaseClient get _client {
    if (!SupabaseConfig.isInitialized) {
      throw Exception('Supabase não está inicializado');
    }
    return SupabaseConfig.client;
  }

  /// Verifica se o usuário está autenticado
  static bool get isAuthenticated {
    try {
      return _client.auth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  /// Obtém o usuário atual
  static User? get currentUser {
    try {
      return _client.auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  /// Obtém o email do usuário atual
  static String? get currentUserEmail {
    return currentUser?.email;
  }

  /// Obtém o ID do usuário atual
  static String? get currentUserId {
    return currentUser?.id;
  }

  /// Faz login com email e senha
  static Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        throw Exception('Falha ao fazer login');
      }

      return response.user!;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erro ao fazer login: ${e.toString()}');
    }
  }

  /// Cria uma nova conta com email e senha
  static Future<User> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: name != null ? {'name': name} : null,
      );

      if (response.user == null) {
        throw Exception('Falha ao criar conta');
      }

      // O trigger do Supabase cria o perfil automaticamente
      // Aguardar um pouco e atualizar o perfil com o nome se fornecido
      if (response.user != null &&
          response.user!.id.isNotEmpty &&
          name != null) {
        // Aguardar o trigger criar o perfil
        await Future<void>.delayed(const Duration(milliseconds: 500));

        try {
          await _updateUserProfileName(
            userId: response.user!.id,
            name: name,
          );
        } catch (e) {
          // Se falhar, não é crítico - o perfil já foi criado pelo trigger
          debugPrint('Aviso: Não foi possível atualizar nome do perfil: $e');
        }
      }

      return response.user!;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erro ao criar conta: ${e.toString()}');
    }
  }

  /// Atualiza o nome do perfil do usuário (o perfil é criado automaticamente pelo trigger)
  static Future<void> _updateUserProfileName({
    required String userId,
    required String name,
  }) async {
    try {
      await _client.from('profiles').update({
        'name': name,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      // Se o perfil ainda não existir, aguardar mais um pouco e tentar novamente
      if (e.toString().contains('not found') ||
          e.toString().contains('no rows')) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await _client.from('profiles').update({
          'name': name,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
      } else {
        rethrow;
      }
    }
  }

  /// Faz logout
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: ${e.toString()}');
    }
  }

  /// Redefine a senha
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erro ao redefinir senha: ${e.toString()}');
    }
  }

  /// Verifica se o usuário completou o onboarding
  static Future<bool> hasCompletedOnboarding() async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final response = await _client
          .from('profiles')
          .select('onboarding_completed')
          .eq('id', userId)
          .single();

      return (response['onboarding_completed'] as bool?) ?? false;
    } catch (e) {
      // Se não conseguir verificar, assumir que não completou
      debugPrint('Erro ao verificar onboarding: $e');
      return false;
    }
  }

  /// Marca o onboarding como completo
  static Future<void> markOnboardingCompleted() async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      await _client.from('profiles').update({
        'onboarding_completed': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      debugPrint('Erro ao marcar onboarding como completo: $e');
      // Não lançar exceção - não é crítico
    }
  }

  /// Obtém o perfil do usuário do Supabase
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final response =
          await _client.from('profiles').select().eq('id', userId).single();

      return response as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Erro ao buscar perfil: $e');
      return null;
    }
  }

  /// Atualiza o perfil do usuário no Supabase
  static Future<void> updateProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (photoUrl != null) updateData['photo_url'] = photoUrl;

      await _client.from('profiles').update(updateData).eq('id', userId);
    } catch (e) {
      debugPrint('Erro ao atualizar perfil: $e');
      throw Exception('Erro ao atualizar perfil: ${e.toString()}');
    }
  }

  /// Faz upload da foto para o Supabase Storage
  static Future<String> uploadPhoto(Uint8List imageBytes) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      // Nome do arquivo único
      final fileName = 'avatar_$userId.jpg';
      final path = 'avatars/$fileName';

      // Fazer upload
      await _client.storage.from('profiles').uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Obter URL pública
      final photoUrl = _client.storage.from('profiles').getPublicUrl(path);

      // Atualizar perfil com a URL
      await updateProfile(photoUrl: photoUrl);

      return photoUrl;
    } catch (e) {
      debugPrint('Erro ao fazer upload da foto: $e');
      throw Exception('Erro ao fazer upload da foto: ${e.toString()}');
    }
  }

  /// Remove a foto do Supabase Storage
  static Future<void> deletePhoto() async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      final fileName = 'avatar_$userId.jpg';
      final path = 'avatars/$fileName';

      await _client.storage.from('profiles').remove([path]);

      // Atualizar perfil removendo a URL
      await updateProfile(photoUrl: '');
    } catch (e) {
      debugPrint('Erro ao remover foto: $e');
      throw Exception('Erro ao remover foto: ${e.toString()}');
    }
  }

  /// Escuta mudanças no estado de autenticação
  static Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  /// Converte exceções de autenticação em mensagens amigáveis
  static String _handleAuthException(AuthException e) {
    switch (e.statusCode) {
      case 'invalid_credentials':
        return 'Email ou senha incorretos';
      case 'signup_disabled':
        return 'Cadastro de novos usuários está desabilitado';
      case 'email_rate_limit_exceeded':
        return 'Muitas tentativas. Tente novamente mais tarde';
      case 'weak_password':
        return 'A senha é muito fraca. Use pelo menos 6 caracteres';
      case 'user_already_registered':
        return 'Este email já está cadastrado';
      case 'invalid_email':
        return 'Email inválido';
      default:
        return e.message.isNotEmpty ? e.message : 'Erro de autenticação';
    }
  }
}
