import type { Fixture } from '@booking-code/contracts';
import { List } from 'lucide-react';
import { OutcomeChip } from '@/components/create/outcome-chip';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { type DraftPick, draftPick } from '@/lib/draft';
import { formatKickoff } from '@/lib/format';

const WDW_LABELS = ['1', 'X', '2'];

/**
 * One fixture in the browse list: name, league and kickoff, the inline 1X2 market as three
 * tappable chips, and a way into the full market sheet. `GET /api/events` always returns
 * exactly the 1X2 market inline (docs/backend-api.md §2), so `markets[0]` is what's shown.
 */
export function EventTile({
  event,
  selectedOutcomeIds,
  draftFull,
  eventHasPick,
  onToggle,
  onMoreMarkets,
}: {
  event: Fixture;
  selectedOutcomeIds: Set<string>;
  /** Draft is at the 20-leg cap — unselected chips disable so the limit is visible. */
  draftFull: boolean;
  /** This match already has a leg — a code can't hold two on one event (docs/betway-api.md §3). */
  eventHasPick: boolean;
  onToggle: (pick: DraftPick) => void;
  onMoreMarkets: () => void;
}) {
  const market = event.markets[0];
  const isWdw = market?.type === 'win-draw-win' && market.outcomes.length === 3;

  return (
    <Card padding="md" className="flex flex-col gap-3">
      <div>
        <p className="type-body-strong line-clamp-2 text-text-primary">{event.name}</p>
        <p className="type-meta mt-1 truncate text-text-muted">
          {event.league} &nbsp;·&nbsp; {formatKickoff(event.kickoffAt)}
        </p>
      </div>

      {market && (
        <div className="grid grid-cols-3 gap-2">
          {market.outcomes.map((outcome, i) => (
            <OutcomeChip
              key={outcome.outcomeId}
              block
              label={isWdw ? (WDW_LABELS[i] ?? outcome.label) : outcome.label}
              odds={outcome.odds}
              selected={selectedOutcomeIds.has(outcome.outcomeId)}
              disabled={draftFull || eventHasPick}
              onToggle={() => onToggle(draftPick(event, market, outcome))}
            />
          ))}
        </div>
      )}

      {eventHasPick && (
        <p className="type-meta text-text-muted">
          One pick per match — remove it in your slip to choose another.
        </p>
      )}

      <Button
        variant="ghost"
        size="sm"
        className="self-start"
        icon={<List className="size-3.5" aria-hidden />}
        onClick={onMoreMarkets}
      >
        More markets
      </Button>
    </Card>
  );
}
