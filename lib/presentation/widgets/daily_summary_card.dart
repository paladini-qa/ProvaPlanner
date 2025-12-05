import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DailySummaryCard extends StatelessWidget {
  final String resumo;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const DailySummaryCard({
    super.key,
    required this.resumo,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Gerando resumo do dia...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final partes = resumo.split('\n\n');
    String titulo = '';
    String conteudo = resumo;

    if (partes.isNotEmpty && partes[0].startsWith('Título:')) {
      titulo = partes[0].replaceAll('Título:', '').trim();
      conteudo = partes.skip(1).join('\n\n').trim();
    } else if (partes.isNotEmpty) {
      titulo = partes[0];
      conteudo = partes.skip(1).join('\n\n').trim();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: AppTheme.indigo.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.indigo,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo.isNotEmpty ? titulo : 'Resumo do Dia',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRefresh,
                    tooltip: 'Atualizar resumo',
                    color: AppTheme.indigo,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              conteudo,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: AppTheme.slate,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

