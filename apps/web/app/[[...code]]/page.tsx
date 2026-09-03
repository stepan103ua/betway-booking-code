import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import type { PopularPage } from '@booking-code/contracts';
import { DecodeScreen } from '@/components/decode-screen';
import { apiFetch } from '@/lib/api';
import { isValidCode } from '@/lib/format';
import { POPULAR_PAGE } from '@/lib/popular';
import { type ResolveResult, resolveSlip } from '@/lib/resolve';

/**
 * Decode — served at `/` (empty) and at `/<code>` (resolved). One optional-catch-all route
 * rather than `page.tsx` + `[code]/page.tsx` so `DecodeScreen` stays mounted as the URL
 * changes between codes: the popular-list pagination and the input survive a "decode
 * another".
 *
 * Deviation from docs/frontend.md §3, which resolves via a Server Action + `useActionState`:
 * a decoded slip on a URL is a shareable link (the point of this route), so resolving *is* a
 * navigation here, and the form trades no-JS progressive enhancement for that.
 *
 * A single malformed segment (`/nonsense`) is a code attempt that fails the shape check — it
 * renders the friendly "we can't read that" screen, not a 404. Only a multi-segment path
 * (`/a/b/c`), which cannot be a code at all, is `notFound()`.
 */
type Params = { code?: string[] };

function codeParam(segments: string[] | undefined): string | undefined {
  const first = segments?.[0]?.trim().toUpperCase();
  return first ? first : undefined;
}

export async function generateMetadata({ params }: { params: Promise<Params> }): Promise<Metadata> {
  const code = codeParam((await params).code);
  return code && isValidCode(code)
    ? { title: `${code} — Betway Booking Code` }
    : { title: 'Betway Booking Code' };
}

async function firstPopularPage(): Promise<PopularPage | null> {
  try {
    return await apiFetch<PopularPage>(`/api/booking-codes/popular?limit=${POPULAR_PAGE}`);
  } catch {
    return null;
  }
}

export default async function DecodePage({ params }: { params: Promise<Params> }) {
  const segments = (await params).code;
  if (segments && segments.length > 1) notFound();

  const code = codeParam(segments);

  // Parallel — the popular list never blocks on the decode (docs/frontend.md §3).
  const [popular, result] = await Promise.all([firstPopularPage(), resolveFor(code)]);

  return (
    <main className="flex flex-col gap-5">
      <header className="flex flex-col gap-1.5">
        <h1 className="type-h1 text-text-primary">Decode a booking code</h1>
        <p className="type-body text-text-secondary">
          Paste a Betway Nigeria booking code to see everything it contains.
        </p>
      </header>

      <DecodeScreen code={code} result={result} firstPopularPage={popular} />
    </main>
  );
}

function resolveFor(code: string | undefined): Promise<ResolveResult | undefined> {
  if (code === undefined) return Promise.resolve(undefined);
  if (!isValidCode(code)) return Promise.resolve<ResolveResult>({ kind: 'invalid' });
  return resolveSlip(code);
}
