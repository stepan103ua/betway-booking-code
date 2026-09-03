import { type InputHTMLAttributes, type ReactNode, type Ref, useId } from 'react';
import { type VariantProps, cva } from 'class-variance-authority';
import { TriangleAlert } from 'lucide-react';
import { cn } from '@/lib/cn';

// design-system.md §4: sm (h36) · md (h44) · lg (h52, default). Border is danger when
// invalid, accent when focused, else borderInput. `mono` switches to the code face. The
// uppercase-the-stored-value transform for the code preset is the composing feature's job
// (CodeInput), not this primitive's.
const field = cva(
  'flex items-center gap-2.5 rounded-control border bg-surface-input px-3.5 transition-colors duration-[120ms] focus-within:border-accent-solid',
  {
    variants: {
      inputSize: { sm: 'h-9', md: 'h-11', lg: 'h-[52px]' },
      invalid: { true: 'border-danger-solid', false: 'border-border-input' },
    },
    defaultVariants: { inputSize: 'lg', invalid: false },
  },
);

type InputProps = Omit<InputHTMLAttributes<HTMLInputElement>, 'size' | 'prefix'> &
  VariantProps<typeof field> & {
    label?: string;
    hint?: string;
    error?: string;
    /** Leading glyph inside the box. */
    icon?: ReactNode;
    /** Trailing control inside the box (e.g. a Paste button). */
    suffix?: ReactNode;
    mono?: boolean;
    ref?: Ref<HTMLInputElement>;
  };

export function Input({
  className,
  inputSize,
  invalid,
  label,
  hint,
  error,
  icon,
  suffix,
  mono = false,
  id,
  ref,
  ...props
}: InputProps) {
  const autoId = useId();
  const inputId = id ?? autoId;
  const isInvalid = invalid ?? Boolean(error);
  const describedBy = error ? `${inputId}-error` : hint ? `${inputId}-hint` : undefined;

  return (
    <div className="flex flex-col gap-1.5">
      {label && (
        <label htmlFor={inputId} className="type-label text-text-muted">
          {label}
        </label>
      )}
      <div className={cn(field({ inputSize, invalid: isInvalid }), className)}>
        {icon && <span className="shrink-0 text-text-muted">{icon}</span>}
        <input
          ref={ref}
          id={inputId}
          aria-invalid={isInvalid || undefined}
          aria-describedby={describedBy}
          className={cn(
            'w-full bg-transparent text-text-primary outline-none placeholder:text-text-disabled',
            mono ? 'type-code-hero !text-[18px]' : 'type-body',
          )}
          {...props}
        />
        {suffix}
      </div>
      {error ? (
        <p id={`${inputId}-error`} className="type-meta flex items-center gap-1.5 text-danger-text">
          <TriangleAlert className="size-3.5 shrink-0" aria-hidden />
          {error}
        </p>
      ) : (
        hint && (
          <p id={`${inputId}-hint`} className="type-meta text-text-muted">
            {hint}
          </p>
        )
      )}
    </div>
  );
}
