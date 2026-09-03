'use client';

import { useActionState } from 'react';
import { type ResolveState, resolveCode } from '@/app/actions';
import { SlipCard } from '@/components/slip-card';
import { Alert } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

const INITIAL: ResolveState = {};

/**
 * `useActionState` gives pending state, error state and progressive enhancement (the form
 * still submits without JS) for free — the idiomatic React 19 / Next 16 pattern for this
 * shape of interaction (docs/frontend.md §3). Composition only: the `components/ui/`
 * primitives plus the action.
 */
export function DecodeForm() {
  const [state, formAction, isPending] = useActionState(resolveCode, INITIAL);

  return (
    <div className="flex flex-col gap-4">
      <form action={formAction} className="flex flex-col gap-2 sm:flex-row">
        <Input
          name="code"
          required
          mono
          autoCapitalize="characters"
          autoComplete="off"
          spellCheck={false}
          placeholder="BW + 8 characters"
          aria-label="Booking code"
          invalid={Boolean(state.error)}
          className="flex-1 uppercase placeholder:normal-case placeholder:tracking-normal"
        />
        <Button type="submit" size="lg" loading={isPending} className="h-[52px]">
          {isPending ? 'Resolving…' : 'Resolve'}
        </Button>
      </form>

      {state.error && <Alert tone="danger">{state.error}</Alert>}

      {state.slip && <SlipCard slip={state.slip} />}
    </div>
  );
}
