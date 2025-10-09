import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icon.dart';

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

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _nome = prefs.getString('nome_usuario') ?? 'Usuário';
      _email = prefs.getString('email_usuario') ?? 'usuario@exemplo.com';
      _notificacoesHabilitadas = prefs.getBool('notifications_enabled') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _salvarDadosUsuario() async {
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
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
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.indigo.withOpacity(0.1),
                            child: const AppIcon(size: 60),
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
