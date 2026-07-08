import { callApi, type FetchLike } from './apiClient.js';
import type { Config } from './config.js';
import { KEY_REQUIRED_MESSAGE } from './messages.js';
import {
  buildMockSuggestions,
  classifyIntent,
  MOCK_AEO_AUDIT,
  MOCK_RANK_ROWS,
} from './mocks.js';

export interface ToolContext {
  config: Config;
  fetchImpl?: FetchLike;
}

export interface TextResult {
  content: Array<{ type: 'text'; text: string }>;
  [key: string]: unknown;
}

function text(payload: unknown): TextResult {
  const body = typeof payload === 'string' ? payload : JSON.stringify(payload, null, 2);
  return { content: [{ type: 'text', text: body }] };
}

function guidance(): TextResult {
  return text(KEY_REQUIRED_MESSAGE);
}

function apiOptions(ctx: ToolContext): { apiUrl: string; apiKey: string; fetchImpl?: FetchLike } {
  return { apiUrl: ctx.config.apiUrl, apiKey: ctx.config.apiKey as string, fetchImpl: ctx.fetchImpl };
}

export function parseLocale(locale?: string): { hl: string; gl: string } {
  const normalized = (locale ?? '').trim();
  if (normalized.length === 0) {
    return { hl: 'ja', gl: 'JP' };
  }
  const [langPart, regionPart] = normalized.split(/[-_]/);
  const hl = langPart.toLowerCase() || 'ja';
  const gl = (regionPart ?? (hl === 'en' ? 'US' : 'JP')).toUpperCase();
  return { hl, gl };
}

export interface SuggestArgs {
  keyword: string;
  locale?: string;
  limit?: number;
}

export async function suggestKeywords(args: SuggestArgs, ctx: ToolContext): Promise<TextResult> {
  const { hl, gl } = parseLocale(args.locale);
  const limit = args.limit ?? 20;

  if (ctx.config.mock) {
    return text({
      kind: 'monkeyword/suggest',
      mockMode: true,
      keyword: args.keyword,
      hl,
      gl,
      suggestions: buildMockSuggestions(args.keyword, hl, gl, limit),
    });
  }

  if (!ctx.config.apiKey) {
    return guidance();
  }

  const data = await callApi('/v1/suggest', { keyword: args.keyword, hl, gl, limit }, apiOptions(ctx));
  return text(data);
}

export interface AeoAuditArgs {
  url: string;
}

export async function aeoAuditLite(args: AeoAuditArgs, ctx: ToolContext): Promise<TextResult> {
  if (ctx.config.mock) {
    return text({
      kind: 'monkeyword/aeo_audit_lite',
      mockMode: true,
      url: args.url,
      ...MOCK_AEO_AUDIT,
    });
  }

  if (!ctx.config.apiKey) {
    return guidance();
  }

  const data = await callApi('/v1/aeo_audit_lite', { url: args.url }, apiOptions(ctx));
  return text(data);
}

export interface KeywordIntentArgs {
  keywords: string[];
}

export async function keywordIntent(args: KeywordIntentArgs, ctx: ToolContext): Promise<TextResult> {
  if (ctx.config.mock) {
    return text({
      kind: 'monkeyword/keyword_intent',
      mockMode: true,
      results: args.keywords.map((keyword) => ({
        keyword,
        intentCluster: classifyIntent(keyword),
      })),
    });
  }

  if (!ctx.config.apiKey) {
    return guidance();
  }

  const data = await callApi('/v1/keyword_intent', { keywords: args.keywords }, apiOptions(ctx));
  return text(data);
}

export interface RankGscArgs {
  site: string;
  query: string;
}

export async function rankGsc(args: RankGscArgs, ctx: ToolContext): Promise<TextResult> {
  if (ctx.config.mock) {
    const rows = MOCK_RANK_ROWS.filter((row) => row.query === args.query);
    return text({
      kind: 'monkeyword/rank_gsc',
      mockMode: true,
      site: args.site,
      query: args.query,
      rows: rows.length > 0 ? rows : MOCK_RANK_ROWS.slice(0, 1),
    });
  }

  if (!ctx.config.apiKey) {
    return guidance();
  }

  const data = await callApi('/v1/rank_gsc', { site: args.site, query: args.query }, apiOptions(ctx));
  return text(data);
}
