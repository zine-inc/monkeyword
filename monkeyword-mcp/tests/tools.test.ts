import { describe, expect, it, vi } from 'vitest';
import { loadConfig } from '../src/config.js';
import { LLMO_SHINDAN_URL } from '../src/messages.js';
import {
  aeoAuditLite,
  keywordIntent,
  parseLocale,
  rankGsc,
  suggestKeywords,
  type TextResult,
} from '../src/tools.js';

function parsePayload(result: TextResult): Record<string, unknown> {
  return JSON.parse(result.content[0].text) as Record<string, unknown>;
}

const mockConfig = loadConfig({ MONKEYWORD_MOCK: '1' } as NodeJS.ProcessEnv);
const noKeyConfig = loadConfig({} as NodeJS.ProcessEnv);
const keyedConfig = loadConfig({
  MONKEYWORD_API_KEY: 'mw_test_key',
  MONKEYWORD_API_URL: 'https://api.example.test',
} as NodeJS.ProcessEnv);

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json' },
  });
}

describe('parseLocale', () => {
  it('defaults to ja/JP', () => {
    expect(parseLocale(undefined)).toEqual({ hl: 'ja', gl: 'JP' });
  });

  it('splits language and region', () => {
    expect(parseLocale('en-US')).toEqual({ hl: 'en', gl: 'US' });
    expect(parseLocale('ja_JP')).toEqual({ hl: 'ja', gl: 'JP' });
  });

  it('infers region from language when absent', () => {
    expect(parseLocale('en')).toEqual({ hl: 'en', gl: 'US' });
  });
});

describe('mock mode', () => {
  it('suggest_keywords returns bounded suggestions', async () => {
    const result = await suggestKeywords({ keyword: 'seo ツール', limit: 5 }, { config: mockConfig });
    const payload = parsePayload(result);
    expect(payload.mockMode).toBe(true);
    const suggestions = payload.suggestions as Array<Record<string, unknown>>;
    expect(suggestions).toHaveLength(5);
    for (const suggestion of suggestions) {
      expect(typeof suggestion.keyword).toBe('string');
      expect(typeof suggestion.searchVolumeEst).toBe('number');
      expect(['informational', 'commercial', 'transactional', 'navigational']).toContain(
        suggestion.intentCluster,
      );
    }
  });

  it('aeo_audit_lite returns robots and structured-data sections', async () => {
    const result = await aeoAuditLite({ url: 'https://example.test/' }, { config: mockConfig });
    const payload = parsePayload(result);
    expect(payload.url).toBe('https://example.test/');
    expect(payload.robots).toBeTruthy();
    expect(payload.structuredData).toBeTruthy();
  });

  it('keyword_intent classifies each keyword', async () => {
    const result = await keywordIntent(
      { keywords: ['seo ログイン', 'seo ツール 比較', 'seo とは'] },
      { config: mockConfig },
    );
    const payload = parsePayload(result);
    const results = payload.results as Array<Record<string, unknown>>;
    expect(results).toHaveLength(3);
    expect(results[0].intentCluster).toBe('navigational');
    expect(results[1].intentCluster).toBe('commercial');
    expect(results[2].intentCluster).toBe('informational');
  });

  it('rank_gsc returns rows without an API key', async () => {
    const result = await rankGsc({ site: 'example.test', query: 'seo ツール 無料' }, { config: mockConfig });
    const payload = parsePayload(result);
    expect(Array.isArray(payload.rows)).toBe(true);
    expect((payload.rows as unknown[]).length).toBeGreaterThan(0);
  });
});

describe('missing API key guidance', () => {
  it('returns the contract guidance for every tool', async () => {
    const results = await Promise.all([
      suggestKeywords({ keyword: 'seo' }, { config: noKeyConfig }),
      aeoAuditLite({ url: 'https://example.test/' }, { config: noKeyConfig }),
      keywordIntent({ keywords: ['seo'] }, { config: noKeyConfig }),
      rankGsc({ site: 'example.test', query: 'seo' }, { config: noKeyConfig }),
    ]);
    for (const result of results) {
      const message = result.content[0].text;
      expect(message).toContain('APIキーが必要です');
      expect(message).toContain('¥2,980');
      expect(message).toContain(LLMO_SHINDAN_URL);
    }
  });
});

describe('keyed mode calls the hosted API', () => {
  it('posts to /v1/suggest with bearer auth', async () => {
    const fetchImpl = vi.fn(async () =>
      jsonResponse({ kind: 'monkeyword/suggest', suggestions: [{ keyword: 'seo とは' }] }),
    );
    const result = await suggestKeywords(
      { keyword: 'seo', locale: 'ja-JP', limit: 10 },
      { config: keyedConfig, fetchImpl: fetchImpl as unknown as typeof fetch },
    );
    expect(fetchImpl).toHaveBeenCalledTimes(1);
    const [url, init] = fetchImpl.mock.calls[0] as [string, RequestInit];
    expect(url).toBe('https://api.example.test/v1/suggest');
    expect(init.method).toBe('POST');
    expect((init.headers as Record<string, string>).Authorization).toBe('Bearer mw_test_key');
    expect(JSON.parse(init.body as string)).toEqual({ keyword: 'seo', hl: 'ja', gl: 'JP', limit: 10 });
    const payload = parsePayload(result);
    expect(payload.kind).toBe('monkeyword/suggest');
  });

  it('surfaces a 429 error from the hosted API', async () => {
    const fetchImpl = vi.fn(async () => jsonResponse({ message: 'rate limited' }, 429));
    await expect(
      rankGsc(
        { site: 'example.test', query: 'seo' },
        { config: keyedConfig, fetchImpl: fetchImpl as unknown as typeof fetch },
      ),
    ).rejects.toThrow('rate limited');
  });
});
