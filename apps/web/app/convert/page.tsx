import type { Metadata } from 'next';
import { ConvertScreen } from '@/components/convert/convert-screen';
import { isValidCode } from '@/lib/format';
import { type ResolveResult, resolveSlip } from '@/lib/resolve';

export const metadata: Metadata = { title: 'Convert — Betway Booking Code' };

/**
 * Convert — load a booking code, drop the legs you don't want (dead ones go automatically),
 * reissue it as a fresh code. `?code=` selects the code and is server-resolved here — the
 * same "URL is the state" choice Decode and Create make, and the target of Decode's "Rebuild
 * with N live legs" link (`/convert?code=…`). Dropping legs and the convert call are client
 * state / a Server Action.
 */
export default async function ConvertPage({
  searchParams,
}: {
  searchParams: Promise<{ code?: string }>;
}) {
  const raw = (await searchParams).code?.trim().toUpperCase();
  const code = raw ? raw : undefined;

  const resolve: ResolveResult | undefined =
    code === undefined
      ? undefined
      : isValidCode(code)
        ? await resolveSlip(code)
        : { kind: 'invalid' };

  return (
    <main>
      <ConvertScreen code={code} resolve={resolve} />
    </main>
  );
}
