import { writable } from 'svelte/store';
import type { Theme } from './types';

function preferredTheme(): Theme {
  if (typeof window !== 'undefined' && window.matchMedia?.('(prefers-color-scheme: dark)').matches) {
    return 'dark';
  }
  return 'light';
}

export const theme = writable<Theme>(preferredTheme());

export function applyTheme(next: Theme) {
  theme.set(next);
  if (typeof document !== 'undefined') {
    document.documentElement.dataset.theme = next;
  }
}

export function initTheme() {
  applyTheme(preferredTheme());
}
