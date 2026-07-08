import type { IExecuteFunctions } from 'n8n-workflow';
import { Monkeyword } from '../src/nodes/Monkeyword/Monkeyword.node';

interface ContextOverrides {
  credentials?: Record<string, unknown>;
  parameters?: Record<string, unknown>;
  httpRequest?: jest.Mock;
}

function buildContext(overrides: ContextOverrides = {}): {
  context: IExecuteFunctions;
  httpRequest: jest.Mock;
} {
  const credentials = {
    baseUrl: 'https://api.monkeyword.1stop.direct',
    apiKey: '',
    mockMode: true,
    ...overrides.credentials,
  };
  const parameters: Record<string, unknown> = {
    operation: 'suggest',
    keyword: 'seo ツール',
    hl: 'ja',
    gl: 'JP',
    limit: 5,
    ...overrides.parameters,
  };
  const httpRequest = overrides.httpRequest ?? jest.fn().mockResolvedValue({});

  const context = {
    getInputData: () => [{ json: {} }],
    getCredentials: async () => credentials,
    getNodeParameter: (name: string) => parameters[name],
    getNode: () => ({
      id: 'test-node',
      name: 'Monkeyword',
      type: 'monkeyword',
      typeVersion: 1,
      position: [0, 0],
      parameters: {},
    }),
    helpers: {
      httpRequest,
    },
  };

  return { context: context as unknown as IExecuteFunctions, httpRequest };
}

describe('Monkeyword node execute', () => {
  it('returns deterministic mock suggestions and never calls the API in mock mode', async () => {
    const node = new Monkeyword();
    const { context, httpRequest } = buildContext({ credentials: { mockMode: true } });

    const result = await node.execute.call(context);

    expect(httpRequest).not.toHaveBeenCalled();
    expect(result[0]).toHaveLength(1);
    const [{ json }] = result[0];
    expect(json.mockMode).toBe(true);
    expect(json.keyword).toBe('seo ツール');
    expect(Array.isArray(json.suggestions)).toBe(true);
    expect((json.suggestions as unknown[]).length).toBe(5);
  });

  it('throws a clear error with the key signup link when apiKey is missing in live mode', async () => {
    const node = new Monkeyword();
    const { context } = buildContext({ credentials: { mockMode: false, apiKey: '' } });

    await expect(node.execute.call(context)).rejects.toThrow(
      /llmo-shindan\.html\?utm_source=n8n&utm_medium=node_error/,
    );
  });

  it('calls the live API with a bearer token when mock mode is off and apiKey is set', async () => {
    const httpRequest = jest.fn().mockResolvedValue({ kind: 'monkeyword/suggest', suggestions: [] });
    const node = new Monkeyword();
    const { context } = buildContext({
      credentials: {
        mockMode: false,
        apiKey: 'test-key',
        baseUrl: 'https://api.monkeyword.1stop.direct',
      },
      httpRequest,
    });

    await node.execute.call(context);

    expect(httpRequest).toHaveBeenCalledWith(
      expect.objectContaining({
        method: 'POST',
        url: 'https://api.monkeyword.1stop.direct/v1/projects/default/jobs',
        headers: expect.objectContaining({ Authorization: 'Bearer test-key' }),
      }),
    );
  });

  it('rejects an empty keyword', async () => {
    const node = new Monkeyword();
    const { context } = buildContext({ parameters: { keyword: '  ' } });

    await expect(node.execute.call(context)).rejects.toThrow(/Keyword must not be empty/);
  });
});
