import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icon.dart';
import '../repositories/profile_repository.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String _nome = 'Usuário';
  String _email = 'usuario@exemplo.com';
  bool _notificacoesHabilitadas = true;
  bool _isLoading = true;
  String? _fotoPath;
  Uint8List? _fotoData; // Para web

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    try {
      // Carregar dados usando ProfileRepository
      final profileData = await ProfileRepository.getProfileData();
      
      setState(() {
        _nome = profileData['name'] as String;
        _email = profileData['email'] as String;
        _notificacoesHabilitadas = profileData['notificationsEnabled'] as bool;
        _fotoPath = profileData['photoPath'] as String?;
        _isLoading = false;
      });
      
      // Carregar dados da foto
      await _carregarFoto();
    } catch (e) {
      // Fallback para SharedPreferences se ProfileRepository falhar
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _nome = prefs.getString('nome_usuario') ?? 'Usuário';
        _email = prefs.getString('email_usuario') ?? 'usuario@exemplo.com';
        _notificacoesHabilitadas = prefs.getBool('notifications_enabled') ?? true;
        _fotoPath = null;
        _isLoading = false;
      });
    }
  }

  ImageProvider? _getBackgroundImage() {
    if (kIsWeb && _fotoData != null) {
      return MemoryImage(_fotoData!);
    } else if (!kIsWeb && _fotoPath != null) {
      return FileImage(File(_fotoPath!));
    }
    return null;
  }

  Widget? _getAvatarChild() {
    if ((kIsWeb && _fotoData == null) || (!kIsWeb && _fotoPath == null)) {
      return const AppIcon(size: 60);
    }
    return null;
  }

  Future<void> _carregarFoto() async {
    try {
      final photo = await ProfileRepository.getPhoto();
      
      if (photo != null) {
        if (kIsWeb) {
          // Para web, photo é uma string base64
          final base64String = photo as String;
          final bytes = base64Decode(base64String);
          setState(() {
            _fotoData = bytes;
          });
        } else {
          // Para mobile, photo é um File
          final file = photo as File;
          setState(() {
            _fotoPath = file.path;
          });
        }
      } else {
        setState(() {
          _fotoPath = null;
          _fotoData = null;
        });
      }
    } catch (e) {
      setState(() {
        _fotoPath = null;
        _fotoData = null;
      });
    }
  }

  Future<void> _salvarDadosUsuario() async {
    try {
      // Salvar usando ProfileRepository
      await ProfileRepository.updateProfileData(
        name: _nome,
        email: _email,
        notificationsEnabled: _notificacoesHabilitadas,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados salvos com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Fallback para SharedPreferences se ProfileRepository falhar
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nome_usuario', _nome);
      await prefs.setString('email_usuario', _email);
      await prefs.setBool('notifications_enabled', _notificacoesHabilitadas);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados salvos com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _editarPerfil() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _EditarPerfilDialog(
        nome: _nome,
        email: _email,
        notificacoes: _notificacoesHabilitadas,
      ),
    );

    if (result != null) {
      setState(() {
        _nome = result['nome'];
        _email = result['email'];
        _notificacoesHabilitadas = result['notificacoes'];
      });
      await _salvarDadosUsuario();
    }
  }

  Future<void> _mostrarOpcoesFoto() async {
    final hasPhoto = kIsWeb ? _fotoData != null : _fotoPath != null;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle do bottom sheet
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Título
            Text(
              'Alterar Foto do Perfil',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Opções
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.indigo),
              title: const Text('Tirar Foto'),
              subtitle: const Text('Usar a câmera do dispositivo'),
              onTap: () {
                Navigator.pop(context);
                _selecionarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.indigo),
              title: const Text('Escolher da Galeria'),
              subtitle: const Text('Selecionar uma foto existente'),
              onTap: () {
                Navigator.pop(context);
                _selecionarFoto(ImageSource.gallery);
              },
            ),
            if (hasPhoto) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remover Foto',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text('Voltar ao ícone padrão'),
                onTap: () {
                  Navigator.pop(context);
                  _removerFoto();
                },
              ),
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarFoto(ImageSource source) async {
    try {
      // Verificar permissões
      bool hasPermission = await _verificarPermissoes(source);
      if (!hasPermission) {
        _mostrarErroPermissao(source);
        return;
      }

      // Mostrar loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Selecionar imagem
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      // Fechar loading
      if (mounted) {
        Navigator.pop(context);
      }

      if (image != null) {
        if (kIsWeb) {
          // Para web, converter para Uint8List
          final bytes = await image.readAsBytes();
          await _salvarFoto(bytes);
        } else {
          // Para mobile, usar File
          await _salvarFoto(File(image.path));
        }
      }
    } catch (e) {
      // Fechar loading se ainda estiver aberto
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      _mostrarErro('Erro ao selecionar foto: ${e.toString()}');
    }
  }

  Future<bool> _verificarPermissoes(ImageSource source) async {
    // Para web, não precisamos verificar permissões da mesma forma
    if (kIsWeb) {
      return true; // Na web, o navegador gerencia as permissões
    }
    
    if (source == ImageSource.camera) {
      final status = await Permission.camera.status;
      if (status.isDenied) {
        final result = await Permission.camera.request();
        return result.isGranted;
      }
      return status.isGranted;
    } else {
      // Para galeria, verificar permissão de fotos
      if (Platform.isAndroid) {
        final status = await Permission.photos.status;
        if (status.isDenied) {
          final result = await Permission.photos.request();
          return result.isGranted;
        }
        return status.isGranted;
      } else {
        // iOS
        final status = await Permission.photos.status;
        if (status.isDenied) {
          final result = await Permission.photos.request();
          return result.isGranted;
        }
        return status.isGranted;
      }
    }
  }

  void _mostrarErroPermissao(ImageSource source) {
    final String tipo = source == ImageSource.camera ? 'câmera' : 'galeria';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão Necessária'),
        content: Text(
          'O ProvaPlanner precisa de permissão para acessar sua $tipo para tirar/escolher fotos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Configurações'),
          ),
        ],
      ),
    );
  }

  Future<void> _salvarFoto(dynamic imageFile) async {
    try {
      // Mostrar loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Salvar foto usando ProfileRepository
      await ProfileRepository.setPhoto(imageFile);
      
      // Recarregar foto
      await _carregarFoto();

      // Fechar loading
      if (mounted) {
        Navigator.pop(context);
      }

      // Mostrar sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Fechar loading se ainda estiver aberto
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      _mostrarErro('Erro ao salvar foto: ${e.toString()}');
    }
  }

  Future<void> _removerFoto() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Foto'),
        content: const Text(
          'Tem certeza que deseja remover sua foto de perfil? '
          'Você voltará ao ícone padrão.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        // Mostrar loading
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Remover foto usando ProfileRepository
        await ProfileRepository.removePhoto();
        
        // Atualizar estado
        if (mounted) {
          setState(() {
            _fotoPath = null;
            _fotoData = null;
          });
        }

        // Fechar loading
        if (mounted) {
          Navigator.pop(context);
        }

        // Mostrar confirmação
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto removida com sucesso!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        // Fechar loading se ainda estiver aberto
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        
        _mostrarErro('Erro ao remover foto: ${e.toString()}');
      }
    }
  }

  void _mostrarErro(String mensagem) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Tentar Novamente',
            textColor: Colors.white,
            onPressed: () => _mostrarOpcoesFoto(),
          ),
        ),
      );
    }
  }

  Future<void> _limparDados() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Dados'),
        content: const Text(
          'Tem certeza que deseja limpar todos os dados do aplicativo? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        // Limpar dados usando ProfileRepository (inclui foto)
        await ProfileRepository.clearProfileData();
        
        // Limpar outros dados do app
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
        }
      } catch (e) {
        // Fallback para SharedPreferences se ProfileRepository falhar
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            onPressed: _editarPerfil,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar e informações básicas
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Avatar com foto ou fallback para AppIcon
                          Semantics(
                            label: "Foto do perfil",
                            image: true,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppTheme.indigo.withValues(alpha: 0.1),
                                  backgroundImage: _getBackgroundImage(),
                                  child: _getAvatarChild(),
                                ),
                                // Botão de editar foto
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Semantics(
                                    label: "Alterar foto do perfil",
                                    button: true,
                                    child: GestureDetector(
                                      onTap: _mostrarOpcoesFoto,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppTheme.indigo,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _nome,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _email,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Aviso de privacidade
                          Text(
                            'Sua foto fica apenas neste dispositivo. Você pode remover quando quiser.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Configurações
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Notificações'),
                          subtitle: Text(
                            _notificacoesHabilitadas ? 'Habilitadas' : 'Desabilitadas',
                          ),
                          trailing: Switch(
                            value: _notificacoesHabilitadas,
                            onChanged: (value) {
                              setState(() {
                                _notificacoesHabilitadas = value;
                              });
                              _salvarDadosUsuario();
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Editar Perfil'),
                          subtitle: const Text('Alterar nome e email'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _editarPerfil,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.info),
                          title: const Text('Sobre o App'),
                          subtitle: const Text('Versão 1.0.0'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Sobre o ProvaPlanner'),
                                content: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Versão: 1.0.0'),
                                    SizedBox(height: 8),
                                    Text('Desenvolvido em Flutter'),
                                    SizedBox(height: 8),
                                    Text(
                                      'O ProvaPlanner é um aplicativo para organização acadêmica, '
                                      'permitindo que estudantes gerenciem suas provas e criem '
                                      'cronogramas de estudos personalizados.',
                                    ),
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
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Ações perigosas
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.delete_forever, color: Colors.red),
                          title: const Text(
                            'Limpar Dados',
                            style: TextStyle(color: Colors.red),
                          ),
                          subtitle: const Text('Remover todos os dados do aplicativo'),
                          onTap: _limparDados,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _EditarPerfilDialog extends StatefulWidget {
  final String nome;
  final String email;
  final bool notificacoes;

  const _EditarPerfilDialog({
    required this.nome,
    required this.email,
    required this.notificacoes,
  });

  @override
  State<_EditarPerfilDialog> createState() => _EditarPerfilDialogState();
}

class _EditarPerfilDialogState extends State<_EditarPerfilDialog> {
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late bool _notificacoes;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nome);
    _emailController = TextEditingController(text: widget.email);
    _notificacoes = widget.notificacoes;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Perfil'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Notificações'),
            value: _notificacoes,
            onChanged: (value) {
              setState(() {
                _notificacoes = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'nome': _nomeController.text.trim(),
              'email': _emailController.text.trim(),
              'notificacoes': _notificacoes,
            });
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
