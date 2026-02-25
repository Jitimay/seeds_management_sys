import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _getSelectedIndex(String location) {
    if (location.startsWith('/stocks')) {
      return 1;
    } else if (location.startsWith('/orders')) {
      return 2;
    } else if (location.startsWith('/profile')) {
      return 3;
    }
    return 0; // Default to Home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/stocks');
        break;
      case 2:
        context.go('/orders');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String location =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    final int selectedIndex = _getSelectedIndex(location);

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: _buildBottomNavigationBar(selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(int selectedIndex) {
    return Container(
      height: 60, // Diminished from 70
      decoration: BoxDecoration(
        color: Colors.green[900]?.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_rounded, 'Accueil', selectedIndex),
            _buildNavItem(
                1, Icons.inventory_2_rounded, 'Stocks', selectedIndex),
            _buildNavItem(
                2, Icons.shopping_basket_rounded, 'Commandes', selectedIndex),
            _buildNavItem(3, Icons.person_rounded, 'Profil', selectedIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, String label, int selectedIndex) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 12 : 10, vertical: 6), // Reduced padding
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: isSelected ? 22 : 20, // Reduced icon sizes
            ),
            if (isSelected) ...[
              const SizedBox(width: 4), // Reduced spacing
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Reduced font size
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
