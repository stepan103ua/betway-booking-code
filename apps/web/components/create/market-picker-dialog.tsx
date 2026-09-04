'use client';

import { useEffect, useState } from 'react';
import type { Fixture } from '@booking-code/contracts';
import { RotateCcw } from 'lucide-react';
import { OutcomeChip } from '@/components/create/outcome-chip';
import { Alert } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { Modal } from '@/components/ui/modal';
import { Skeleton } from '@/components/ui/skeleton';
import type { MarketsResult } from '@/lib/create';
import { type DraftPick, draftPick } from '@/lib/draft';
import { loadEventMarkets } from '@/app/actions';

/**
 * The "more markets" sheet — the full market list for one event, loaded on open. The picker
 * keeps one pick per match, so an event that already has a leg shows a notice and disables
 * every chip until that leg is removed (docs/betway-api.md §3).
 */
export function MarketPickerDialog({
  event,
  selectedOutcomeIds,
  draftFull,
  eventHasPick,
  onToggle,
  onClose,
}: {
  event: Fixture | null;
  selectedOutcomeIds: Set<string>;
  draftFull: boolean;
  /** The draft already has a leg on this event. */
  eventHasPick: boolean;
  onToggle: (pick: DraftPick) => void;
  onClose: () => void;
}) {
  // Hold the last event so the sheet keeps its content while it animates closed.
  const [shown, setShown] = useState(event);
  if (event && event.eventId !== shown?.eventId) setShown(event);

  const [loaded, setLoaded] = useState<{ eventId: string; result: MarketsResult } | null>(null);
  const [retryKey, setRetryKey] = useState(0);

  useEffect(() => {
    if (!event) return;
    let alive = true;
    void loadEventMarkets(event.eventId).then((result) => {
      if (alive) setLoaded({ eventId: event.eventId, result });
    });
    return () => {
      alive = false;
    };
  }, [event, retryKey]);

  const result = event && loaded?.eventId === event.eventId ? loaded.result : null;

  return (
    <Modal open={event != null} onClose={onClose} title={shown?.name ?? 'Markets'}>
      {shown && eventHasPick && (
        <Alert tone="info" title="One pick per match" className="mb-4">
          You&apos;ve got a selection on this match. A booking code can&apos;t combine two from the
          same event — remove it in your slip to pick a different one.
        </Alert>
      )}

      {result === null && <MarketsSkeleton />}

      {result?.kind === 'empty' && (
        <Alert tone="info" title="No markets for this event yet">
          Nothing is priced on this fixture right now. Try another event, or check back closer to
          kick-off.
        </Alert>
      )}

      {result?.kind === 'error' && (
        <Alert
          tone="danger"
          title="Couldn't load markets"
          action={
            <Button
              variant="secondary"
              size="sm"
              icon={<RotateCcw className="size-3.5" aria-hidden />}
              onClick={() => setRetryKey((k) => k + 1)}
            >
              Try again
            </Button>
          }
        >
          {result.message}
        </Alert>
      )}

      {result?.kind === 'markets' && shown && (
        <div className="flex animate-rise flex-col gap-4">
          {result.markets.map((market) => (
            <div key={market.marketId} className="flex flex-col gap-2">
              <p className="type-body-strong text-text-secondary">{market.name}</p>
              <div className="flex flex-wrap gap-2">
                {market.outcomes.map((outcome) => (
                  <OutcomeChip
                    key={outcome.outcomeId}
                    label={outcome.label}
                    odds={outcome.odds}
                    selected={selectedOutcomeIds.has(outcome.outcomeId)}
                    disabled={draftFull || eventHasPick}
                    onToggle={() => onToggle(draftPick(shown, market, outcome))}
                  />
                ))}
              </div>
            </div>
          ))}
        </div>
      )}
    </Modal>
  );
}

function MarketsSkeleton() {
  return (
    <div className="flex flex-col gap-4">
      {Array.from({ length: 4 }, (_, i) => (
        <div key={i} className="flex flex-col gap-2">
          <Skeleton width={120} height={13} />
          <div className="flex gap-2">
            <Skeleton width={84} height={34} />
            <Skeleton width={84} height={34} />
            <Skeleton width={84} height={34} />
          </div>
        </div>
      ))}
    </div>
  );
}
