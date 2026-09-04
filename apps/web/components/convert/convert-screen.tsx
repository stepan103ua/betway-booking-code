'use client';

import { type ReactNode, useRef, useState, useTransition } from 'react';
import { useRouter } from 'next/navigation';
import { Repeat, RotateCcw } from 'lucide-react';
import { CodeInput } from '@/components/code-input';
import { ConvertLegRow } from '@/components/convert/convert-leg-row';
import { ConvertResultView } from '@/components/convert/convert-result-view';
import { DiffSummary } from '@/components/convert/diff-summary';
import { SlipSkeleton } from '@/components/slip-skeleton';
import { Alert } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import type { ConvertActionResult } from '@/lib/convert';
import { convertPreview } from '@/lib/convert-preview';
import { isValidCode } from '@/lib/format';
import type { ResolveResult } from '@/lib/resolve';
import { convert } from '@/app/actions';

const INTRO =
  "Load any booking code, drop the selections you no longer want — we'll remove ones that can't be bet anyway — and get a fresh code for what is left.";
const CODE_INPUT_PROPS = {
  label: 'Booking code to convert',
  cta: 'Load code',
  ctaIcon: <Repeat className="size-[18px]" aria-hidden />,
} as const;

/**
 * Convert's whole client surface — the port of apps/mobile's `ConvertScreen` + its cubit.
 * `?code=` is server-resolved by the route; dropping legs is local state and the convert
 * call is the `convert` Server Action in a transition. Load / Change / Convert-another are
 * all navigations, the same "URL is the state" shape Decode and Create use.
 */
