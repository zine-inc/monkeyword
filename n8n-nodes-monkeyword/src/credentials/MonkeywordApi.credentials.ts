import type {
  ICredentialType,
  INodeProperties,
} from 'n8n-workflow';

export class MonkeywordApi implements ICredentialType {
  name = 'monkeywordApi';

  displayName = 'Monkeyword API';

  documentationUrl = 'https://github.com/zine-inc/monkeyword';

  properties: INodeProperties[] = [
    {
      displayName: 'Base URL',
      name: 'baseUrl',
      type: 'string',
      default: 'https://monkeyword.1stop.direct',
      required: true,
    },
    {
      displayName: 'API Key',
      name: 'apiKey',
      type: 'string',
      typeOptions: {
        password: true,
      },
      default: '',
      required: true,
    },
    {
      displayName: 'Mock Mode',
      name: 'mockMode',
      type: 'boolean',
      default: true,
      required: true,
      description: 'Return mock JSON in Phase 1 without calling the monkeyword API.',
    },
  ];
}
