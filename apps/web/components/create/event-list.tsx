'use client';

import { useState, useTransition } from 'react';
import type { EventsPage, Fixture } from '@booking-code/contracts';
import { ChevronRight } from 'lucide-react';
import { EventTile } from '@/components/create/event-tile';
import { Alert } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import type { DraftPick } from '@/lib/draft';
import { loadEvents } from '@/app/actions';

/**
 * The upcoming-fixtures list for the selected sport. The first page is server-rendered
 * (`firstEventsPage`) and re-seeds this component whenever it changes — a sport switch or a
 * "refresh fixtures". "Load more" appends the next page through a Server Action.
 *
 * Paging is driven by `hasMore` (upstream's own end-of-list flag), never `events.length` —
 * this feed reports no total and a page can come back short while more remain
 * (docs/backend-api.md §2).
 */
export function EventList({
  sport,
  sportName,
  firstPage,
  selectedOutcomeIds,
  pickedEventIds,
  draftFull,
  onToggle,
  onMoreMarkets,
}: {
  sport: string;
  sportName: string;
  firstPage: EventsPage | null;
  selectedOutcomeIds: Set<string>;
  pickedEventIds: Set<string>;
  draftFull: boolean;
  onToggle: (pick: DraftPick) => void;
  onMoreMarkets: (event: Fixture) => void;
}) {
  const [events, setEvents] = useState<Fixture[]>(firstPage?.events ?? []);
  const [nextSkip, setNextSkip] = useState((firstPage?.skip ?? 0) + (firstPage?.limit ?? 0));
  const [hasMore, setHasMore] = useState(firstPage?.hasMore ?? false);
  const [loadMoreFailed, setLoadMoreFailed] = useState(false);
  const [pending, startTransition] = useTransition();

  // Re-seed when the server hands down a new first page (sport switch, refresh).
  const [seed, setSeed] = useState(firstPage);
  if (firstPage !== seed) {
    setSeed(firstPage);
    setEvents(firstPage?.events ?? []);
    setNextSkip((firstPage?.skip ?? 0) + (firstPage?.limit ?? 0));
    setHasMore(firstPage?.hasMore ?? false);
    setLoadMoreFailed(false);
  }

  function loadMore() {
    startTransition(async () => {
      const page = await loadEvents(sport, nextSkip);
      if (!page) {
        setLoadMoreFailed(true);
        return;
      }
      setEvents((prev) => [...prev, ...page.events]);
      setNextSkip(page.skip + page.limit);
      setHasMore(page.hasMore);
      setLoadMoreFailed(false);
    });
  }

  if (firstPage === null) {
    return (
      <Alert tone="danger" title="Couldn't load fixtures">
        The fixture list is unavailable right now. Try again in a moment.
      </Alert>
    );
  }

  if (events.length === 0) {
    return <p className="type-meta text-text-muted">No upcoming {sportName} fixtures right now.</p>;
  }

  return (
    <div className="flex flex-col gap-2.5">
      {events.map((event) => (
        <div key={event.eventId} className="animate-rise">
          <EventTile
            event={event}
            selectedOutcomeIds={selectedOutcomeIds}
            draftFull={draftFull}
            eventHasPick={pickedEventIds.has(event.eventId)}
            onToggle={onToggle}
            onMoreMarkets={() => onMoreMarkets(event)}
          />
        </div>
      ))}

      {hasMore && (
        <>
          {loadMoreFailed && (
            <p className="type-meta text-danger-text">
              Couldn&apos;t load more fixtures. Tap to try again.
            </p>
          )}
          <Button
            variant="secondary"
            block
            loading={pending}
            icon={<ChevronRight className="size-4" aria-hidden />}
            onClick={loadMore}
          >
            {loadMoreFailed ? 'Retry loading fixtures' : 'Load more fixtures'}
          </Button>
        </>
      )}
    </div>
  );
}

export function EventListSkeleton() {
  return (
    <div className="flex flex-col gap-2.5">
      {Array.from({ length: 3 }, (_, i) => (
        <Card key={i} padding="md" className="flex flex-col gap-3">
          <Skeleton height={13} />
          <Skeleton width="50%" height={10} />
          <div className="grid grid-cols-3 gap-2">
            <Skeleton height={34} />
            <Skeleton height={34} />
            <Skeleton height={34} />
          </div>
        </Card>
      ))}
    </div>
  );
}
