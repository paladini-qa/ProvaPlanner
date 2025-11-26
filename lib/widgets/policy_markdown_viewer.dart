import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../theme/app_theme.dart';

/// Widget para visualizar políticas em Markdown com barra de progresso
class PolicyMarkdownViewer extends StatefulWidget {
  final String assetPath;
  final VoidCallback? onReadComplete;
  final bool showProgressBar;
  final bool showMarkAsReadButton;

  const PolicyMarkdownViewer({
    super.key,
    required this.assetPath,
    this.onReadComplete,
    this.showProgressBar = true,
    this.showMarkAsReadButton = true,
  });

  @override
  State<PolicyMarkdownViewer> createState() => _PolicyMarkdownViewerState();
}

class _PolicyMarkdownViewerState extends State<PolicyMarkdownViewer> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  bool _hasScrolledToEnd = false;
  bool _markedAsRead = false;
  bool _hasInitializedScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
    // Aguardar um frame após o build para garantir que o scroll esteja pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _updateScrollProgress();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollProgress() {
    if (!_scrollController.hasClients) return;

    try {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      
      if (maxScroll > 0) {
        final progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
        
        // Considerar que chegou ao final se estiver a 50px do final
        final threshold = maxScroll - 50;
        final hasScrolledToEnd = currentScroll >= threshold;
        
        // Só atualizar o estado se houver mudança significativa
        if ((_scrollProgress - progress).abs() > 0.01 || _hasScrolledToEnd != hasScrolledToEnd) {
          setState(() {
            _scrollProgress = progress;
            _hasScrolledToEnd = hasScrolledToEnd;
          });
        }
      } else {
        // Se maxScroll for 0, pode ser que o conteúdo ainda não tenha sido renderizado
        // Aguardar um pouco e tentar novamente
        Future<void>.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _scrollController.hasClients) {
            _updateScrollProgress();
          }
        });
      }
    } catch (e) {
      // Ignorar erros de scroll durante rebuilds
    }
  }

  void _markAsRead() {
    if (_hasScrolledToEnd && !_markedAsRead) {
      setState(() {
        _markedAsRead = true;
      });
      widget.onReadComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de progresso
        if (widget.showProgressBar)
          Container(
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.indigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _scrollProgress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.indigo,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

        // Conteúdo Markdown
        Expanded(
          child: FutureBuilder<String>(
            future: _loadMarkdown(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar política',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final markdown = snapshot.data ?? '';

              return LayoutBuilder(
                builder: (context, constraints) {
                  // Aguardar um frame após o layout ser calculado (apenas uma vez)
                  if (!_hasInitializedScroll && markdown.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _scrollController.hasClients && !_hasInitializedScroll) {
                        setState(() {
                          _hasInitializedScroll = true;
                        });
                        _updateScrollProgress();
                      }
                    });
                  }

                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: MarkdownBody(
                      key: ValueKey(markdown.length),
                      data: markdown,
                      styleSheet: MarkdownStyleSheet(
                    h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                    h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                    h3: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.slate,
                          fontWeight: FontWeight.bold,
                        ),
                    p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.slateLight,
                          height: 1.5,
                        ),
                    listBullet: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.indigo,
                        ),
                    strong: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate,
                    ),
                    code: TextStyle(
                      backgroundColor: AppTheme.indigo.withValues(alpha: 0.1),
                      color: AppTheme.indigo,
                      fontFamily: 'monospace',
                    ),
                      codeblockDecoration: BoxDecoration(
                        color: AppTheme.indigo.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );
                },
              );
            },
          ),
        ),

        // Botão "Marcar como lido"
        if (widget.showMarkAsReadButton)
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (!_hasScrolledToEnd)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Por favor, role até o final para marcar como lido',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange[700],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _hasScrolledToEnd && !_markedAsRead
                        ? _markAsRead
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasScrolledToEnd && !_markedAsRead
                          ? AppTheme.indigo
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _markedAsRead
                          ? '✓ Marcado como lido'
                          : 'Marcar como lido',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<String> _loadMarkdown() async {
    try {
      return await rootBundle.loadString(widget.assetPath);
    } catch (e) {
      throw Exception('Erro ao carregar arquivo: $e');
    }
  }
}

