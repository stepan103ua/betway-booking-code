'use client';

import { type ReactNode, useRef, useState, useTransition } from 'react';
import { useRouter } from 'next/navigation';
import type { PopularPage } from '@booking-code/contracts';
import { Clipboard, RotateCcw, ShieldCheck } from 'lucide-react';
import { CodeInput } from '@/components/code-input';
import { PopularCodes } from '@/components/popular-codes';
import { ShareDialog } from '@/components/share-dialog';
import { SlipCard } from '@/components/slip-card';
import { SlipFooter } from '@/components/slip-footer';
import { SlipSkeleton } from '@/components/slip-skeleton';
import { Alert } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { isValidCode } from '@/lib/format';
import type { ResolveResult } from '@/lib/resolve';

const INVALID_HELP =
  'Codes are BW followed by 8 characters — like BW6E19810C. Check for an O typed as a 0, and drop any spaces.';
const COPIED_MS = 1600;

/**
 * Decode's whole client surface. The URL is the source of truth: `/` is empty, `/<code>` is
 * a resolved slip (server-rendered, shareable). Submitting, "Decode another", and picking a
 * popular code are all navigations; the result comes down as a prop, already resolved.
 */
export function DecodeScreen({
  code,
  result,
  firstPopularPage,
}: {
  code: string | undefined;
  result: ResolveResult | undefined;
  firstPopularPage: PopularPage | null;
}) {
  const router = useRouter();
  const [input, setInput] = useState(code ?? '');
  const [navigating, startNav] = useTransition();
  const [copied, setCopied] = useState(false);
  const [shareOpen, setShareOpen] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);
  const copyTimer = useRef<ReturnType<typeof setTimeout> | undefined>(undefined);

  // Snap the field to the URL when it changes under us — a popular-tile decode, "Decode
  // another", the back button. Adjusting state during render (not in an effect) is React's
  // pattern for "reset some state when a prop changes" without an extra paint.
  const [urlCode, setUrlCode] = useState(code);
  if (code !== urlCode) {
    setUrlCode(code);
    setInput(code ?? '');
  }

  const slip = result?.kind === 'slip' ? result.slip : undefined;

  function go(target: string) {
    startNav(() => router.push(target));
  }

  function submit(e: React.FormEvent) {
    e.preventDefault();
    const next = input.trim().toUpperCase();
    if (isValidCode(next)) go(`/${next}`);
  }

  async function paste() {
    try {
      const text = (await navigator.clipboard.readText()).trim().toUpperCase();
      if (text) setInput(text);
    } catch {
      // Clipboard read denied or unavailable — a convenience, not worth surfacing.
    }
  }

  function copy(text: string) {
    void navigator.clipboard?.writeText(text).catch(() => {});
    setCopied(true);
    clearTimeout(copyTimer.current);
    copyTimer.current = setTimeout(() => setCopied(false), COPIED_MS);
  }

  function renderResult(): { key: string; node: ReactNode } | null {
    if (navigating) return { key: 'pending', node: <SlipSkeleton rows={5} /> };

    if (slip) {
      return {
        key: `slip-${slip.bookingCode}`,
        node: (
          <>
            <SlipCard
              code={slip.bookingCode}
              totalOdds={slip.totalOdds}
              selections={slip.selections}
              expiresAt={slip.expiresAt}
              usageCount={slip.usageCount}
              collapsedCount={5}
              onCopy={() => copy(slip.bookingCode)}
              footer={
                <SlipFooter
                  slip={slip}
                  copied={copied}
                  onCopy={() => copy(slip.bookingCode)}
                  onShare={() => setShareOpen(true)}
                />
              }
            />
            <div className="flex items-center justify-between gap-3">
              <p className="type-meta flex items-center gap-2 text-text-disabled">
                <ShieldCheck className="size-3.5" aria-hidden />
                Read-only. We never place bets for you.
              </p>
              <Button
                variant="ghost"
                size="sm"
                icon={<RotateCcw className="size-3.5" aria-hidden />}
                onClick={() => go('/')}
              >
                Decode another
              </Button>
            </div>
          </>
        ),
      };
    }

    if (result?.kind === 'invalid') {
      return {
        key: 'invalid',
        node: (
          <Alert
            tone="danger"
            title="We can't read that code"
            action={
              <>
                <Button
                  variant="secondary"
                  size="sm"
                  icon={<RotateCcw className="size-3.5" aria-hidden />}
                  onClick={() => go('/')}
                >
                  Clear
                </Button>
                <Button
                  variant="ghost"
                  size="sm"
                  icon={<Clipboard className="size-3.5" aria-hidden />}
                  onClick={paste}
                >
                  Paste again
                </Button>
              </>
            }
          >
            {INVALID_HELP}
          </Alert>
        ),
      };
    }

    if (result?.kind === 'transport') {
      return {
        key: 'transport',
        node: (
          <Alert
            tone="danger"
            title="Something went wrong"
            action={
              <Button
                variant="secondary"
                size="sm"
                icon={<RotateCcw className="size-3.5" aria-hidden />}
                onClick={() => startNav(() => router.refresh())}
              >
                Try again
              </Button>
            }
          >
            {result.message}
          </Alert>
        ),
      };
    }

    return null;
  }

  const rendered = renderResult();
  const showEmptyIntro = !rendered;

  return (
    <div className="flex animate-rise flex-col gap-4 pb-6">
      <form onSubmit={submit}>
        <CodeInput
          inputRef={inputRef}
          value={input}
          onChange={setInput}
          onPaste={paste}
          loading={navigating}
          error={result?.kind === 'invalid' ? "That's not a code we can read." : undefined}
        />
      </form>

      {rendered && (
        <div key={rendered.key} className="flex animate-rise flex-col gap-4">
          {rendered.node}
        </div>
      )}

      <div className="flex flex-col gap-4">
        {showEmptyIntro && (
          <Alert tone="info" title="Paste any Betway booking code" className="animate-rise">
            You&apos;ll see every selection, the market, the odds and whether the slip is still live
            — before you stake anything.
          </Alert>
        )}
        <PopularCodes
          firstPage={firstPopularPage}
          onUse={(c) => go(`/${c}`)}
          excludeCode={slip?.bookingCode}
          heading={slip ? 'Try another code' : 'Popular codes'}
        />
      </div>

      {slip && (
        <ShareDialog
          open={shareOpen}
          onClose={() => setShareOpen(false)}
          code={slip.bookingCode}
          totalOdds={slip.totalOdds}
        />
      )}
    </div>
  );
}
