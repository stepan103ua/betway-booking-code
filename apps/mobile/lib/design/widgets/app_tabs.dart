import 'package:flutter/material.dart';

import '../app_icons.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

class AppTabItem {
  const AppTabItem({required this.value, required this.label, this.icon});
  final String value;
  final String label;
  final String? icon;
}

/// Segmented switch for the three jobs: Decode / Create / Convert. This is
/// the mode switch — not to be confused with a bottom nav bar; the design
/// system keeps those as two different controls (`AppShell`'s [AppTabs] up
/// top for "which job", the bottom nav for "which app section").
class AppTabs extends StatelessWidget {
  const AppTabs({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final List<AppTabItem> items;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: _Tab(
                item: item,
                active: item.value == value,
                onTap: () => onChanged(item.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item, required this.active, required this.onTap});
  final AppTabItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: active,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.easeOut,
          height: 44,
          decoration: BoxDecoration(
            color: active ? colors.surfaceRaised : Colors.transparent,
            border: Border.all(
              color: active ? colors.borderStrong : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null) ...[
                AppIcon(
                  item.icon!,
                  size: 15,
                  color: active ? colors.textPrimary : colors.textMuted,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                item.label,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: -0.015 * 14,
                  color: active ? colors.textPrimary : colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
