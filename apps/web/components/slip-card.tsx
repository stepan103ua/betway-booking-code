import type { Selection, Slip } from '@booking-code/contracts';
import { Badge } from '@/components/ui/badge';
import { Card } from '@/components/ui/card';
import { DEAD_LEG_REASON, formatKickoff, formatOdds, formatUsage, slipStatus } from '@/lib/format';

/**
 * The product's central object (design-system.md §5). Takes the real `Slip` / `Selection`
 * DTOs — no parallel view-model — and is used unchanged for Decode's result, Create's recap
 * and Convert's before/after. Composition only: layout and formatting, over the
 * `components/ui/` primitives. This is the basic version — no expander, no footer actions.
 */
export function SlipCard({ slip }: { slip: Slip }) {
  const status = slipStatus(slip.selections);

  return (
    <Card padding="none" className="overflow-hidden">
      <header className="flex flex-wrap items-start justify-between gap-4 p-4">
        <div>
          <p className="type-label text-text-muted">Booking code</p>
          <p className="type-code-hero mt-1 text-text-primary">{slip.bookingCode}</p>
        </div>
        <div className="text-right">
          <p className="type-label text-text-muted">Total odds</p>
          <p className="type-odds-hero mt-1 text-odds-text">{formatOdds(slip.totalOdds)}</p>
        </div>
      </header>

      <div className="flex flex-wrap gap-2 px-4 pb-3">
        <Badge tone={status === 'live' ? 'accent' : 'warn'}>
          {status === 'live' ? 'Active' : 'Some legs dead'}
        </Badge>
        <Badge>{slip.selections.length} selections</Badge>
        {slip.usageCount !== null && <Badge>{formatUsage(slip.usageCount)}</Badge>}
      </div>

      <ul className="bg-surface-row">
        {slip.selections.map((selection) => (
          <SelectionRow key={selection.outcomeId} selection={selection} />
        ))}
      </ul>
    </Card>
  );
}

function SelectionRow({ selection }: { selection: Selection }) {
  const dead = !selection.isActive;
  return (
    <li className="border-t border-border-subtle px-[14px] py-3 first:border-t-0" data-dead={dead}>
      <p className={`type-body-strong text-text-primary ${dead ? 'line-through opacity-70' : ''}`}>
        {selection.eventName}
      </p>
      <p className="mt-1 flex flex-wrap items-center gap-2 text-text-secondary">
        <Badge tone="neutral">{selection.marketName}</Badge>
        <span className="type-body">{selection.outcomeName.trim()}</span>
        <span className="type-odds text-odds-text">{formatOdds(selection.odds)}</span>
      </p>
      <p className="type-meta mt-1 text-text-muted">
        {selection.league} · {formatKickoff(selection.kickoffAt)}
      </p>
      {dead && <p className="type-meta mt-1 text-danger-text">{DEAD_LEG_REASON}</p>}
    </li>
  );
}
