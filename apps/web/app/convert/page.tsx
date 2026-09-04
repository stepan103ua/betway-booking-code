import Link from 'next/link';
import { buttonVariants } from '@/components/ui/button';
import { DashedBorder } from '@/components/ui/dashed-border';

/**
 * Placeholder. Convert is designed (docs/frontend.md §2) but not built — this exists so
 * Decode's "Rebuild with N live legs" has a real target instead of a 404. It reads the
 * `?code=` that Decode hands over so the wiring is already in place for the real screen.
 */
export default async function ConvertPage({
  searchParams,
}: {
  searchParams: Promise<{ code?: string }>;
}) {
  const { code } = await searchParams;

  return (
    <main className="flex animate-rise flex-col gap-4">
      <h1 className="type-h1 text-text-primary">Convert</h1>
      <DashedBorder className="flex flex-col items-center gap-3 px-6 py-9 text-center">
        <p className="type-h3 text-text-primary">Not built yet</p>
        <p className="type-meta max-w-[280px] text-text-muted">
          Convert drops the dead legs from a code and reissues it.
          {code ? ` Decode sent over ${code}.` : ''}
        </p>
        <Link href="/" className={buttonVariants({ variant: 'secondary', size: 'sm' })}>
          Back to Decode
        </Link>
      </DashedBorder>
    </main>
  );
}
