import type { ApiError } from '@booking-code/contracts';

/**
 * The thin fetch wrapper (docs/frontend.md §5): base URL, JSON headers, error unwrapping.
 * The only place `fetch` names the Express API. Runs server-side only — Server Components
 * and Server Actions — so it reads `API_URL`, not `NEXT_PUBLIC_API_URL`.
 */
const BASE_URL = process.env.API_URL ?? 'http://localhost:3000';

/**
 * A non-2xx from the API. The API's contract guarantees every error body is `ApiError`
 * (`{ error, message }`), so `code` is safe to branch on and `message` is safe to render.
 */
export class ApiRequestError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = 'ApiRequestError';
  }
}

export async function apiFetch<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE_URL}${path}`, {
    ...init,
    headers: { 'Content-Type': 'application/json', ...init?.headers },
    // Live odds — never serve a cached copy (docs/frontend.md §3). This is also Next 15+'s
    // default for a plain fetch; stated here so it survives a config change.
    cache: 'no-store',
  });

  const body: unknown = await res.json().catch(() => null);

  if (!res.ok) {
    const err = (body ?? {}) as Partial<ApiError>;
    throw new ApiRequestError(
      res.status,
      err.error ?? 'unknown',
      err.message ?? `Request to ${path} failed (${res.status}).`,
    );
  }

  return body as T;
}
