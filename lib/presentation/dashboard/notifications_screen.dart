import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: Text('Notifications', style: context.textStyles.heading.copyWith(fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all_rounded, color: context.colors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All caught up!')),
              );
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: context.colors.divider),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const _DateHeader(date: 'Today'),
            const SizedBox(height: 12),
            _NotificationCard(
              title: 'Weekly Report Generated',
              message: 'Your spending report for this week is ready. You saved 12% more than average!',
              time: '10:30 AM',
              icon: Icons.pie_chart_rounded,
              color: context.colors.primary,
              bgColor: context.colors.primary.withAlpha(20),
            ),
            const SizedBox(height: 12),
            _NotificationCard(
              title: 'Budget Alert',
              message: 'You have used 80% of your Food & Dining budget.',
              time: '08:15 AM',
              icon: Icons.warning_rounded,
              color: context.colors.expenseRed,
              bgColor: context.colors.expenseBg,
            ),
            const SizedBox(height: 24),
            
            const _DateHeader(date: 'Yesterday'),
            const SizedBox(height: 12),
            _NotificationCard(
              title: 'Transaction Successful',
              message: 'N1,000 was deducted for Netflix Subscription.',
              time: '18:45 PM',
              icon: Icons.done_all_rounded,
              color: context.colors.textMuted,
              bgColor: context.colors.surface,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});
  final String date;

  @override
  Widget build(BuildContext context) {
    return Text(date, style: context.textStyles.sectionHeader);
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(color: context.colors.ink.withAlpha(15), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600))),
                    Text(time, style: context.textStyles.caption.copyWith(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(message, style: context.textStyles.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }
}