export function ConvertScreen({
  code,
  resolve,
}: {
  code: string | undefined;
  resolve: ResolveResult | undefined;
}) {
  const router = useRouter();
  const [input, setInput] = useState(code ?? '');
  const [drops, setDrops] = useState<Set<string>>(new Set());
  const [outcome, setOutcome] = useState<ConvertActionResult | null>(null);
  const [loadingCode, setLoadingCode] = useState(false);
  const [navigating, startNav] = useTransition();
  const [converting, startConvert] = useTransition();
  const inputRef = useRef<HTMLInputElement>(null);

  // Snap to the URL when it changes under us (loaded a code, hit "Change", back button).
  const [urlCode, setUrlCode] = useState(code);
  if (code !== urlCode) {
    setUrlCode(code);
    setInput(code ?? '');
    setDrops(new Set());
    setOutcome(null);
    setLoadingCode(false);
  }

  const original = resolve?.kind === 'slip' ? resolve.slip : undefined;
  const converted = outcome?.kind === 'converted' ? outcome.result : undefined;
  const convertError = outcome && outcome.kind !== 'converted' ? outcome : undefined;

  function go(target: string) {
    startNav(() => router.push(target));
  }

  function submit(e: React.FormEvent) {
    e.preventDefault();
    const next = input.trim().toUpperCase();
    if (!isValidCode(next)) return;
    setLoadingCode(true);
    go(`/convert?code=${next}`);
  }

  async function paste() {
    try {
      const text = (await navigator.clipboard.readText()).trim().toUpperCase();
      if (text) setInput(text);
    } catch {
      // Clipboard read denied or unavailable — a convenience, not worth surfacing.
    }
  }

  function toggleDrop(outcomeId: string) {
    setOutcome(null);
    setDrops((current) => {
      const next = new Set(current);
      if (!next.delete(outcomeId)) next.add(outcomeId);
      return next;
    });
  }

  function runConvert() {
    if (!original) return;
    startConvert(async () => {
      setOutcome(await convert(original.bookingCode, [...drops]));
    });
  }

  const phase = renderPhase();

  function renderPhase(): { key: string; node: ReactNode } {
    if (navigating && loadingCode) {
      return {
        key: 'resolving',
        node: (
          <>
            <CodeInput {...CODE_INPUT_PROPS} value={input} onChange={setInput} loading />
            <SlipSkeleton rows={5} />
          </>
        ),
      };
    }

    if (original && converted) {
      return {
        key: `result-${converted.bookingCode}`,
        node: <ConvertResultView result={converted} onConvertAnother={() => go('/convert')} />,
      };
    }

    if (original) {
      const preview = convertPreview(original.selections, drops);
      return {
        key: 'picker',
        node: (
          <>
            <div className="flex items-start justify-between gap-3">
              <div className="min-w-0">
                <p className="type-label text-text-muted">Converting</p>
                <p className="type-code-hero mt-1 truncate text-[20px] text-code-text">
                  {original.bookingCode}
                </p>
              </div>
              <Button
                variant="ghost"
                size="sm"
                icon={<RotateCcw className="size-3.5" aria-hidden />}
                onClick={() => go('/convert')}
              >
                Change
              </Button>
            </div>

            <DiffSummary original={original} drops={drops} />

            <div className="flex flex-col gap-2.5">
              <h2 className="type-label text-text-muted">Selections</h2>
              <Card padding="none" className="overflow-hidden">
                <ul className="bg-surface-row">
                  {original.selections.map((s) => (
                    <ConvertLegRow
                      key={s.outcomeId}
                      className="animate-rise"
                      selection={s}
                      dropped={!s.isActive || drops.has(s.outcomeId)}
                      onToggle={s.isActive ? () => toggleDrop(s.outcomeId) : undefined}
                    />
                  ))}
                </ul>
              </Card>
            </div>

            {convertError && (
              <div className="animate-rise">
                <ConvertErrorAlert error={convertError} />
              </div>
            )}

            {!preview.canConvert && (
              <p className="type-meta text-text-muted">
                {preview.allDead
                  ? 'Every leg in this code is dead — there is nothing to rebuild.'
                  : 'Keep at least one leg to convert.'}
              </p>
            )}

            <Button
              size="lg"
              block
              loading={converting}
              disabled={!preview.canConvert}
              icon={<Repeat className="size-[18px]" aria-hidden />}
              onClick={runConvert}
            >
              Convert to a new code
            </Button>
          </>
        ),
      };
    }

    // No code yet, or a resolve error — back to the input.
    return {
      key: 'input',
      node: (
        <>
          <form onSubmit={submit}>
            <CodeInput
              {...CODE_INPUT_PROPS}
              inputRef={inputRef}
              value={input}
              onChange={setInput}
              onPaste={paste}
              loading={false}
              error={resolve?.kind === 'invalid' ? "That's not a code we can read." : undefined}
            />
          </form>
          {resolve?.kind === 'transport' ? (
            <Alert
              tone="danger"
              title="Something went wrong"
              action={
                <Button
                  variant="secondary"
                  size="sm"
                  icon={<RotateCcw className="size-3.5" aria-hidden />}
                  onClick={() => go('/convert')}
                >
                  Clear
                </Button>
              }
            >
              {resolve.message}
            </Alert>
          ) : (
            <Alert tone="info" title="Rebuild a slip without its dead legs">
              {INTRO}
            </Alert>
          )}
        </>
      ),
    };
  }

  return (
    <div className="flex animate-rise flex-col gap-4 pb-6">
      <div key={phase.key} className="flex animate-rise flex-col gap-4">
        {phase.node}
      </div>
    </div>
  );
}

function ConvertErrorAlert({
  error,
}: {
  error: Exclude<ConvertActionResult, { kind: 'converted' }>;
}) {
  const title =
    error.kind === 'empty'
      ? 'Nothing left to convert'
      : error.kind === 'unavailable'
        ? 'Some selections went off'
        : error.kind === 'conflicting'
          ? 'Two legs are on the same match'
          : "Couldn't convert";
  return (
    <Alert tone={error.kind === 'error' ? 'danger' : 'warn'} title={title}>
      {error.message}
    </Alert>
  );
}
