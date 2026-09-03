import { type HTMLAttributes } from 'react';
import { cn } from '@/lib/cn';

// design-system.md §1: a dashed border means "the thing to take away" — generated-code
// frames, empty slots, the "no slip yet" placeholder. The one non-solid stroke in the
// system, carrying that single meaning. On web it is simply `border-style: dashed`.
export function DashedBorder({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn('rounded-card border border-dashed border-border-dashed', className)}
      {...props}
    />
  );
}
