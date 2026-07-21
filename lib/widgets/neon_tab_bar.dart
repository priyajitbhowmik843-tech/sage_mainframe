import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared neon tab bar used across all dashboards
class NeonTabBar extends StatelessWidget {
  final int selectedIndex;
  final List<IconData> icons;
  final List<String> labels;
  final ValueChanged<int> onTap;
  final Color? accentColor;
  final Map<int, int> badges;

  const NeonTabBar({
    super.key,
    required this.selectedIndex,
    required this.icons,
    required this.labels,
    required this.onTap,
    this.accentColor,
    this.badges = const {},
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? SageColors.primary;
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(icons.length, (i) {
            final active = i == selectedIndex;
            final unreadCount = badges[i] ?? 0;
            return GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: active ? color : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topRight,
                  children: [
                    Icon(
                      icons[i],
                      size: 24,
                      color: active ? Colors.black : SageColors.outlineVariant,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: SageColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Neon-styled list tile for employees, tasks etc.
class NeonListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool glow;

  const NeonListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.borderColor,
    this.onTap,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? SageColors.outlineVariant;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: SageColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SageColors.outlineVariant, width: 1),
          boxShadow: glow
              ? SageColors.neonGlow(color, spread: 0, blur: 4)
              : null,
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  title,
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    subtitle!,
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}
