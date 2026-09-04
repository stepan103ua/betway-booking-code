import { type ReactNode } from 'react';
import { DashedBorder } from '@/components/ui/dashed-border';

/**
 * design-system.md §4: a dashed frame around a centred icon, an `h3` title, a `meta` body
 * and an optional action. "No slip yet" / "no selections yet".
 */
export function EmptyState({
  icon,
  title,
  body,
  action,
}: {
  icon: ReactNode;
  title: string;
  body?: string;
  action?: ReactNode;
}) {
  return (
    <DashedBorder className="flex flex-col items-center gap-2.5 px-6 py-9 text-center">
      <span className="text-text-disabled">{icon}</span>
      <p className="type-h3 text-text-primary">{title}</p>
      {body && <p className="type-meta max-w-[280px] leading-[1.55] text-text-muted">{body}</p>}
      {action && <div className="mt-1.5">{action}</div>}
    </DashedBorder>
  );
}
