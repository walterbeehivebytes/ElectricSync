import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'home/project_manager_home.dart';
import 'home/site_manager_home.dart';
import 'home/team_lead_home.dart';
import 'home/team_member_home.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;

  const HomeScreen({super.key, required this.authService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Widget _getRoleBasedHome() {
    final role = widget.authService.currentUser!.role;
    switch (role) {
      case UserRole.projectManager:
        return const ProjectManagerHome();
      case UserRole.siteManager:
        return const SiteManagerHome();
      case UserRole.teamLead:
        return const TeamLeadHome();
      case UserRole.teamMember:
        return const TeamMemberHome();
    }
  }

  String _getRoleTitle() {
    final role = widget.authService.currentUser!.role;
    switch (role) {
      case UserRole.projectManager:
        return 'Portfolio Dashboard';
      case UserRole.siteManager:
        return 'Site Operations';
      case UserRole.teamLead:
        return 'Crew Status Overview';
      case UserRole.teamMember:
        return 'My Workspace';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_getRoleTitle()),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
              ),
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => ProfileScreen(authService: widget.authService),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeOutCubic;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                ),
              );
            },
            tooltip: 'Profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _getRoleBasedHome().animate().fade(duration: 400.ms).slideY(begin: 0.05, curve: Curves.easeOut),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              activeIcon: Icon(Icons.check_circle_rounded),
              label: 'Tasks',
            ),
          ],
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
