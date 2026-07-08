import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import type { Config } from './config.js';
import type { FetchLike } from './apiClient.js';
import {
  aeoAuditLite,
  keywordIntent,
  rankGsc,
  suggestKeywords,
  type ToolContext,
} from './tools.js';

export const SERVER_NAME = 'monkeyword-mcp';
export const SERVER_VERSION = '0.1.0';

export function createServer(config: Config, fetchImpl?: FetchLike): McpServer {
  const server = new McpServer({ name: SERVER_NAME, version: SERVER_VERSION });
  const ctx: ToolContext = { config, fetchImpl };

  server.registerTool(
    'suggest_keywords',
    {
      title: 'Suggest keywords',
      description:
        'Expand a seed keyword into related SEO/AEO search queries with search-volume, intent, and difficulty estimates.',
      inputSchema: {
        keyword: z.string().min(1),
        locale: z.string().optional(),
        limit: z.number().int().min(1).max(100).optional(),
      },
    },
    async (args) => suggestKeywords(args, ctx),
  );

  server.registerTool(
    'aeo_audit_lite',
    {
      title: 'AEO audit (lite)',
      description:
        'Lightweight Answer-Engine-Optimization check for a URL: robots.txt AI-crawler policy and structured-data presence.',
      inputSchema: {
        url: z.string().url(),
      },
    },
    async (args) => aeoAuditLite(args, ctx),
  );

  server.registerTool(
    'keyword_intent',
    {
      title: 'Classify keyword intent',
      description:
        'Classify keywords into search-intent clusters: informational, commercial, transactional, or navigational.',
      inputSchema: {
        keywords: z.array(z.string().min(1)).min(1).max(200),
      },
    },
    async (args) => keywordIntent(args, ctx),
  );

  server.registerTool(
    'rank_gsc',
    {
      title: 'Rank in Google Search Console',
      description:
        'Return your own site position for a query from linked Google Search Console data. Requires an API key.',
      inputSchema: {
        site: z.string().min(1),
        query: z.string().min(1),
      },
    },
    async (args) => rankGsc(args, ctx),
  );

  return server;
}
