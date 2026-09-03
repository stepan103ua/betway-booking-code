import type { PopularPage } from '@booking-code/contracts';
import { DecodeForm } from '@/components/decode-form';
import { PopularCodes } from '@/components/popular-codes';
import { apiFetch } from '@/lib/api';

/**
 * Decode (`/`) — the default route. The `popular codes` read happens here, in a Server
 * Component, and ships in the HTML; everything the user types or submits is the Client
 * Component `DecodeForm` (docs/frontend.md §2, "fetch on the server, mutate on the client").
 */
async function getPopularCodes(): Promise<PopularPage | null> {
  try {
    return await apiFetch<PopularPage>('/api/booking-codes/popular?limit=6');
  } catch {
    // The "try a code" list is a nicety, not the screen — if the API is unreachable the
    // form still works. A failed resolve, by contrast, is surfaced to the user.
    return null;
  }
}

export default async function DecodePage() {
  const popular = await getPopularCodes();

  return (
    <main className="flex flex-col gap-8">
      <header className="flex flex-col gap-2">
        <h1 className="type-h1 text-text-primary">Decode a booking code</h1>
        <p className="type-body text-text-secondary">
          Paste a Betway Nigeria booking code to see everything it contains.
        </p>
      </header>

      <DecodeForm />

      {popular && popular.codes.length > 0 && <PopularCodes codes={popular.codes} />}
    </main>
  );
}
