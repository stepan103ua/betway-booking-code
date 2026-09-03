import { type CSSProperties } from 'react';
import { cn } from '@/lib/cn';

// design-system.md §1: skeletons, never spinners, for content — a loading slip renders the
// shape of the answer. Opacity pulse over the `skeleton` motion token (globals.css).
type SkeletonProps = {
  width?: number | string;
  height?: number | string;
  /** Tailwind radius class; defaults to the `tile` shape. */
  radius?: string;
  className?: string;
};

export function Skeleton({
  width,
  height = 12,
  radius = 'rounded-tile',
  className,
}: SkeletonProps) {
  const style: CSSProperties = {
    width: typeof width === 'number' ? `${width}px` : width,
    height: typeof height === 'number' ? `${height}px` : height,
  };
  return (
    <span
      aria-hidden
      style={style}
      className={cn('block bg-surface-skeleton animate-skeleton', radius, className)}
    />
  );
}

/** Stacked bars, the last one 62% width — a paragraph placeholder (design-system.md §4). */
export function SkeletonLines({ lines = 2, height = 12 }: { lines?: number; height?: number }) {
  return (
    <span className="flex flex-col gap-2">
      {Array.from({ length: lines }, (_, i) => (
        <Skeleton key={i} height={height} width={i === lines - 1 ? '62%' : '100%'} />
      ))}
    </span>
  );
}
