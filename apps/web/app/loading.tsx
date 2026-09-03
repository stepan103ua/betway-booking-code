/**
 * Whole-page navigation loading — the Suspense boundary Next.js wraps around `page.tsx`.
 * Partial in-component states (a resolving form) are driven by `isPending`, not this
 * (docs/frontend.md §6). Skeletons, never spinners, for content (design-system.md §1).
 */
export default function Loading() {
  return (
    <div className="flex flex-col gap-4">
      <div className="h-8 w-64 animate-pulse rounded-tile bg-surface-skeleton" />
      <div className="h-[52px] w-full animate-pulse rounded-control bg-surface-skeleton" />
    </div>
  );
}
