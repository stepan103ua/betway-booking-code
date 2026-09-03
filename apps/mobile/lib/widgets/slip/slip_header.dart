import 'package:flutter/material.dart';

import '../../design/app_icons.dart';
import '../../design/tokens/app_colors.dart';
import '../../design/tokens/app_typography.dart';
import '../../design/widgets/app_badge.dart';
import '../../design/widgets/app_icon_button.dart';
import 'slip_format.dart';

/// `docs/backend-api.md` §1 is explicit that `resolve` never reports a slip
/// as expired — `expiresAt` comes back `null` every time, because
/// `FindBookABet` doesn't track it. There is no third status here for that
/// reason: an `expired` badge would be UI for a state the API cannot
/// produce.
enum SlipStatus { live, partial }

class _StatusSpec {
  const _StatusSpec(this.tone, this.icon, this.label);
  final AppBadgeTone tone;
  final String icon;
  final String label;
}

const _statusSpecs = {
  SlipStatus.live: _StatusSpec(AppBadgeTone.accent, 'check', 'Active'),
  SlipStatus.partial: _StatusSpec(
    AppBadgeTone.warn,
    'triangle-alert',
    'Some legs dead',
  ),
};

/// Slip header: code, hero total odds, leg count, expiry, usage.
class SlipHeader extends StatelessWidget {
  const SlipHeader({
    super.key,
    required this.code,
    required this.totalOdds,
    required this.selectionCount,
    this.expiresIn,
    this.usedCount,
    this.status = SlipStatus.live,
    this.onCopy,
  });

  final String code;
  final double totalOdds;
  final int selectionCount;
  final String? expiresIn;
  final int? usedCount;
  final SlipStatus status;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spec = _statusSpecs[status]!;
    final microLabel = AppTypography.label.copyWith(color: colors.textMuted);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('BOOKING CODE', style: microLabel),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            code,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.codeHero.copyWith(
                              color: colors.codeText,
                            ),
                          ),
                        ),
                        if (onCopy != null) ...[
                          const SizedBox(width: 8),
                          AppIconButton(
                            icon: 'copy',
                            label: 'Copy booking code',
                            size: AppIconButtonSize.sm,
                            onPressed: onCopy,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('TOTAL ODDS', style: microLabel),
                  const SizedBox(height: 4),
                  Text(
                    totalOdds.toStringAsFixed(2),
                    style: AppTypography.oddsHero.copyWith(
                      color: colors.oddsText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppBadge(label: spec.label, tone: spec.tone, icon: spec.icon),
              _Meta(icon: 'list', label: '$selectionCount selections'),
              if (expiresIn != null) _Meta(icon: 'clock', label: expiresIn!),
              if (usedCount != null)
                _Meta(
                  icon: 'users',
                  label: '${formatUsageCount(usedCount!)} loaded',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(icon, size: 12, color: colors.textMuted),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTypography.meta.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}
