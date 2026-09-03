'use client';

import type { Ref } from 'react';
import { Hash, ScanLine } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { isValidCode } from '@/lib/format';

/**
 * The entry point of the whole product: paste a code, decode it. The `<form>` and its action
 * live in the parent (`decode-screen.tsx`) so `useActionState` can own submission — this is
 * the visual composition: the code field, an inline Paste button, and the submit CTA.
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
}: {
  value: string;
  onChange: (next: string) => void;
  onPaste?: () => void;
  error?: string;
  loading: boolean;
  inputRef?: Ref<HTMLInputElement>;
}) {
  const ready = isValidCode(value);

  return (
    <div className="flex flex-col gap-3">
      <Input
        ref={inputRef}
        name="code"
        label="Booking code"
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
      <Button
        type="submit"
        size="lg"
        block
        loading={loading}
        disabled={!ready}
        icon={<ScanLine className="size-[18px]" aria-hidden />}
      >
        Decode code
      </Button>
    </div>
  );
}
