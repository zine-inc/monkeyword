export interface Config {
  apiKey: string | null;
  apiUrl: string;
  mock: boolean;
}

const DEFAULT_API_URL = 'https://api.monkeyword.1stop.direct';

export function loadConfig(env: NodeJS.ProcessEnv = process.env): Config {
  const rawKey = typeof env.MONKEYWORD_API_KEY === 'string' ? env.MONKEYWORD_API_KEY.trim() : '';
  const rawUrl = typeof env.MONKEYWORD_API_URL === 'string' ? env.MONKEYWORD_API_URL.trim() : '';
  const rawMock = typeof env.MONKEYWORD_MOCK === 'string' ? env.MONKEYWORD_MOCK.trim().toLowerCase() : '';

  return {
    apiKey: rawKey.length > 0 ? rawKey : null,
    apiUrl: (rawUrl.length > 0 ? rawUrl : DEFAULT_API_URL).replace(/\/+$/, ''),
    mock: rawMock === '1' || rawMock === 'true' || rawMock === 'yes',
  };
}
