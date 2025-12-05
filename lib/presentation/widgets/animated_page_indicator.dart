import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Widget paramétrico para indicadores de página animados
class AnimatedPageIndicator extends StatefulWidget {
  final int currentPage;
  final int pageCount;
  final Color activeColor;
  final Color? inactiveColor;
  final double activeWidth;
  final double inactiveWidth;
  final double height;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedPageIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
    this.activeColor = AppTheme.indigo,
    this.inactiveColor,
    this.activeWidth = 24.0,
    this.inactiveWidth = 8.0,
    this.height = 8.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<AnimatedPageIndicator> createState() => _AnimatedPageIndicatorState();
}

class _AnimatedPageIndicatorState extends State<AnimatedPageIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _widthAnimations;
  late List<Animation<Color?>> _colorAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _widthAnimations = List.generate(
      widget.pageCount,
      (index) => Tween<double>(
        begin: widget.inactiveWidth,
        end: widget.currentPage == index ? widget.activeWidth : widget.inactiveWidth,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: widget.animationCurve,
        ),
      ),
    );

    final inactiveColor = widget.inactiveColor ??
        widget.activeColor.withValues(alpha: 0.3);

    _colorAnimations = List.generate(
      widget.pageCount,
      (index) => ColorTween(
        begin: inactiveColor,
        end: widget.currentPage == index ? widget.activeColor : inactiveColor,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: widget.animationCurve,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedPageIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage ||
        oldWidget.pageCount != widget.pageCount) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    _widthAnimations = List.generate(
      widget.pageCount,
      (index) => Tween<double>(
        begin: widget.currentPage == index
            ? widget.inactiveWidth
            : widget.activeWidth,
        end: widget.currentPage == index ? widget.activeWidth : widget.inactiveWidth,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: widget.animationCurve,
        ),
      ),
    );

    final inactiveColor = widget.inactiveColor ??
        widget.activeColor.withValues(alpha: 0.3);

    _colorAnimations = List.generate(
      widget.pageCount,
      (index) => ColorTween(
        begin: widget.currentPage == index
            ? widget.activeColor
            : inactiveColor,
        end: widget.currentPage == index ? widget.activeColor : inactiveColor,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: widget.animationCurve,
        ),
      ),
    );

    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.pageCount,
        (index) => AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _widthAnimations[index].value,
              height: widget.height,
              decoration: BoxDecoration(
                color: _colorAnimations[index].value,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
            );
          },
        ),
      ),
    );
  }
}

