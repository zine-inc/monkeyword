import type {
  ICredentialType,
  INodeProperties,
} from 'n8n-workflow';

const KEY_SIGNUP_URL =
  'https://monkeyword.1stop.direct/llmo-shindan.html?utm_source=n8n&utm_medium=credential';

export class MonkeywordApi implements ICredentialType {
  name = 'monkeywordApi';

  displayName = 'Monkeyword API';

  documentationUrl = 'https://github.com/zine-inc/monkeyword/tree/main/n8n-nodes-monkeyword#readme';

  properties: INodeProperties[] = [
    {
      displayName: 'Base URL',
      name: 'baseUrl',
      type: 'string',
      default: 'https://api.monkeyword.1stop.direct',
      required: true,
      description: 'Base URL of the monkeyword API.',
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
      description: `Required when Mock Mode is off. Get a key at ${KEY_SIGNUP_URL}`,
    },
    {
      displayName: 'Mock Mode',
      name: 'mockMode',
      type: 'boolean',
      default: true,
      required: true,
      description: 'Return deterministic mock JSON without calling the monkeyword API. Turn off once you have an API key.',
    },
  ];
}
