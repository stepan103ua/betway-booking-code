import Link from 'next/link';
import { buttonVariants } from '@/components/ui/button';
import { DashedBorder } from '@/components/ui/dashed-border';

export default function NotFound() {
  return (
    <main className="flex flex-col gap-4">
      <h1 className="type-h1 text-text-primary">Page not found</h1>
      <DashedBorder className="flex flex-col items-center gap-3 px-6 py-9 text-center">
        <p className="type-meta max-w-[280px] text-text-muted">
          That address doesn&apos;t point anywhere here.
        </p>
        <Link href="/" className={buttonVariants({ variant: 'secondary', size: 'sm' })}>
          Go to Decode
        </Link>
      </DashedBorder>
    </main>
  );
}
