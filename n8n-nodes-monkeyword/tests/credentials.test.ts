import { MonkeywordApi } from '../src/credentials/MonkeywordApi.credentials';

describe('MonkeywordApi credentials', () => {
  it('defines required Phase 1 credential fields', () => {
    const credential = new MonkeywordApi();
    const propertyNames = credential.properties.map((property) => property.name);

    expect(credential.name).toBe('monkeywordApi');
    expect(credential.displayName).toBe('Monkeyword API');
    expect(propertyNames).toEqual(['baseUrl', 'apiKey', 'mockMode']);
  });
});
