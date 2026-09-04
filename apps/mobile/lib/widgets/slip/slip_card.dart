import 'package:flutter/material.dart';

import '../../design/tokens/app_colors.dart';
import '../../design/tokens/app_typography.dart';
import '../../design/widgets/app_alert.dart';
import '../../design/widgets/app_card.dart';
import '../../models/selection.dart';
import 'selection_row.dart';
import 'slip_header.dart';

/// The product's central object: a booking code and everything inside it.
/// Used, unchanged, wherever a slip is shown — Decode's result, Create's
/// "what's inside" recap, Convert's before state — same as `models/` sits
/// above `features/` in `docs/mobile.md` because `Slip` is the one shape
/// every feature shares.
class SlipCard extends StatefulWidget {
  const SlipCard({
    super.key,
    required this.code,
    required this.totalOdds,
    required this.selections,
    this.expiresIn,
    this.usedCount,
    this.status,
    this.notice,
    this.onCopy,
    this.footer,
    this.collapsedCount,
  });

  final String code;
  final double totalOdds;
  final List<Selection> selections;
  final String? expiresIn;
  final int? usedCount;

  /// Defaults to [SlipStatus.live]/[SlipStatus.partial], derived from
  /// whether any selection is inactive — the API is the one source of
  /// staleness (`isActive`), so a caller only needs to override this for a
  /// status the selections themselves can't express.
  final SlipStatus? status;

  /// Overrides the built-in "N selections are no longer available" notice
  /// for a `partial` slip. Pass an explicit `SizedBox.shrink()` to suppress
  /// it entirely rather than showing both.
  final Widget? notice;
  final VoidCallback? onCopy;
  final Widget? footer;
  final int? collapsedCount;

  @override
  State<SlipCard> createState() => _SlipCardState();
}

class _SlipCardState extends State<SlipCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dead = widget.selections.where((s) => !s.isActive).length;
    final status =
        widget.status ?? (dead > 0 ? SlipStatus.partial : SlipStatus.live);
    final shown = widget.collapsedCount != null && !_expanded
        ? widget.selections.take(widget.collapsedCount!).toList()
        : widget.selections;
    final hidden = widget.selections.length - shown.length;

    return AppCard(
      padding: AppCardPadding.none,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SlipHeader(
            code: widget.code,
            totalOdds: widget.totalOdds,
            selectionCount: widget.selections.length,
            expiresIn: widget.expiresIn,
            usedCount: widget.usedCount,
            status: status,
            onCopy: widget.onCopy,
          ),
          if (widget.notice != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: widget.notice,
            )
          else if (status == SlipStatus.partial && dead > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: AppAlert(
                tone: AppAlertTone.warn,
                title:
                    '$dead of ${widget.selections.length} selections are no longer available',
                body:
                    'The rest of the slip still loads. Remove the dead legs in Convert to get a fresh code.',
              ),
            ),
          Container(
            color: colors.surfaceRow,
            child: Column(
              children: [
                for (var i = 0; i < shown.length; i++)
                  SelectionRow(
                    selection: shown[i],
                    index: i + 1,
                    showDivider: true,
                  ),
              ],
            ),
          ),
          if (hidden > 0)
            Material(
              color: colors.surfaceRow,
              child: InkWell(
                onTap: () => setState(() => _expanded = true),
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: colors.borderSubtle)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Show $hidden more ${hidden == 1 ? 'selection' : 'selections'}',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          if (widget.footer != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                border: Border(top: BorderSide(color: colors.borderSubtle)),
              ),
              child: widget.footer,
            ),
        ],
      ),
    );
  }
}
