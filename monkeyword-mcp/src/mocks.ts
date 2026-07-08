export type IntentCluster =
  | 'informational'
  | 'commercial'
  | 'transactional'
  | 'navigational';

export interface SuggestSuffix {
  suffix: string;
  intent: IntentCluster;
}

export const MOCK_SUFFIXES: ReadonlyArray<SuggestSuffix> = [
  { suffix: 'とは', intent: 'informational' },
  { suffix: '使い方', intent: 'informational' },
  { suffix: '比較', intent: 'commercial' },
  { suffix: 'おすすめ', intent: 'commercial' },
  { suffix: '料金', intent: 'transactional' },
  { suffix: '無料', intent: 'transactional' },
  { suffix: 'やり方', intent: 'informational' },
  { suffix: '初心者', intent: 'informational' },
  { suffix: 'ログイン', intent: 'navigational' },
  { suffix: '評判', intent: 'commercial' },
];

export const INTENT_MARKERS: ReadonlyArray<{ marker: string; intent: IntentCluster }> = [
  { marker: 'ログイン', intent: 'navigational' },
  { marker: '公式', intent: 'navigational' },
  { marker: '料金', intent: 'transactional' },
  { marker: '購入', intent: 'transactional' },
  { marker: '申込', intent: 'transactional' },
  { marker: '無料', intent: 'transactional' },
  { marker: '比較', intent: 'commercial' },
  { marker: 'おすすめ', intent: 'commercial' },
  { marker: '評判', intent: 'commercial' },
  { marker: 'レビュー', intent: 'commercial' },
];

export interface MockAeoAudit {
  robots: {
    fetched: boolean;
    aiCrawlers: Array<{ agent: string; allowed: boolean }>;
  };
  structuredData: {
    hasJsonLd: boolean;
    types: string[];
    hasFaq: boolean;
    hasHowTo: boolean;
  };
  notes: string[];
}

export const MOCK_AEO_AUDIT: MockAeoAudit = {
  robots: {
    fetched: true,
    aiCrawlers: [
      { agent: 'GPTBot', allowed: true },
      { agent: 'ClaudeBot', allowed: true },
      { agent: 'Google-Extended', allowed: false },
      { agent: 'PerplexityBot', allowed: true },
      { agent: 'CCBot', allowed: false },
    ],
  },
  structuredData: {
    hasJsonLd: true,
    types: ['Organization', 'WebSite', 'BreadcrumbList'],
    hasFaq: false,
    hasHowTo: false,
  },
  notes: [
    'FAQPage / HowTo の構造化データが未設定です。回答エンジン向けに追加を検討してください。',
    'Google-Extended が disallow のため、Gemini/AI Overviews の学習対象から外れます。',
  ],
};

export interface MockRankRow {
  query: string;
  page: string;
  position: number;
  clicks: number;
  impressions: number;
  ctr: number;
}

export const MOCK_RANK_ROWS: ReadonlyArray<MockRankRow> = [
  {
    query: 'seo ツール 無料',
    page: 'https://monkeyword.1stop.direct/guides/free-seo-tools',
    position: 4.2,
    clicks: 128,
    impressions: 5400,
    ctr: 0.0237,
  },
  {
    query: 'キーワード 難易度 調べ方',
    page: 'https://monkeyword.1stop.direct/guides/keyword-difficulty',
    position: 10.1,
    clicks: 41,
    impressions: 3100,
    ctr: 0.0132,
  },
];

function hashSeed(value: string): number {
  let hash = 0;
  for (let i = 0; i < value.length; i += 1) {
    hash = (hash * 31 + value.charCodeAt(i)) >>> 0;
  }
  return hash;
}

export interface Suggestion {
  keyword: string;
  hl: string;
  gl: string;
  searchVolumeEst: number;
  intentCluster: IntentCluster;
  kdEst: number;
}

export function buildMockSuggestions(
  keyword: string,
  hl: string,
  gl: string,
  limit: number,
): Suggestion[] {
  const count = Math.max(1, Math.min(limit, MOCK_SUFFIXES.length));
  return MOCK_SUFFIXES.slice(0, count).map(({ suffix, intent }) => {
    const seed = hashSeed(`${keyword}|${suffix}|${gl}`);
    return {
      keyword: `${keyword} ${suffix}`,
      hl,
      gl,
      searchVolumeEst: 100 + (seed % 220) * 50,
      intentCluster: intent,
      kdEst: 18 + ((seed >> 4) % 50),
    };
  });
}

export interface IntentResult {
  keyword: string;
  intentCluster: IntentCluster;
}

export function classifyIntent(keyword: string): IntentCluster {
  for (const { marker, intent } of INTENT_MARKERS) {
    if (keyword.includes(marker)) {
      return intent;
    }
  }
  return 'informational';
}
