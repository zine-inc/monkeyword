<script lang="ts">
  import { onMount } from 'svelte';
  import { Save, Trash2 } from '@lucide/svelte';
  import { getSettings, saveSettings } from '$lib/api';
  import { setLocale, t } from '$lib/i18n';
  import { applyTheme } from '$lib/theme';
  import type { Locale, PublicSettings, Theme } from '$lib/types';
  import ErrorPanel from '$lib/components/ErrorPanel.svelte';
  import MockBadge from '$lib/components/MockBadge.svelte';

  let settings: PublicSettings | null = null;
  let apiUrl = '';
  let apiKey = '';
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
      settings = await getSettings();
      apiUrl = settings.apiUrl;
      selectedLocale = settings.locale;
      selectedTheme = settings.theme;
      setLocale(selectedLocale);
      applyTheme(selectedTheme);
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'Unknown error';
    } finally {
      loading = false;
    }
  }

  async function save(clearApiKey = false) {
    saving = true;
    saved = false;
    error = '';
    try {
      settings = await saveSettings({
        apiUrl,
        apiKey: clearApiKey ? undefined : apiKey,
        clearApiKey,
        locale: selectedLocale,
        theme: selectedTheme,
        mockMode: true
      });
      apiKey = '';
      setLocale(settings.locale);
      applyTheme(settings.theme);
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
  <form class="panel panel-inner settings-form" on:submit|preventDefault={() => save(false)}>
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
      <input class="input" type="password" bind:value={apiKey} placeholder={$t('settings.apiKeyPlaceholder')} autocomplete="off" aria-label={$t('settings.apiKey')} />
      <span class="help">{settings?.hasApiKey ? $t('settings.hasApiKey') : $t('settings.mockLocked')}</span>
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
      <button class="button" type="button" on:click={() => save(true)} disabled={saving || !settings?.hasApiKey} aria-label={$t('settings.clearApiKey')}>
        <Trash2 size={16} aria-hidden="true" />
        {$t('settings.clearApiKey')}
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
</style>
