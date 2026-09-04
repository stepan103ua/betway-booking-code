import { type HTMLAttributes, type ReactNode } from 'react';
import { type VariantProps, cva } from 'class-variance-authority';
import { Check, Clock, Info, TriangleAlert } from 'lucide-react';
import { cn } from '@/lib/cn';

// design-system.md §4: tones danger · warn · info · success. Icon + title + body + optional
// action. `danger` is an ARIA live region. The copy passed in must name the fix (§1) — the
// component does not enforce that.
const alert = cva('flex gap-3 rounded-control border p-3.5', {
  variants: {
    tone: {
      danger: 'border-danger-solid bg-danger-quiet text-danger-text',
      warn: 'border-warn-solid bg-warn-quiet text-warn-text',
      info: 'border-info-text bg-info-quiet text-info-text',
      success: 'border-accent-solid bg-accent-quiet text-accent-text',
    },
  },
  defaultVariants: { tone: 'info' },
});

const toneIcon = {
  danger: TriangleAlert,
  warn: Clock,
  info: Info,
  success: Check,
} as const;

type AlertProps = Omit<HTMLAttributes<HTMLDivElement>, 'title'> &
  VariantProps<typeof alert> & {
    title?: ReactNode;
    action?: ReactNode;
  };

export function Alert({ className, tone = 'info', title, action, children, ...props }: AlertProps) {
  const Icon = toneIcon[tone ?? 'info'];
  return (
    <div
      role={tone === 'danger' ? 'alert' : 'status'}
      aria-live={tone === 'danger' ? 'assertive' : 'polite'}
      className={cn(alert({ tone }), className)}
      {...props}
    >
      <Icon className="mt-px size-4 shrink-0" aria-hidden />
      <div className="flex flex-col gap-1">
        {title && <p className="type-body-strong">{title}</p>}
        {children && (
          <div className="type-meta text-text-secondary [&_a]:underline">{children}</div>
        )}
        {action && <div className="mt-1.5 flex flex-wrap gap-2">{action}</div>}
      </div>
    </div>
  );
}
