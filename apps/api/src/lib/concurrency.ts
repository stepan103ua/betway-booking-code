/**
 * Run an async function over a list, a bounded number at a time.
 *
 * The only place in this service that fans out, and it exists for one endpoint: the popular
 * codes list needs one decode per code, and doing those sequentially is several seconds while
 * doing them all at once points a burst at Betway that the rate limiter exists to prevent.
 *
 * Chunked rather than a rolling worker pool. A pool keeps the pipe fuller when call durations
 * vary, but it is twice the code for a list of about ten items; `CLAUDE.md`'s anti-goals call
 * for the boring version until the difference is measurable.
 *
 * Rejections are not caught here — the caller decides what a failure means, and for popular
 * codes a single failure is expected and dropped.
 */
export async function mapLimited<T, R>(
  items: readonly T[],
  limit: number,
  fn: (item: T) => Promise<R>,
): Promise<R[]> {
  const results: R[] = [];

  for (let i = 0; i < items.length; i += limit) {
    results.push(...(await Promise.all(items.slice(i, i + limit).map(fn))));
  }

  return results;
}
