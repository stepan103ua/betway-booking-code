import type { Metadata } from 'next';
import { CreateScreen } from '@/components/create/create-screen';
import { getEventsPage, getSports } from '@/lib/create';

export const metadata: Metadata = { title: 'Create — Betway Booking Code' };

/**
 * Create — build an accumulator and generate a booking code. `GET /api/sports` and the first
 * `GET /api/events` page are read here (Server Component, in parallel); the fixture list
 * pages and the generate call go through Server Actions from `CreateScreen`.
 *
 * The selected sport rides in `?sport=` — the same "URL is the state" choice Decode makes,
 * so the first fixture page can be server-rendered for whichever sport is showing. Upstream
 * lists only soccer today, so this is mostly future-proofing.
 */
export default async function CreatePage({
  searchParams,
}: {
  searchParams: Promise<{ sport?: string }>;
}) {
  const sports = await getSports();
  const requested = (await searchParams).sport;
  const sport = pickSport(sports, requested);
  const firstEventsPage = sport ? await getEventsPage(sport) : null;

  return (
    <main>
      <CreateScreen sports={sports} sport={sport} firstEventsPage={firstEventsPage} />
    </main>
  );
}

function pickSport(sports: { id: string }[] | null, requested: string | undefined): string | null {
  if (!sports || sports.length === 0) return null;
  const match = requested && sports.find((s) => s.id === requested);
  return match ? match.id : (sports[0]?.id ?? null);
}
