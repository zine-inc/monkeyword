<script lang="ts">
  import { onMount } from 'svelte';
  import { Save } from '@lucide/svelte';
  import { getSettings, saveSettings } from '$lib/api';
  import { setLocale, t } from '$lib/i18n';
  import { applyTheme } from '$lib/theme';
  import type { Locale, Theme } from '$lib/types';
  import ErrorPanel from '$lib/components/ErrorPanel.svelte';
  import MockBadge from '$lib/components/MockBadge.svelte';

  let apiUrl = '';
  let selectedLocale: Locale = 'ja';
  let selectedTheme: Theme = 'light';
  let loading = true;
  let saving = false;
  let saved = false;
  let error = '';

  async function load() {
    loading = true;
    error = '';
    try {
      const next = await getSettings();
      apiUrl = next.apiUrl;
      selectedLocale = next.locale;
      selectedTheme = next.theme;
      setLocale(selectedLocale);
      applyTheme(selectedTheme);
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'Unknown error';
    } finally {
      loading = false;
    }
  }

  async function save() {
    saving = true;
    saved = false;
    error = '';
    try {
      const next = await saveSettings({
        apiUrl,
        locale: selectedLocale,
        theme: selectedTheme,
        mockMode: true
      });
      setLocale(next.locale);
      applyTheme(next.theme);
      saved = true;
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'Unknown error';
    } finally {
      saving = false;
    }
  }

  onMount(load);
</script>

<section class="page-head">
  <div>
    <p class="eyebrow">{$t('settings.eyebrow')}</p>
    <h1>{$t('settings.title')}</h1>
    <p>{$t('settings.body')}</p>
  </div>
  <MockBadge />
</section>

{#if loading}
  <div class="loading">{$t('app.loading')}</div>
{:else if error}
  <ErrorPanel message={error} retry={load} />
{:else}
  <form class="panel panel-inner settings-form" on:submit|preventDefault={save}>
    <fieldset>
      <legend>{$t('app.language')}</legend>
      <div class="segmented">
        <label>
          <input type="radio" bind:group={selectedLocale} value="ja" />
          <span>JA</span>
        </label>
        <label>
          <input type="radio" bind:group={selectedLocale} value="en" />
          <span>EN</span>
        </label>
      </div>
    </fieldset>

    <fieldset>
      <legend>{$t('app.theme')}</legend>
      <div class="segmented">
        <label>
          <input type="radio" bind:group={selectedTheme} value="light" />
          <span>{$t('app.light')}</span>
        </label>
        <label>
          <input type="radio" bind:group={selectedTheme} value="dark" />
          <span>{$t('app.dark')}</span>
        </label>
      </div>
    </fieldset>

    <label class="label">
      <span>{$t('settings.apiUrl')}</span>
      <input class="input" type="url" bind:value={apiUrl} placeholder="https://api.example" aria-label={$t('settings.apiUrl')} />
      <span class="help">Phase 1: {$t('settings.mockLocked')}</span>
    </label>

    <label class="label">
      <span>{$t('settings.apiKey')}</span>
      <input class="input" type="password" placeholder={$t('settings.apiKeyPlaceholder')} autocomplete="off" aria-label={$t('settings.apiKey')} disabled />
      <span class="help">{$t('settings.apiKeyPhase2')}</span>
    </label>

    <label class="switch">
      <input type="checkbox" checked disabled aria-label={$t('app.mockMode')} />
      <span>{$t('settings.mockLocked')}</span>
    </label>

    <div class="row wrap">
      <button class="button primary" type="submit" disabled={saving} aria-label={$t('settings.save')}>
        <Save size={16} aria-hidden="true" />
        {$t('settings.save')}
      </button>
      {#if saved}
        <span class="badge" role="status">{$t('settings.saved')}</span>
      {/if}
    </div>
  </form>
{/if}

<style>
  .settings-form {
    display: grid;
    max-width: 760px;
    gap: 20px;
  }

  fieldset {
    display: grid;
    gap: 10px;
    border: 0;
    margin: 0;
    padding: 0;
  }

  legend {
    color: var(--strong);
    font-weight: 900;
    padding: 0;
  }

  .segmented {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }

  .segmented label {
    cursor: pointer;
  }

  .segmented input {
    position: absolute;
    opacity: 0;
  }

  .segmented span {
    display: inline-flex;
    min-height: 38px;
    align-items: center;
    justify-content: center;
    border: 1px solid var(--border);
    border-radius: 7px;
    background: var(--surface-muted);
    color: var(--muted);
    font-weight: 900;
    padding: 0 14px;
  }

  .segmented input:checked + span {
    border-color: var(--accent);
    background: var(--accent-soft);
    color: var(--accent-strong);
  }

  .switch {
    display: flex;
    align-items: center;
    gap: 10px;
    color: var(--strong);
    font-weight: 800;
  }

  .switch input {
    width: 18px;
    height: 18px;
  }

  .input:disabled {
    cursor: not-allowed;
    opacity: 0.65;
  }
</style>
