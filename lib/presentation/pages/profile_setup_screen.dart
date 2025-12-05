import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_icon.dart';
import '../services/profile_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  String? _fotoPath;
  Uint8List? _fotoData; // Para web
  bool _hasPhoto = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosExistentes();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosExistentes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nome = prefs.getString('nome_usuario');
      final email = prefs.getString('email_usuario');
      
      if (nome != null) _nomeController.text = nome;
      if (email != null) _emailController.text = email;
    } catch (e) {
      // Ignorar erros ao carregar dados existentes
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
    if (!_hasPhoto) {
      return const AppIcon(size: 60);
    }
    return null;
  }

  Future<void> _mostrarOpcoesFoto() async {
    showModalBottomSheet<void>(
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
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            
            // Título
            Text(
              'Escolher Foto do Perfil',
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
            if (_hasPhoto) ...[
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
      final bool hasPermission = await _verificarPermissoes(source);
      if (!hasPermission) {
        _mostrarErroPermissao(source);
        return;
      }

      // Mostrar loading
      setState(() {
        _isLoading = true;
      });

      // Selecionar imagem
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (image != null) {
        if (kIsWeb) {
          // Para web, converter para Uint8List
          final bytes = await image.readAsBytes();
          setState(() {
            _fotoData = bytes;
            _hasPhoto = true;
            _isLoading = false;
          });
        } else {
          // Para mobile, usar File
          setState(() {
            _fotoPath = image.path;
            _hasPhoto = true;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
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
    
    showDialog<void>(
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

  void _removerFoto() {
    setState(() {
      _fotoPath = null;
      _fotoData = null;
      _hasPhoto = false;
    });
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _salvarPerfil() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Salvar dados básicos
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nome_usuario', _nomeController.text.trim());
      await prefs.setString('email_usuario', _emailController.text.trim());
      await prefs.setBool('profile_setup_completed', true);

      // Salvar foto se houver
      if (_hasPhoto) {
        try {
          if (kIsWeb && _fotoData != null) {
            await ProfileService.setPhoto(_fotoData);
          } else if (!kIsWeb && _fotoPath != null) {
            await ProfileService.setPhoto(File(_fotoPath!));
          }
        } catch (e) {
          // Se falhar ao salvar foto, continuar sem ela
        }
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      _mostrarErro('Erro ao salvar perfil: ${e.toString()}');
    }
  }

  void _pularConfiguracao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profile_setup_completed', true);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Configurar Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.slate,
        actions: [
          TextButton(
            onPressed: _pularConfiguracao,
            child: const Text(
              'Pular',
              style: TextStyle(
                color: AppTheme.slateLight,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.indigo.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                            child: const Icon(
                              Icons.person_add,
                              size: 40,
                              color: AppTheme.indigo,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Configure seu Perfil',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.slate,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Personalize sua experiência no ProvaPlanner',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.slateLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Avatar
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppTheme.indigo.withValues(alpha: 0.1),
                            backgroundImage: _getBackgroundImage(),
                            child: _getAvatarChild(),
                          ),
                          // Botão de editar foto
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _mostrarOpcoesFoto,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.indigo,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Campo Nome
                    Text(
                      'Nome',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.slate,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        hintText: 'Digite seu nome completo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, digite seu nome';
                        }
                        if (value.trim().length < 2) {
                          return 'Nome deve ter pelo menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Campo Email
                    Text(
                      'Email',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.slate,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Digite seu email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, digite seu email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                          return 'Por favor, digite um email válido';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Aviso sobre privacidade
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.indigo.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        border: Border.all(
                          color: AppTheme.indigo.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppTheme.indigo,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Seus dados ficam apenas neste dispositivo. Você pode alterar essas informações a qualquer momento nas configurações.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.slateLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Botão Salvar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _salvarPerfil,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Salvar e Continuar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Botão Pular
                    Center(
                      child: TextButton(
                        onPressed: _pularConfiguracao,
                        child: const Text(
                          'Pular por enquanto',
                          style: TextStyle(
                            color: AppTheme.slateLight,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

