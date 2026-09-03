import { type HTMLAttributes, type ReactNode } from 'react';
import { type VariantProps, cva } from 'class-variance-authority';
import { cn } from '@/lib/cn';

// design-system.md §4: tones danger · warn · info · success. Icon + title + body + optional
// action. `danger` is an ARIA live region. The copy passed in must name the fix (§1) — the
// component does not enforce that.
const alert = cva('flex gap-3 rounded-tile border border-border-subtle p-4', {
  variants: {
    tone: {
      danger: 'bg-danger-quiet text-danger-text',
      warn: 'bg-warn-quiet text-warn-text',
      info: 'bg-info-quiet text-info-text',
      success: 'bg-accent-quiet text-accent-text',
    },
  },
  defaultVariants: { tone: 'info' },
});

type AlertProps = Omit<HTMLAttributes<HTMLDivElement>, 'title'> &
  VariantProps<typeof alert> & {
    title?: ReactNode;
    /** Lucide glyph (design-system.md §3); optional until the icon set is wired. */
    icon?: ReactNode;
    action?: ReactNode;
  };

export function Alert({
  className,
  tone = 'info',
  title,
  icon,
  action,
  children,
  ...props
}: AlertProps) {
  return (
    <div
      role={tone === 'danger' ? 'alert' : 'status'}
      aria-live={tone === 'danger' ? 'assertive' : 'polite'}
      className={cn(alert({ tone }), className)}
      {...props}
    >
      {icon && (
        <span aria-hidden className="mt-0.5 shrink-0">
          {icon}
        </span>
      )}
      <div className="flex flex-col gap-1">
        {title && <p className="type-body-strong">{title}</p>}
        {children && <div className="type-body">{children}</div>}
        {action && <div className="mt-1">{action}</div>}
      </div>
    </div>
  );
}
