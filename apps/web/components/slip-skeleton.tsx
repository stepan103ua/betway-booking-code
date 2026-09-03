import { Card } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';

/** The loading state for a slip — the shape of the answer, never a spinner (design-system.md §1). */
export function SlipSkeleton({ rows = 5 }: { rows?: number }) {
  return (
    <Card padding="none" className="overflow-hidden">
      <div className="flex flex-col gap-3.5 p-[14px] pt-4">
        <div className="flex items-start justify-between gap-3">
          <div className="flex flex-col gap-2">
            <Skeleton width={72} height={9} />
            <Skeleton width={150} height={24} radius="rounded-control" />
          </div>
          <div className="flex flex-col items-end gap-2">
            <Skeleton width={60} height={9} />
            <Skeleton width={96} height={30} radius="rounded-control" />
          </div>
        </div>
        <div className="flex gap-2">
          <Skeleton width={64} height={20} />
          <Skeleton width={88} height={20} />
          <Skeleton width={76} height={20} />
        </div>
      </div>

      <ul className="bg-surface-row">
        {Array.from({ length: rows }, (_, i) => (
          <li key={i} className="flex gap-3 border-t border-border-subtle px-[14px] py-3">
            <div className="flex-1 space-y-2">
              <Skeleton height={12} />
              <div className="flex gap-1.5">
                <Skeleton width={52} height={16} />
                <Skeleton width={84} height={16} />
              </div>
              <Skeleton width="46%" height={10} />
            </div>
            <Skeleton width={46} height={16} className="mt-0.5" />
          </li>
        ))}
      </ul>
    </Card>
  );
}
