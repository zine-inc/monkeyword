import { writable, derived, get } from 'svelte/store';
import ja from '../locales/ja.json';
import en from '../locales/en.json';
import type { Locale } from './types';

const dictionaries = { ja, en };

export const locale = writable<Locale>('ja');

function readPath(source: Record<string, unknown>, key: string): string {
  const value = key.split('.').reduce<unknown>((current, part) => {
    if (current && typeof current === 'object' && part in current) {
      return (current as Record<string, unknown>)[part];
    }
    return undefined;
  }, source);
  return typeof value === 'string' ? value : key;
}

function applyParams(template: string, params?: Record<string, string | number>) {
  if (!params) return template;
  return Object.entries(params).reduce(
    (text, [key, value]) => text.replaceAll(`{${key}}`, String(value)),
    template
  );
}

export const t = derived(locale, ($locale) => {
  return (key: string, params?: Record<string, string | number>) =>
    applyParams(readPath(dictionaries[$locale], key), params);
});

export function translate(key: string, params?: Record<string, string | number>) {
  return get(t)(key, params);
}

export function setLocale(next: Locale) {
  locale.set(next);
  if (typeof document !== 'undefined') {
    document.documentElement.lang = next;
  }
}
