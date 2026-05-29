import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/breakpoints.dart';
import '../providers/auth_provider.dart';
import '../presentation/auth/splash_screen.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/register_screen.dart';
import '../presentation/auth/forgot_password_screen.dart';
import '../presentation/dashboard/dashboard_screen.dart';
import '../presentation/transactions/transactions_screen.dart';
import '../presentation/analytics/analytics_screen.dart';
import '../presentation/categories/categories_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/settings/profile_screen.dart';
import '../presentation/dashboard/notifications_screen.dart';
import '../presentation/transactions/add_edit_transaction_sheet.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuth = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot-password') ||
          state.matchedLocation == '/splash';

      if (state.matchedLocation == '/splash') return null;
      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      // Shell with adaptive nav
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (_, __) => const TransactionsScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (_, __) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/categories',
            builder: (_, __) => const CategoriesScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

// ── Adaptive Shell ─────────────────────────────────────────────────────────

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return _WebShell(location: location, child: child);
    }
    return _MobileShell(location: location, child: child);
  }
}

// ── Desktop Shell ──────────────────────────────────────────────────────────

class _WebShell extends ConsumerWidget {
  const _WebShell({required this.child, required this.location});
  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: Row(
        children: [
          _SideNav(location: location),
          Container(width: 1, color: context.colors.divider),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SideNav extends ConsumerWidget {
  const _SideNav({required this.location});
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 240,
      height: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: context.colors.balanceCardGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'FinTrack',
                  style: context.textStyles.heading.copyWith(fontSize: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'MENU',
              style: context.textStyles.label.copyWith(
                color: context.colors.textMuted,
                letterSpacing: 1.2,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _SideNavItem(
            icon: Icons.home_rounded,
            label: 'Dashboard',
            isActive: location == '/',
            onTap: () => context.go('/'),
          ),
          _SideNavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Analytics',
            isActive: location.startsWith('/analytics'),
            onTap: () => context.go('/analytics'),
          ),
          _SideNavItem(
            icon: Icons.receipt_long_rounded,
            label: 'Transactions',
            isActive: location.startsWith('/transactions'),
            onTap: () => context.go('/transactions'),
          ),
          _SideNavItem(
            icon: Icons.category_rounded,
            label: 'Categories',
            isActive: location.startsWith('/categories'),
            onTap: () => context.go('/categories'),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(height: 1, color: context.colors.divider),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'ACCOUNT',
              style: context.textStyles.label.copyWith(
                color: context.colors.textMuted,
                letterSpacing: 1.2,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _SideNavItem(
            icon: Icons.person_outline_rounded,
            label: 'Settings',
            isActive: location.startsWith('/settings'),
            onTap: () => context.go('/settings'),
          ),
          const Spacer(),
          // Add transaction button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: context.colors.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    child: const SizedBox(
                      width: 500,
                      child: AddEditTransactionSheet(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
              label: const Text('Add Transaction',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                minimumSize: const Size(double.infinity, 46),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive
              ? context.colors.primary.withAlpha(18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? context.colors.primary
                      : context.colors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: isActive
                        ? context.colors.primary
                        : context.colors.textSecondary,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mobile Shell ───────────────────────────────────────────────────────────

class _MobileShell extends StatelessWidget {
  const _MobileShell({required this.child, required this.location});
  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(40, 0, 40, 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.colors.surfaceGlass,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                      color: context.colors.divider.withAlpha(80), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      isActive: location == '/',
                      onTap: () => context.go('/'),
                    ),
                    _NavItem(
                      icon: Icons.pie_chart_rounded,
                      isActive: location.startsWith('/analytics'),
                      onTap: () => context.go('/analytics'),
                    ),
                    const _FloatingAddButton(),
                    _NavItem(
                      icon: Icons.receipt_long_rounded,
                      isActive: location.startsWith('/transactions'),
                      onTap: () => context.go('/transactions'),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      isActive: location.startsWith('/settings'),
                      onTap: () => context.go('/settings'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? context.colors.primary.withAlpha(20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 26,
          color: isActive
              ? context.colors.primary
              : context.colors.textMuted.withAlpha(120),
        ),
      ),
    );
  }
}

class _FloatingAddButton extends StatefulWidget {
  const _FloatingAddButton();

  @override
  State<_FloatingAddButton> createState() => _FloatingAddButtonState();
}

class _FloatingAddButtonState extends State<_FloatingAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: context.colors.surface,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          builder: (ctx) => const _ChooseMethodSheet(),
        );
      },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: context.colors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withAlpha(80),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

// ── Choose Method Sheet ────────────────────────────────────────────────────

class _ChooseMethodSheet extends StatelessWidget {
  const _ChooseMethodSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Choose Method',
              style: context.textStyles.heading.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 20),
            _MethodRow(
              icon: Icons.edit_rounded,
              iconBg: const Color(0xFF3B6BE4),
              title: 'Enter Manually',
              subtitle: 'Input your expense details manually',
              onTap: () {
                Navigator.of(context).pop();
                showModalBottomSheet(
                  context: context,
                  backgroundColor: context.colors.surface,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24))),
                  builder: (_) => const AddEditTransactionSheet(),
                );
              },
            ),
            const SizedBox(height: 12),
            _MethodRow(
              icon: Icons.picture_as_pdf_rounded,
              iconBg: const Color(0xFFFF7E3E),
              title: 'PDF Receipt',
              subtitle: 'Upload a PDF receipt of your transaction details',
              comingSoon: true,
            ),
            const SizedBox(height: 12),
            _MethodRow(
              icon: Icons.image_rounded,
              iconBg: const Color(0xFFB13BE4),
              title: 'Upload Image',
              subtitle: 'Upload an image of your transaction details',
              comingSoon: true,
            ),
            const SizedBox(height: 12),
            _MethodRow(
              icon: Icons.camera_alt_rounded,
              iconBg: const Color(0xFF0CA75B),
              title: 'Snap Receipt',
              subtitle: 'Quickly capture expense details with your camera',
              comingSoon: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.comingSoon = false,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: comingSoon ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.pageBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.divider, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: context.textStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (comingSoon) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5656).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Coming soon',
                  style: context.textStyles.label.copyWith(
                    color: const Color(0xFFFF5656),
                    fontSize: 9,
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
