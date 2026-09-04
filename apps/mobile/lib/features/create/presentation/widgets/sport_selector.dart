import 'package:flutter/material.dart';

import '../../../../design/tokens/app_colors.dart';
import '../../../../design/tokens/app_motion.dart';
import '../../../../design/tokens/app_radius.dart';
import '../../../../design/tokens/app_typography.dart';
import '../../../../design/widgets/app_reveal.dart';
import '../../../../models/sport.dart';

/// Horizontal row of sport chips. Upstream lists only `soccer` today, so this
/// usually renders a single selected chip — it exists in full so a second
/// sport appearing in `GET /api/sports` needs no code change here.
class SportSelector extends StatelessWidget {
  const SportSelector({
    super.key,
    required this.sports,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Sport> sports;
  final String selectedId;
  final ValueChanged<Sport> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SPORT',
          style: AppTypography.label.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final sport in sports) ...[
                _SportChip(
                  label: sport.name,
                  selected: sport.id == selectedId,
                  onTap: () => onSelect(sport),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SportChip extends StatelessWidget {
  const _SportChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: PressScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? colors.accentSolid : colors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: selected ? colors.accentSolid : colors.borderStrong,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: selected ? colors.textOnAccent : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
