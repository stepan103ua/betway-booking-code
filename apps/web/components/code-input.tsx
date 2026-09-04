'use client';

import type { ReactNode, Ref } from 'react';
import { Hash, ScanLine } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { isValidCode } from '@/lib/format';

/**
 * The code field, an inline Paste button, and the submit CTA. The `<form>` and what submit
 * does live in the parent (`decode-screen.tsx`, `convert-screen.tsx`).
 *
 * The `^BW[0-9A-F]{8}$` gate matches `apps/api`'s own validation. A looser client gate would
 * let `BWZZZZZZZZ` reach the server as a `400 invalid_request` — a more confusing failure
 * than the `404 invalid_code` this input exists to pre-empt.
 */
export function CodeInput({
  value,
  onChange,
  onPaste,
  error,
  loading,
  inputRef,
  label = 'Booking code',
  cta = 'Decode code',
  ctaIcon = <ScanLine className="size-[18px]" aria-hidden />,
}: {
  value: string;
  onChange: (next: string) => void;
  onPaste?: () => void;
  error?: string;
  loading: boolean;
  inputRef?: Ref<HTMLInputElement>;
  label?: string;
  cta?: string;
  ctaIcon?: ReactNode;
}) {
  const ready = isValidCode(value);

  return (
    <div className="flex flex-col gap-3">
      <Input
        ref={inputRef}
        name="code"
        label={label}
        mono
        required
        autoComplete="off"
        autoCapitalize="characters"
        spellCheck={false}
        maxLength={10}
        placeholder="BW6E19810C"
        value={value}
        onChange={(e) => onChange(e.target.value.toUpperCase())}
        icon={<Hash className="size-4" aria-hidden />}
        hint="BW + 8 characters, e.g. BW6E19810C"
        error={error}
        suffix={
          onPaste && (
            <Button type="button" variant="ghost" size="sm" onClick={onPaste}>
              Paste
            </Button>
          )
        }
      />
      <Button type="submit" size="lg" block loading={loading} disabled={!ready} icon={ctaIcon}>
        {cta}
      </Button>
    </div>
  );
}
