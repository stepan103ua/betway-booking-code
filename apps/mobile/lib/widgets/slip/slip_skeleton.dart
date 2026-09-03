import 'package:flutter/material.dart';

import '../../design/tokens/app_colors.dart';
import '../../design/tokens/app_radius.dart';
import '../../design/tokens/app_spacing.dart';
import '../../design/widgets/app_card.dart';
import '../../design/widgets/app_skeleton.dart';

/// Loading state for a slip: the shape of the answer, never a spinner.
class SlipSkeleton extends StatelessWidget {
  const SlipSkeleton({super.key, this.rows = 5});

  final int rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: AppCardPadding.none,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
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
                        children: const [
                          AppSkeleton(width: 72, height: 9),
                          SizedBox(height: 8),
                          AppSkeleton(
                            width: 150,
                            height: 24,
                            radius: AppRadius.md,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        AppSkeleton(width: 60, height: 9),
                        SizedBox(height: 8),
                        AppSkeleton(
                          width: 96,
                          height: 30,
                          radius: AppRadius.md,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    AppSkeleton(width: 64, height: 20, radius: AppRadius.sm),
                    SizedBox(width: 8),
                    AppSkeleton(width: 88, height: 20, radius: AppRadius.sm),
                    SizedBox(width: 8),
                    AppSkeleton(width: 76, height: 20, radius: AppRadius.sm),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: colors.surfaceRow,
            child: Column(
              children: [
                for (var i = 0; i < rows; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.slipRowPadY,
                      horizontal: AppSpacing.slipRowPadX,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: colors.borderSubtle),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const AppSkeleton(height: 12),
                              const SizedBox(height: 7),
                              Row(
                                children: const [
                                  AppSkeleton(
                                    width: 52,
                                    height: 16,
                                    radius: AppRadius.sm,
                                  ),
                                  SizedBox(width: 6),
                                  AppSkeleton(
                                    width: 84,
                                    height: 16,
                                    radius: AppRadius.sm,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              const FractionallySizedBox(
                                widthFactor: 0.46,
                                alignment: Alignment.centerLeft,
                                child: AppSkeleton(height: 10),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: AppSkeleton(
                            width: 46,
                            height: 16,
                            radius: AppRadius.sm,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
