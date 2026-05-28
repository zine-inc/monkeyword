<script lang="ts">
  import { Moon, Sun } from '@lucide/svelte';
  import ProjectPicker from './ProjectPicker.svelte';
  import { applyTheme, theme } from '$lib/theme';
  import { locale, setLocale, t } from '$lib/i18n';
  import { saveSettings } from '$lib/api';
  import type { Locale, Theme } from '$lib/types';

  async function changeLocale(next: Locale) {
    setLocale(next);
    await saveSettings({ locale: next });
  }

  async function changeTheme(next: Theme) {
    applyTheme(next);
    await saveSettings({ theme: next });
  }
</script>

<header class="topbar">
  <ProjectPicker />
  <div class="actions" aria-label="Application controls">
    <div class="segmented" aria-label={$t('app.language')}>
      <button class:active={$locale === 'ja'} type="button" on:click={() => changeLocale('ja')} aria-label="日本語">JA</button>
      <button class:active={$locale === 'en'} type="button" on:click={() => changeLocale('en')} aria-label="English">EN</button>
    </div>
    <div class="segmented" aria-label={$t('app.theme')}>
      <button class:active={$theme === 'light'} type="button" on:click={() => changeTheme('light')} aria-label={$t('app.light')}>
        <Sun size={16} aria-hidden="true" />
      </button>
      <button class:active={$theme === 'dark'} type="button" on:click={() => changeTheme('dark')} aria-label={$t('app.dark')}>
        <Moon size={16} aria-hidden="true" />
      </button>
    </div>
  </div>
</header>

<style>
  .actions {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: flex-end;
    gap: 10px;
  }

  .segmented {
    display: inline-flex;
    overflow: hidden;
    border: 1px solid var(--border);
    border-radius: 8px;
    background: var(--surface-muted);
  }

  button {
    display: inline-flex;
    min-width: 38px;
    height: 36px;
    align-items: center;
    justify-content: center;
    background: transparent;
    color: var(--muted);
    cursor: pointer;
    font-weight: 900;
  }

  button.active {
    background: var(--surface);
    color: var(--accent-strong);
  }
</style>
