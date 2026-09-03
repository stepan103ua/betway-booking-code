'use client';

import { useState } from 'react';
import type { Slip } from '@booking-code/contracts';
import { ChevronRight } from 'lucide-react';
import { SelectionRow } from '@/components/selection-row';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { formatExpiry, formatOdds, formatUsage, pluralize } from '@/lib/format';

/**
 * One live code: a collapsed summary (code, odds, leg count) that expands in place to the
 * same `SelectionRow` list a resolved slip shows, with a button to decode it (navigate to
 * `/<code>`). A booking code alone tells a user nothing worth clicking for. The expand
 * animates via a `grid-template-rows` 0fr→1fr transition — height without measuring anything.
 */
export function PopularCodeTile({ slip, onUse }: { slip: Slip; onUse: (code: string) => void }) {
  const [expanded, setExpanded] = useState(false);
  const dead = slip.selections.filter((s) => !s.isActive).length;

  return (
    <Card tone="raised" padding="none" className="overflow-hidden transition-colors">
      <button
        type="button"
        onClick={() => setExpanded((v) => !v)}
        aria-expanded={expanded}
        className="flex w-full items-center gap-3 px-3.5 py-3 text-left transition-colors hover:bg-surface-hover"
      >
        <span className="min-w-0 flex-1">
          <span className="flex items-center gap-2">
            <span className="type-code truncate text-text-primary">{slip.bookingCode}</span>
            <Badge mono tone="accent">
              {formatOdds(slip.totalOdds)}
            </Badge>
          </span>
          <span className="mt-1 flex flex-wrap gap-x-1.5 text-text-muted">
            <span className="type-meta">{pluralize(slip.selections.length, 'selection')}</span>
            {dead > 0 && <span className="type-meta text-warn-text">· {dead} dead</span>}
            {slip.expiresAt != null && (
              <span className="type-meta">· {formatExpiry(slip.expiresAt)}</span>
            )}
            {slip.usageCount != null && (
              <span className="type-meta">· {formatUsage(slip.usageCount)}</span>
            )}
          </span>
        </span>
        <ChevronRight
          className={`size-4 shrink-0 text-text-muted transition-transform duration-200 ease-[var(--ease-out)] ${expanded ? 'rotate-90' : ''}`}
          aria-hidden
        />
      </button>

      <div
        className={`grid transition-[grid-template-rows] duration-200 ease-[var(--ease-out)] ${expanded ? 'grid-rows-[1fr]' : 'grid-rows-[0fr]'}`}
      >
        <div className="overflow-hidden">
          <ul className="border-t border-border-subtle bg-surface-row">
            {slip.selections.map((selection, i) => (
              <SelectionRow key={selection.outcomeId} selection={selection} index={i + 1} />
            ))}
          </ul>
          <div className="p-3.5">
            <Button variant="secondary" block onClick={() => onUse(slip.bookingCode)}>
              Decode this code
            </Button>
          </div>
        </div>
      </div>
    </Card>
  );
}
