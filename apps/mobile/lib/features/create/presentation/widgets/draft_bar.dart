import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../design/app_icons.dart';
import '../../../../design/tokens/app_colors.dart';
import '../../../../design/tokens/app_motion.dart';
import '../../../../design/tokens/app_radius.dart';
import '../../../../design/tokens/app_typography.dart';
import '../../../../design/widgets/app_button.dart';
import '../cubit/create_cubit.dart';
import '../cubit/create_state.dart';
import 'draft_sheet.dart';

/// The floating slip summary — a rounded island near the bottom of the Create
/// screen while there are legs. The left side (leg count + running odds) opens
/// [openDraftSheet]; the right side generates the code straight away. It sits
/// in an overlay (see `AppShell`), not the scrolling column, so the fixture
/// list never jumps when a leg is added or an error appears.
class DraftBar extends StatelessWidget {
  const DraftBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<CreateCubit, CreateState>(
      builder: (context, state) {
        final ready = state is CreateReady;
        final visible =
            ready && state.picks.isNotEmpty && state.createdCode == null;
        final legs = ready ? state.picks.length : 0;
        final odds = ready ? state.totalOdds : 1.0;
        final generating = ready && state.generating;
        final failed = ready && state.generateError != null;

        return IgnorePointer(
          ignoring: !visible,
          child: SafeArea(
            top: false,
            child: AnimatedSlide(
              // Travel a bit past its own height so the island clears the
              // bottom margin when hidden.
              offset: visible ? Offset.zero : const Offset(0, 1.4),
              duration: AppMotion.base,
              curve: AppMotion.easeOut,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: AppMotion.fast,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: colors.borderStrong),
                    ),
                    padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Summary(
                            legs: legs,
                            odds: odds,
                            failed: failed,
                            onTap: () => openDraftSheet(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        AppButton(
                          label: 'Generate',
                          variant: AppButtonVariant.primary,
                          icon: 'wand-sparkles',
                          loading: generating,
                          onPressed: () =>
                              context.read<CreateCubit>().generate(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.legs,
    required this.odds,
    required this.failed,
    required this.onTap,
  });

  final int legs;
  final double odds;
  final bool failed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: failed
          ? "Couldn't generate. Open the slip for details."
          : 'Your slip, $legs ${legs == 1 ? 'leg' : 'legs'}, '
                'total odds ${odds.toStringAsFixed(2)}. Open for details.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          children: [
            RotatedBox(
              quarterTurns: -1,
              child: AppIcon(
                'chevron-right',
                size: 16,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: failed
                  ? Text(
                      "Couldn't generate — tap for details",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.meta.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.dangerText,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$legs ${legs == 1 ? 'leg' : 'legs'}',
                          style: AppTypography.meta.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                        Text(
                          odds.toStringAsFixed(2),
                          style: AppTypography.odds.copyWith(
                            fontSize: 18,
                            color: colors.oddsText,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
