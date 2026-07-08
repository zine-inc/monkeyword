import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import { beforeEach, describe, expect, it } from 'vitest';
import { loadConfig } from '../src/config.js';
import { createServer } from '../src/server.js';

async function connectedClient(): Promise<Client> {
  const server = createServer(loadConfig({ MONKEYWORD_MOCK: '1' } as NodeJS.ProcessEnv));
  const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
  const client = new Client({ name: 'test-client', version: '0.0.0' });
  await Promise.all([server.connect(serverTransport), client.connect(clientTransport)]);
  return client;
}

describe('MCP server wiring', () => {
  let client: Client;

  beforeEach(async () => {
    client = await connectedClient();
  });

  it('registers the four monkeyword tools', async () => {
    const listed = await client.listTools();
    const names = listed.tools.map((tool) => tool.name).sort();
    expect(names).toEqual(['aeo_audit_lite', 'keyword_intent', 'rank_gsc', 'suggest_keywords']);
  });

  it('publishes an input schema for every tool', async () => {
    const listed = await client.listTools();
    for (const tool of listed.tools) {
      expect(tool.inputSchema).toBeTruthy();
      expect(tool.inputSchema.type).toBe('object');
    }
  });

  it('calls suggest_keywords end to end in mock mode', async () => {
    const result = await client.callTool({
      name: 'suggest_keywords',
      arguments: { keyword: 'seo ツール', limit: 3 },
    });
    const content = result.content as Array<{ type: string; text: string }>;
    const payload = JSON.parse(content[0].text) as Record<string, unknown>;
    expect(payload.mockMode).toBe(true);
    expect((payload.suggestions as unknown[]).length).toBe(3);
  });

  it('rejects invalid arguments against the schema', async () => {
    const result = await client.callTool({
      name: 'aeo_audit_lite',
      arguments: { url: 'not-a-url' },
    });
    expect(result.isError).toBe(true);
    const content = result.content as Array<{ type: string; text: string }>;
    expect(content[0].text).toContain('validation');
  });
});
