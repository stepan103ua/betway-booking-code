import { RotateCcw, WandSparkles } from 'lucide-react';
import { SelectionRow } from '@/components/selection-row';
import { Alert } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import type { CreateResult } from '@/lib/create';
import { type DraftPick, MAX_DRAFT, draftToSelection, draftTotalOdds } from '@/lib/draft';
import { formatOdds, pluralize } from '@/lib/format';

/**
 * The slip being built: the legs picked so far, a running total, and the generate action.
 * Rendered above the fixture list so a new pick and "Generate" are both in reach.
 */
export function DraftTray({
  picks,
  error,
  generating,
  onRemove,
  onClear,
  onGenerate,
  onRefreshEvents,
}: {
  picks: DraftPick[];
  error: Exclude<CreateResult, { kind: 'created' }> | undefined;
  generating: boolean;
  onRemove: (pick: DraftPick) => void;
  onClear: () => void;
  onGenerate: () => void;
  onRefreshEvents: () => void;
}) {
  const full = picks.length >= MAX_DRAFT;

  return (
    <Card padding="none" className="overflow-hidden">
      <div className="flex items-start justify-between gap-3 p-[14px] pb-3">
        <div>
          <p className="type-label text-text-muted">Your slip</p>
          <p className="type-meta mt-1.5 text-text-muted">{pluralize(picks.length, 'leg')}</p>
        </div>
        <div className="text-right">
          <p className="type-label text-text-muted">Total odds</p>
          <p key={picks.length} className="type-odds-hero mt-1 animate-rise text-odds-text">
            {formatOdds(draftTotalOdds(picks))}
          </p>
        </div>
      </div>

      <ul className="bg-surface-row">
        {picks.map((pick, i) => (
          <SelectionRow
            key={pick.outcomeId}
            className="animate-rise"
            selection={draftToSelection(pick)}
            index={i + 1}
            onRemove={() => onRemove(pick)}
          />
        ))}
      </ul>

      <div className="flex flex-col gap-3 p-[14px]">
        {error && (
          <div className="animate-rise">
            <GenerateError error={error} onRefreshEvents={onRefreshEvents} />
          </div>
        )}
        {full && (
          <p className="type-meta text-text-muted">
            Maximum {MAX_DRAFT} legs — remove one to add another.
          </p>
        )}
        <div className="flex gap-2">
          <Button
            variant="ghost"
            icon={<RotateCcw className="size-4" aria-hidden />}
            disabled={generating}
            onClick={onClear}
          >
            Clear
          </Button>
          <Button
            block
            loading={generating}
            icon={<WandSparkles className="size-4" aria-hidden />}
            onClick={onGenerate}
          >
            Generate code
          </Button>
        </div>
      </div>
    </Card>
  );
}

function GenerateError({
  error,
  onRefreshEvents,
}: {
  error: Exclude<CreateResult, { kind: 'created' }>;
  onRefreshEvents: () => void;
}) {
  if (error.kind === 'unavailable') {
    return (
      <Alert
        tone="warn"
        title="Some selections went off"
        action={
          <Button
            variant="secondary"
            size="sm"
            icon={<RotateCcw className="size-3.5" aria-hidden />}
            onClick={onRefreshEvents}
          >
            Refresh fixtures
          </Button>
        }
      >
        {error.message}
      </Alert>
    );
  }
  return (
    <Alert tone="danger" title="Couldn't generate a code">
      {error.message}
    </Alert>
  );
}
