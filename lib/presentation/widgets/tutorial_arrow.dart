import 'package:flutter/material.dart';

enum ArrowPosition {
  top,
  bottom,
  left,
  right,
}

class TutorialArrow extends StatefulWidget {
  final ArrowPosition position;
  final Color color;
  final double size;

  const TutorialArrow({
    super.key,
    this.position = ArrowPosition.bottom,
    this.color = Colors.white,
    this.size = 40,
  });

  @override
  State<TutorialArrow> createState() => _TutorialArrowState();
}

class _TutorialArrowState extends State<TutorialArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    final offset = _getOffsetForPosition();
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: offset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  Offset _getOffsetForPosition() {
    switch (widget.position) {
      case ArrowPosition.top:
        return const Offset(0, -10);
      case ArrowPosition.bottom:
        return const Offset(0, 10);
      case ArrowPosition.left:
        return const Offset(-10, 0);
      case ArrowPosition.right:
        return const Offset(10, 0);
    }
  }

  IconData _getIconForPosition() {
    switch (widget.position) {
      case ArrowPosition.top:
        return Icons.keyboard_arrow_up;
      case ArrowPosition.bottom:
        return Icons.keyboard_arrow_down;
      case ArrowPosition.left:
        return Icons.keyboard_arrow_left;
      case ArrowPosition.right:
        return Icons.keyboard_arrow_right;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Icon(
        _getIconForPosition(),
        color: widget.color,
        size: widget.size,
      ),
    );
  }
}

