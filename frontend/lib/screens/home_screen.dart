import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'home/project_manager_home.dart';
import 'home/site_manager_home.dart';
import 'home/team_lead_home.dart';
import 'home/team_member_home.dart';
import 'profile/profile_screen.dart';
import 'tasks/work_order_creator.dart';
import 'tasks/crew_dispatch.dart';
import 'tasks/qc_signoff.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;
  const HomeScreen({super.key, required this.authService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // ── Role helpers ──────────────────────────────────────────────────────────

  UserRole get _role => widget.authService.currentUser!.role;

  Color get _roleColor => switch (_role) {
    UserRole.projectManager => AppColors.pm,
    UserRole.siteManager    => AppColors.sm,
    UserRole.teamLead       => AppColors.tl,
    UserRole.teamMember     => AppColors.tm,
  };

  String get _roleLabel => switch (_role) {
    UserRole.projectManager => 'PM',
    UserRole.siteManager    => 'SM',
    UserRole.teamLead       => 'TL',
    UserRole.teamMember     => 'TM',
  };

  String get _roleTitle => switch (_role) {
    UserRole.projectManager => 'Portfolio',
    UserRole.siteManager    => 'Site Ops',
    UserRole.teamLead       => 'Crew Status',
    UserRole.teamMember     => 'My Workspace',
  };

  Widget _buildHome() => switch (_role) {
    UserRole.projectManager => const ProjectManagerHome(),
    UserRole.siteManager    => SiteManagerHome(currentUser: widget.authService.currentUser!),
    UserRole.teamLead       => TeamLeadHome(currentUser: widget.authService.currentUser!),
    UserRole.teamMember     => const TeamMemberHome(),
  };

  // ── Navigation ────────────────────────────────────────────────────────────

  void _onTabTapped(int index) {
    if (index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Messages coming soon', style: AppText.body(14)), duration: const Duration(seconds: 1)),
      );
      return;
    }
    if (index == 2) {
      Widget? screen = switch (_role) {
        UserRole.projectManager => const WorkOrderCreator(),
        UserRole.siteManager    => const CrewDispatch(),
        UserRole.teamLead       => QCSignoff(currentUser: widget.authService.currentUser!),
        UserRole.teamMember     => null,
      };
      if (screen != null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      }
      return;
    }
    setState(() => _currentIndex = index);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildHome()
          .animate()
          .fade(duration: 350.ms)
          .slideY(begin: 0.04, curve: Curves.easeOut),
      bottomNavigationBar: _buildFloatingNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 18,
      title: Row(
        children: [
          RoleBadge(_roleLabel, color: _roleColor),
          const SizedBox(width: 10),
          Text(_roleTitle, style: AppText.body(16, weight: FontWeight.w600)),
        ],
      ),
      actions: [
        // Notification bell
        Stack(
          clipBehavior: Clip.none,
          children: [
            AppIconButton(Icons.notifications_outlined, onPressed: () {}),
            Positioned(
              right: 6, top: 6,
              child: Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  color: _roleColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        AppIconButton(
          Icons.person_outline,
          onPressed: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, a, __) => ProfileScreen(authService: widget.authService),
              transitionsBuilder: (_, a, __, child) {
                return SlideTransition(
                  position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic))
                      .animate(a),
                  child: child,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildFloatingNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _navItem(0, Icons.dashboard_outlined,    Icons.dashboard_rounded,    'DASH'),
            _navItem(1, Icons.chat_bubble_outline,   Icons.chat_bubble_rounded,  'MSGS'),
            _navItem(2, Icons.check_circle_outline,  Icons.check_circle_rounded, _taskTabLabel()),
          ],
        ),
      ),
    );
  }

  String _taskTabLabel() => switch (_role) {
    UserRole.projectManager => 'CREATE',
    UserRole.siteManager    => 'DISPATCH',
    UserRole.teamLead       => 'QC',
    UserRole.teamMember     => 'TASKS',
  };

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isActive ? _roleColor.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 20,
                color: isActive ? _roleColor : AppColors.textMuted,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppText.display(8,
                  color: isActive ? _roleColor : AppColors.textMuted,
                  weight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
