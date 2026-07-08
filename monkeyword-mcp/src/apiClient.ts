export type FetchLike = typeof fetch;

export interface ApiClientOptions {
  apiUrl: string;
  apiKey: string;
  fetchImpl?: FetchLike;
}

export class MonkeywordApiError extends Error {
  readonly status: number;

  constructor(status: number, message: string) {
    super(message);
    this.name = 'MonkeywordApiError';
    this.status = status;
  }
}

async function readErrorMessage(res: Response): Promise<string> {
  try {
    const body = (await res.json()) as { message?: unknown; error?: unknown };
    if (typeof body.message === 'string') {
      return body.message;
    }
    if (typeof body.error === 'string') {
      return body.error;
    }
  } catch {
    return '';
  }
  return '';
}

export async function callApi<T>(
  path: string,
  body: unknown,
  options: ApiClientOptions,
): Promise<T> {
  const fetchImpl = options.fetchImpl ?? fetch;
  const res = await fetchImpl(`${options.apiUrl}${path}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${options.apiKey}`,
    },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const detail = await readErrorMessage(res);
    throw new MonkeywordApiError(res.status, detail.length > 0 ? detail : `HTTP ${res.status}`);
  }

  return (await res.json()) as T;
}
