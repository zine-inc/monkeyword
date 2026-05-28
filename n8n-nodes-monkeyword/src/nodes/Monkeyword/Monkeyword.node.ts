import type {
  IDataObject,
  IExecuteFunctions,
  INodeExecutionData,
  INodeType,
  INodeTypeDescription,
} from 'n8n-workflow';
import { NodeConnectionTypes, NodeOperationError } from 'n8n-workflow';

type IntentCluster =
  | 'informational'
  | 'transactional'
  | 'navigational'
  | 'commercial';

interface Suggestion {
  keyword: string;
  hl: string;
  gl: string;
  searchVolumeEst: number;
  intentCluster: IntentCluster;
  kdEst: number;
}

const MOCK_SUFFIXES: ReadonlyArray<{ suffix: string; intent: IntentCluster }> = [
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

function hashSeed(value: string): number {
  let hash = 0;
  for (let i = 0; i < value.length; i++) {
    hash = (hash * 31 + value.charCodeAt(i)) >>> 0;
  }
  return hash;
}

function buildMockSuggestions(
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

export class Monkeyword implements INodeType {
  description: INodeTypeDescription = {
    displayName: 'Monkeyword',
    name: 'monkeyword',
    icon: 'file:monkeyword.svg',
    group: ['transform'],
    version: 1,
    subtitle: '={{ $parameter["operation"] }}',
    description: 'AI-powered SEO keyword research with a local LLM',
    defaults: {
      name: 'Monkeyword',
    },
    inputs: [NodeConnectionTypes.Main],
    outputs: [NodeConnectionTypes.Main],
    credentials: [
      {
        name: 'monkeywordApi',
        required: true,
      },
    ],
    properties: [
      {
        displayName: 'Operation',
        name: 'operation',
        type: 'options',
        noDataExpression: true,
        options: [
          {
            name: 'Suggest Keywords',
            value: 'suggest',
            description: 'Expand a seed keyword into related search queries',
            action: 'Suggest related keywords',
          },
        ],
        default: 'suggest',
      },
      {
        displayName: 'Keyword',
        name: 'keyword',
        type: 'string',
        default: '',
        required: true,
        placeholder: 'seo ツール',
        description: 'The seed keyword to expand',
      },
      {
        displayName: 'Language (hl)',
        name: 'hl',
        type: 'string',
        default: 'ja',
        description: 'Interface language code, e.g. ja or en',
      },
      {
        displayName: 'Country (gl)',
        name: 'gl',
        type: 'string',
        default: 'JP',
        description: 'Geo/country code, e.g. JP or US',
      },
      {
        displayName: 'Limit',
        name: 'limit',
        type: 'number',
        typeOptions: {
          minValue: 1,
          maxValue: 100,
        },
        default: 20,
        description: 'Max number of suggestions to return',
      },
    ],
  };

  async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
    const items = this.getInputData();
    const returnData: INodeExecutionData[] = [];

    const credentials = await this.getCredentials('monkeywordApi');
    const mockMode = credentials.mockMode as boolean;
    const baseUrl = String(credentials.baseUrl ?? '').replace(/\/+$/, '');
    const apiKey = String(credentials.apiKey ?? '');

    for (let i = 0; i < items.length; i++) {
      const operation = this.getNodeParameter('operation', i) as string;
      if (operation !== 'suggest') {
        throw new NodeOperationError(
          this.getNode(),
          `Unsupported operation: ${operation}`,
          { itemIndex: i },
        );
      }

      const keyword = (this.getNodeParameter('keyword', i) as string).trim();
      const hl = this.getNodeParameter('hl', i) as string;
      const gl = this.getNodeParameter('gl', i) as string;
      const limit = this.getNodeParameter('limit', i) as number;

      if (!keyword) {
        throw new NodeOperationError(this.getNode(), 'Keyword must not be empty', {
          itemIndex: i,
        });
      }

      if (mockMode) {
        returnData.push({
          json: {
            kind: 'monkeyword/suggest',
            mockMode: true,
            keyword,
            hl,
            gl,
            suggestions: buildMockSuggestions(keyword, hl, gl, limit),
          },
          pairedItem: { item: i },
        });
        continue;
      }

      if (!baseUrl) {
        throw new NodeOperationError(
          this.getNode(),
          'Base URL is required when mock mode is off',
          { itemIndex: i },
        );
      }

      const response = await this.helpers.httpRequest({
        method: 'POST',
        url: `${baseUrl}/v1/projects/default/jobs`,
        headers: {
          Authorization: `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
        body: {
          kind: 'monkeyword/suggest',
          payload: { keyword, hl, gl, limit },
        },
        json: true,
      });

      returnData.push({
        json: response as IDataObject,
        pairedItem: { item: i },
      });
    }

    return [returnData];
  }
}
