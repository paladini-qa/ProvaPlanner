import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/consent_service.dart';
import '../widgets/policy_markdown_viewer.dart';

class PoliciesScreen extends StatefulWidget {
  const PoliciesScreen({super.key});

  @override
  State<PoliciesScreen> createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends State<PoliciesScreen> {
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  bool _acceptedDataProcessing = false;
  bool _acceptedNotifications = false;
  bool _termsRead = false;
  bool _privacyRead = false;
  bool _lgpdRead = false;

  bool get _canProceed => 
      _acceptedTerms && _acceptedPrivacy && _acceptedDataProcessing;

  @override
  void initState() {
    super.initState();
    _checkPolicyVersion();
  }

  Future<void> _checkPolicyVersion() async {
    final needsAcceptance = await ConsentService.needsPolicyAcceptance();
    if (needsAcceptance && mounted) {
      // Mostrar aviso se a versão mudou
      final acceptedVersion = await ConsentService.getAcceptedVersion();
      if (acceptedVersion != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'As políticas foram atualizadas. Por favor, revise e aceite novamente.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _acceptPolicies() async {
    if (!_canProceed) return;

    await ConsentService.acceptPolicies(
      acceptedTerms: _acceptedTerms,
      acceptedPrivacy: _acceptedPrivacy,
      acceptedDataProcessing: _acceptedDataProcessing,
      acceptedNotifications: _acceptedNotifications,
    );
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Políticas e Consentimento'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.slate,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
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
                      Icons.security,
                      size: 40,
                      color: AppTheme.indigo,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Proteção de Dados',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.slate,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sua privacidade é importante para nós',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.slateLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Política de Privacidade
            _buildPolicySection(
              title: 'Política de Privacidade',
              content: '''
O ProvaPlanner coleta e processa seus dados pessoais de forma transparente e segura:

• Dados de provas e estudos (nome, data, disciplina)
• Preferências de notificação
• Dados de uso para melhorar o aplicativo

Seus dados são armazenados localmente no seu dispositivo e não são compartilhados com terceiros sem seu consentimento explícito.
              ''',
            ),
            
            const SizedBox(height: 24),
            
            // Termos de Uso
            _buildPolicySection(
              title: 'Termos de Uso',
              content: '''
Ao usar o ProvaPlanner, você concorda com:

• Uso responsável do aplicativo
• Não compartilhamento de conteúdo inadequado
• Respeito aos direitos de propriedade intelectual
• Manutenção da segurança da sua conta

O aplicativo é fornecido "como está" e nos reservamos o direito de atualizar estes termos.
              ''',
            ),
            
            const SizedBox(height: 24),
            
            // Processamento de Dados
            _buildPolicySection(
              title: 'Processamento de Dados (LGPD)',
              content: '''
Conforme a Lei Geral de Proteção de Dados (LGPD):

• Base legal: Consentimento e execução de contrato
• Finalidade: Fornecimento do serviço de organização acadêmica
• Retenção: Dados mantidos enquanto necessário para o serviço
• Seus direitos: Acesso, correção, exclusão e portabilidade

Você pode exercer seus direitos entrando em contato conosco.
              ''',
            ),
            
            const SizedBox(height: 32),
            
            // Checkboxes de consentimento
            _buildConsentCheckbox(
              value: _acceptedTerms,
              onChanged: (value) => setState(() => _acceptedTerms = value!),
              title: 'Aceito os Termos de Uso',
              subtitle: 'Concordo com as condições de uso do aplicativo',
            ),
            
            const SizedBox(height: 16),
            
            _buildConsentCheckbox(
              value: _acceptedPrivacy,
              onChanged: (value) => setState(() => _acceptedPrivacy = value!),
              title: 'Aceito a Política de Privacidade',
              subtitle: 'Concordo com o processamento dos meus dados pessoais',
            ),
            
            const SizedBox(height: 16),
            
            _buildConsentCheckbox(
              value: _acceptedDataProcessing,
              onChanged: (value) => setState(() => _acceptedDataProcessing = value!),
              title: 'Consentimento LGPD',
              subtitle: 'Autorizo o processamento de dados conforme a LGPD',
            ),
            
            const SizedBox(height: 16),
            
            _buildConsentCheckbox(
              value: _acceptedNotifications,
              onChanged: (value) => setState(() => _acceptedNotifications = value!),
              title: 'Notificações (Opcional)',
              subtitle: 'Receber lembretes sobre provas e revisões',
            ),
            
            const SizedBox(height: 32),
            
            // Botão de aceitar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canProceed ? _acceptPolicies : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canProceed ? AppTheme.indigo : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Aceitar e Continuar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Links para políticas completas
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => _showPolicyDialog(
                    'Termos de Uso',
                    'assets/policies/terms_of_service.md',
                    () => setState(() => _termsRead = true),
                  ),
                  child: const Text(
                    'Ver Termos Completos',
                    style: TextStyle(
                      color: AppTheme.indigo,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _showPolicyDialog(
                    'Política de Privacidade',
                    'assets/policies/privacy_policy.md',
                    () => setState(() => _privacyRead = true),
                  ),
                  child: const Text(
                    'Ver Privacidade Completa',
                    style: TextStyle(
                      color: AppTheme.indigo,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _showPolicyDialog(
                    'Política LGPD',
                    'assets/policies/lgpd_policy.md',
                    () => setState(() => _lgpdRead = true),
                  ),
                  child: const Text(
                    'Ver LGPD Completa',
                    style: TextStyle(
                      color: AppTheme.indigo,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Informação sobre versão
            FutureBuilder<String?>(
              future: ConsentService.getAcceptedVersion(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Center(
                    child: Text(
                      'Versão aceita anteriormente: ${snapshot.data}\nVersão atual: ${ConsentService.currentPolicyVersion}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.slateLight,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection({
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.indigo.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.indigo.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.indigo,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.trim(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.slateLight,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    required String subtitle,
  }) {
    return Semantics(
      checked: value,
      label: '$title. $subtitle',
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppTheme.slate,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.slateLight,
          ),
        ),
        activeColor: AppTheme.indigo,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  void _showPolicyDialog(String title, String assetPath, VoidCallback onReadComplete) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 700,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.indigo,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: PolicyMarkdownViewer(
                    assetPath: assetPath,
                    showProgressBar: false,
                    onReadComplete: () {
                      onReadComplete();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$title marcado como lido'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.indigo,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Fechar'),
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
