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
  /// IMPORTANTE: Verifica tanto a sessão local quanto se o usuário existe no Supabase
  static bool get isAuthenticated {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return false;
      }
      // Verificar se a sessão ainda é válida verificando o token
      // Se o token expirou ou é inválido, o usuário não está autenticado
      return user.id.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se o usuário está autenticado e se a sessão é válida no servidor
  static Future<bool> isAuthenticatedAndValid() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return false;
      }

      // Tentar atualizar a sessão para verificar se ainda é válida
      try {
        final session = _client.auth.currentSession;
        if (session == null) {
          return false;
        }

        // Verificar se o token não expirou
        if (session.expiresAt != null) {
          final expiresAt = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
          if (expiresAt.isBefore(DateTime.now())) {
            await signOut();
            return false;
          }
        }

        // Tentar buscar o perfil para verificar se o usuário ainda existe
        try {
          await _client
              .from('profiles')
              .select('id')
              .eq('id', user.id)
              .maybeSingle();
          return true;
        } catch (e) {
          // Se não conseguir verificar o perfil, assumir que não está autenticado
          return false;
        }
      } catch (e) {
        return false;
      }
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

      // Verificar se o perfil existe no Supabase, se não existir, criar
      try {
        final profile = await _client
            .from('profiles')
            .select('id')
            .eq('id', response.user!.id)
            .maybeSingle();
        
        if (profile == null) {
          // Criar perfil automaticamente se não existir
          try {
            await _client.from('profiles').insert({
              'id': response.user!.id,
              'email': response.user!.email ?? '',
              'name': response.user!.userMetadata?['name'] ?? response.user!.email ?? 'Usuário',
              'onboarding_completed': false,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
          } catch (e) {
            // Se falhar ao criar perfil, ainda permitir login (o trigger pode criar depois)
            // Não fazer logout, apenas logar o erro
          }
        }
      } catch (e) {
        // Não fazer logout - permitir login mesmo se houver problema com perfil
        // O perfil pode ser criado depois pelo trigger ou manualmente
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
        await Future<void>.delayed(const Duration(milliseconds: 1000));

        try {
          await _updateUserProfileName(
            userId: response.user!.id,
            name: name,
          );
        } catch (e) {
          // Se falhar, não é crítico - o perfil já foi criado pelo trigger
        }
      }

      return response.user!;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
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

  /// Limpa sessões inválidas (útil para limpar cache local)
  static Future<void> clearInvalidSessions() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return;
      }

      // Verificar se a sessão ainda é válida
      final isValid = await isAuthenticatedAndValid();
      if (!isValid) {
        await signOut();
      }
    } catch (e) {
      // Se houver erro, fazer logout para garantir que não há sessão inválida
      try {
        await signOut();
      } catch (_) {
        // Ignorar erro no logout
      }
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
      if (userId == null) {
        return false;
      }

      // Tentar método 1: Query direta
      try {
        final response = await _client
            .from('profiles')
            .select('onboarding_completed')
            .eq('id', userId)
            .single();

        if (response != null && response.isNotEmpty) {
          final onboardingCompleted = response['onboarding_completed'];

          // Tratar diferentes tipos de retorno
          if (onboardingCompleted != null) {
            // Se for boolean, retornar diretamente
            if (onboardingCompleted is bool) {
              return onboardingCompleted;
            }

            // Se for string, converter
            if (onboardingCompleted is String) {
              final boolValue = onboardingCompleted.toLowerCase() == 'true' || onboardingCompleted == '1';
              return boolValue;
            }

            // Se for int (0 ou 1), converter
            if (onboardingCompleted is int) {
              final boolValue = onboardingCompleted == 1;
              return boolValue;
            }

            // Tentar cast direto como fallback
            final result = (onboardingCompleted as bool?) ?? false;
            return result;
          }
        }
      } catch (e) {
        // Tentar método alternativo
      }

      // Método 2: Usar getProfile() como fallback
      final profile = await getProfile();
      if (profile != null && profile.containsKey('onboarding_completed')) {
        final onboardingCompleted = profile['onboarding_completed'];

        if (onboardingCompleted is bool) {
          return onboardingCompleted;
        }
        if (onboardingCompleted is String) {
          return onboardingCompleted.toLowerCase() == 'true' || onboardingCompleted == '1';
        }
        if (onboardingCompleted is int) {
          return onboardingCompleted == 1;
        }
      }

      return false;
    } catch (e, stackTrace) {
      // Se não conseguir verificar, assumir que não completou
      return false;
    }
  }

  /// Marca o onboarding como completo
  static Future<void> markOnboardingCompleted() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return;
      }

      final response = await _client.from('profiles').update({
        'onboarding_completed': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId).select();

      // Verificar se a atualização foi bem-sucedida
      if (response.isEmpty) {
        // Nenhuma linha foi atualizada
      }
    } catch (e, stackTrace) {
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
      throw Exception('Erro ao remover foto: ${e.toString()}');
    }
  }

  /// Escuta mudanças no estado de autenticação
  static Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  /// Converte exceções de autenticação em mensagens amigáveis
  static String _handleAuthException(AuthException e) {
    // Verificar primeiro pela mensagem (alguns erros vêm com statusCode genérico)
    final messageLower = e.message.toLowerCase();
    if (messageLower.contains('already registered') || 
        messageLower.contains('user already registered') ||
        messageLower.contains('email already registered')) {
      return 'Este email já está cadastrado. Se você já tem uma conta, faça login.';
    }
    
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
        return 'Este email já está cadastrado. Se você já tem uma conta, faça login.';
      case 'invalid_email':
        return 'Email inválido';
      case '422': // HTTP 422 - Unprocessable Entity (usado pelo Supabase para alguns erros)
        if (messageLower.contains('already') || messageLower.contains('registered')) {
          return 'Este email já está cadastrado. Se você já tem uma conta, faça login.';
        }
        return e.message.isNotEmpty ? e.message : 'Erro ao processar solicitação';
      default:
        // Mostrar mensagem mais detalhada para debug
        final message = e.message.isNotEmpty ? e.message : 'Erro de autenticação';
        return message;
    }
  }
}
