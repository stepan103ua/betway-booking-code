import { Skeleton } from '@/components/ui/skeleton';

/**
 * Whole-page navigation loading — the Suspense boundary Next.js wraps around `page.tsx`.
 * Partial in-component states (a resolving form) are driven by `isPending`, not this
 * (docs/frontend.md §6). Skeletons, never spinners, for content (design-system.md §1).
 */
export default function Loading() {
  return (
    <div className="flex flex-col gap-4">
      <Skeleton width={256} height={32} />
      <Skeleton height={52} radius="rounded-control" />
    </div>
  );
}
