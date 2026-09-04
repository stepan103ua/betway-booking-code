'use client';

import { type ReactNode, useState } from 'react';
import type { Selection } from '@booking-code/contracts';
import { SelectionRow } from '@/components/selection-row';
import { type SlipStatus, SlipHeader } from '@/components/slip-header';
import { Alert } from '@/components/ui/alert';
import { Card } from '@/components/ui/card';
import { slipStatus } from '@/lib/format';

/**
 * The product's central object (design-system.md §5) — header, an optional partial-slip
 * notice, the selection list on a `surfaceRow` band, a "Show N more" expander, and an
 * optional footer. Takes the real `Selection` DTOs; used unchanged by Decode, Create's recap
 * and Convert's before/after.
 */
export function SlipCard({
  code,
  totalOdds,
  selections,
  status,
  expiresAt,
  usageCount,
  notice,
  onCopy,
  footer,
  collapsedCount,
}: {
  code: string;
  totalOdds: number;
  selections: Selection[];
  status?: SlipStatus;
  expiresAt?: string | null;
  usageCount?: number | null;
  /** Overrides the built-in "N of M are no longer available" notice; pass `null` to suppress. */
  notice?: ReactNode;
  onCopy?: () => void;
  footer?: ReactNode;
  collapsedCount?: number;
}) {
  const [expanded, setExpanded] = useState(false);

  const dead = selections.filter((s) => !s.isActive).length;
  const resolved = status ?? slipStatus(selections);
  const shown =
    collapsedCount != null && !expanded ? selections.slice(0, collapsedCount) : selections;
  const hidden = selections.length - shown.length;

  return (
    <Card padding="none" className="overflow-hidden">
      <SlipHeader
        code={code}
        totalOdds={totalOdds}
        selectionCount={selections.length}
        status={resolved}
        expiresAt={expiresAt}
        usageCount={usageCount}
        onCopy={onCopy}
      />

      {notice !== undefined
        ? notice && <div className="px-[14px] pb-[14px]">{notice}</div>
        : resolved === 'partial' &&
          dead > 0 && (
            <div className="px-[14px] pb-[14px]">
              <Alert
                tone="warn"
                title={`${dead} of ${selections.length} selections are no longer available`}
              >
                The rest of the slip still loads. Remove the dead legs in Convert to get a fresh
                code.
              </Alert>
            </div>
          )}

      <ul className="bg-surface-row">
        {shown.map((selection, i) => (
          <SelectionRow key={selection.outcomeId} selection={selection} index={i + 1} />
        ))}
      </ul>

      {hidden > 0 && (
        <button
          type="button"
          onClick={() => setExpanded(true)}
          className="type-body-strong h-11 w-full border-t border-border-subtle bg-surface-row text-[13px] text-text-secondary hover:text-text-primary"
        >
          Show {hidden} more {hidden === 1 ? 'selection' : 'selections'}
        </button>
      )}

      {footer && (
        <div className="border-t border-border-subtle bg-surface-card p-[14px]">{footer}</div>
      )}
    </Card>
  );
}
