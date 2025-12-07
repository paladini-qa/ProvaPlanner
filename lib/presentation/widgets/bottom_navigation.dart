import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
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
          icon: _buildIcon(Icons.school, 1),
          activeIcon: _buildIcon(Icons.school, 1, isActive: true),
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

  Widget _buildIcon(IconData icon, int index, {bool isActive = false}) {
    return Icon(icon);
  }
}
