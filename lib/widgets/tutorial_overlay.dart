import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'tutorial_arrow.dart';

class TutorialOverlay extends StatefulWidget {
  final String message;
  final String? title;
  final GlobalKey targetKey;
  final ArrowPosition arrowPosition;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final bool showSkip;

  const TutorialOverlay({
    super.key,
    required this.message,
    this.title,
    required this.targetKey,
    this.arrowPosition = ArrowPosition.bottom,
    this.onNext,
    this.onSkip,
    this.showSkip = true,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    _controller.forward();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Overlay escuro com fade
        FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: widget.onNext,
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ),
        // Conteúdo do tutorial
        _buildTutorialContent(context),
      ],
    );
  }

  Widget _buildTutorialContent(BuildContext context) {
    return Stack(
      children: [
        // CustomPaint para desenhar o highlight
        Positioned.fill(
          child: CustomPaint(
            painter: TutorialPainter(
              targetKey: widget.targetKey,
              arrowPosition: widget.arrowPosition,
            ),
          ),
        ),
        // Card de mensagem
        _buildMessageCard(context),
      ],
    );
  }

  Widget _buildMessageCard(BuildContext context) {
    final RenderBox? targetBox = widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final targetPosition = targetBox.localToGlobal(Offset.zero);
    final targetSize = targetBox.size;

    // Calcular posição do card de mensagem
    late Offset cardPosition;

    // Determinar melhor posição para o card
    final spaceTop = targetPosition.dy;
    final spaceBottom = screenSize.height - (targetPosition.dy + targetSize.height);
    final spaceRight = screenSize.width - (targetPosition.dx + targetSize.width);

    if (spaceBottom > 150 && widget.arrowPosition == ArrowPosition.bottom) {
      // Card abaixo do alvo
      cardPosition = Offset(
        targetPosition.dx + (targetSize.width / 2) - 150,
        targetPosition.dy + targetSize.height + 20,
      );
    } else if (spaceTop > 150 && widget.arrowPosition == ArrowPosition.top) {
      // Card acima do alvo
      cardPosition = Offset(
        targetPosition.dx + (targetSize.width / 2) - 150,
        targetPosition.dy - 180,
      );
    } else if (spaceRight > 200) {
      // Card à direita
      cardPosition = Offset(
        targetPosition.dx + targetSize.width + 20,
        targetPosition.dy + (targetSize.height / 2) - 80,
      );
    } else {
      // Card à esquerda
      cardPosition = Offset(
        targetPosition.dx - 320,
        targetPosition.dy + (targetSize.height / 2) - 80,
      );
    }

    // Garantir que o card não saia da tela
    cardPosition = Offset(
      cardPosition.dx.clamp(16.0, screenSize.width - 316.0),
      cardPosition.dy.clamp(16.0, screenSize.height - 200.0),
    );

    return Positioned(
      left: cardPosition.dx,
      top: cardPosition.dy,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.indigo.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: AppTheme.indigo.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícone animado
                Row(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.indigo.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lightbulb,
                          color: AppTheme.indigo,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (widget.title != null)
                      Expanded(
                        child: Text(
                          widget.title!,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.indigo,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.showSkip)
                      TextButton(
                        onPressed: widget.onSkip,
                        child: const Text('Pular Tutorial'),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.indigo,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Entendi!',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TutorialPainter extends CustomPainter {
  final GlobalKey targetKey;
  final ArrowPosition arrowPosition;

  TutorialPainter({
    required this.targetKey,
    required this.arrowPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox? targetBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null) return;

    final targetPosition = targetBox.localToGlobal(Offset.zero);
    final targetSize = targetBox.size;

    // Desenhar highlight no alvo com efeito de brilho
    final paint = Paint()
      ..color = AppTheme.indigo.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        targetPosition.dx - 4,
        targetPosition.dy - 4,
        targetSize.width + 8,
        targetSize.height + 8,
      ),
      const Radius.circular(12),
    );

    canvas.drawRRect(rect, paint);

    // Desenhar borda brilhante animada
    final borderPaint = Paint()
      ..color = AppTheme.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawRRect(rect, borderPaint);

    // Desenhar seta apontando para o alvo
    _drawArrow(canvas, targetPosition, targetSize);
  }

  void _drawArrow(Canvas canvas, Offset targetPosition, Size targetSize) {
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    late Offset arrowPosition;
    late Path arrowPath;

    switch (this.arrowPosition) {
      case ArrowPosition.top:
        arrowPosition = Offset(
          targetPosition.dx + targetSize.width / 2,
          targetPosition.dy - 30,
        );
        arrowPath = Path()
          ..moveTo(arrowPosition.dx, arrowPosition.dy)
          ..lineTo(arrowPosition.dx - 15, arrowPosition.dy - 20)
          ..lineTo(arrowPosition.dx + 15, arrowPosition.dy - 20)
          ..close();
        break;
      case ArrowPosition.bottom:
        arrowPosition = Offset(
          targetPosition.dx + targetSize.width / 2,
          targetPosition.dy + targetSize.height + 30,
        );
        arrowPath = Path()
          ..moveTo(arrowPosition.dx, arrowPosition.dy)
          ..lineTo(arrowPosition.dx - 15, arrowPosition.dy + 20)
          ..lineTo(arrowPosition.dx + 15, arrowPosition.dy + 20)
          ..close();
        break;
      case ArrowPosition.left:
        arrowPosition = Offset(
          targetPosition.dx - 30,
          targetPosition.dy + targetSize.height / 2,
        );
        arrowPath = Path()
          ..moveTo(arrowPosition.dx, arrowPosition.dy)
          ..lineTo(arrowPosition.dx - 20, arrowPosition.dy - 15)
          ..lineTo(arrowPosition.dx - 20, arrowPosition.dy + 15)
          ..close();
        break;
      case ArrowPosition.right:
        arrowPosition = Offset(
          targetPosition.dx + targetSize.width + 30,
          targetPosition.dy + targetSize.height / 2,
        );
        arrowPath = Path()
          ..moveTo(arrowPosition.dx, arrowPosition.dy)
          ..lineTo(arrowPosition.dx + 20, arrowPosition.dy - 15)
          ..lineTo(arrowPosition.dx + 20, arrowPosition.dy + 15)
          ..close();
        break;
    }

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
