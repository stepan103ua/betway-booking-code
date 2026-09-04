'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Repeat, ScanLine, WandSparkles } from 'lucide-react';
import { cn } from '@/lib/cn';

// design-system.md §4: the segmented mode switch (Decode / Create / Convert) — a pill
// container on `surfaceSunken`, the active segment lifted to `surfaceRaised` + `borderStrong`.
// This is "which job", not "which app section" — deliberately not a bottom nav.
const TABS = [
  {
    href: '/',
    label: 'Decode',
    Icon: ScanLine,
    match: (p: string) => p === '/' || /^\/BW/i.test(p),
  },
  {
    href: '/create',
    label: 'Create',
    Icon: WandSparkles,
    match: (p: string) => p.startsWith('/create'),
  },
  {
    href: '/convert',
    label: 'Convert',
    Icon: Repeat,
    match: (p: string) => p.startsWith('/convert'),
  },
] as const;

export function ModeTabs() {
  const pathname = usePathname();

  return (
    <nav className="flex gap-1 rounded-pill bg-surface-sunken p-1">
      {TABS.map(({ href, label, Icon, match }) => {
        const active = match(pathname);
        return (
          <Link
            key={href}
            href={href}
            aria-current={active ? 'page' : undefined}
            className={cn(
              'type-body-strong flex h-10 flex-1 items-center justify-center gap-1.5 rounded-pill text-[13px] transition-colors',
              active
                ? 'border border-border-strong bg-surface-raised text-text-primary'
                : 'text-text-muted hover:text-text-secondary',
            )}
          >
            <Icon className="size-4" aria-hidden />
            {label}
          </Link>
        );
      })}
    </nav>
  );
}
