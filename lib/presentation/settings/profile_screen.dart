import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: context.colors.pageBg,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Personal Information', style: context.textStyles.heading.copyWith(fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: context.colors.divider),
        ),
      ),
      body: SafeArea(
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            color: context.colors.primary.withAlpha(20),
                            shape: BoxShape.circle,
                            border: Border.all(color: context.colors.primary.withAlpha(40), width: 3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            user.initials,
                            style: context.textStyles.heading.copyWith(fontSize: 36, color: context.colors.primary),
                          ),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: context.colors.ink,
                              shape: BoxShape.circle,
                              border: Border.all(color: context.colors.pageBg, width: 2),
                            ),
                            child: Icon(Icons.camera_alt_rounded, color: context.colors.onInk, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  _InfoField(
                    label: 'Full Name',
                    value: user.name,
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 24),

                  _InfoField(
                    label: 'Email Address',
                    value: user.email,
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 24),
                  
                  _InfoField(
                    label: 'Account Created',
                    value: user.createdAt != null 
                        ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                        : 'Unknown Date',
                    icon: Icons.calendar_today_rounded,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Save button placeholder
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updates coming soon.')));
                      },
                      child: Text('Save Changes', style: context.textStyles.buttonLabel.copyWith(color: context.colors.onPrimary)),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textStyles.label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.divider, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: context.colors.textMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: context.textStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
