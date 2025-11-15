import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int? highlightIndex;
  final GlobalKey? disciplinasKey;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.highlightIndex,
    this.disciplinasKey,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.indigo,
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
      items: [
        BottomNavigationBarItem(
          icon: _buildIcon(Icons.home, 0),
          activeIcon: _buildIcon(Icons.home, 0, isActive: true),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(Icons.school, 1, key: disciplinasKey),
          activeIcon: _buildIcon(Icons.school, 1, isActive: true, key: disciplinasKey),
          label: 'Disciplinas',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(Icons.flag, 2),
          activeIcon: _buildIcon(Icons.flag, 2, isActive: true),
          label: 'Metas',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(Icons.person, 3),
          activeIcon: _buildIcon(Icons.person, 3, isActive: true),
          label: 'Perfil',
        ),
      ],
    );
  }

  Widget _buildIcon(IconData icon, int index, {bool isActive = false, Key? key}) {
    final isHighlighted = highlightIndex == index;
    
    Widget iconWidget = Icon(icon);
    
    if (isHighlighted && !isActive) {
      iconWidget = Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.indigo.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.indigo,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: AppTheme.indigo,
        ),
      );
    }
    
    if (key != null) {
      return KeyedSubtree(
        key: key,
        child: iconWidget,
      );
    }
    
    return iconWidget;
  }
}
