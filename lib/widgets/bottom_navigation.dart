import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
