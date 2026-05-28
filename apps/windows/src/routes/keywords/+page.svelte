<script lang="ts">
  import { onMount } from 'svelte';
  import { readFixture } from '$lib/api';
  import { compactNumber, numberFormat } from '$lib/format';
  import { t } from '$lib/i18n';
  import type { IntentCluster, Keyword } from '$lib/types';
  import BarChart from '$lib/charts/BarChart.svelte';
  import DataTable from '$lib/components/DataTable.svelte';
  import ErrorPanel from '$lib/components/ErrorPanel.svelte';

  let keywords: Keyword[] = [];
  let filter: IntentCluster | 'all' = 'all';
  let loading = true;
  let error = '';

  async function load() {
    loading = true;
    error = '';
    try {
      keywords = await readFixture('keywords');
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'Unknown error';
    } finally {
      loading = false;
    }
  }

  onMount(load);

  $: filtered = keywords.filter((keyword) => filter === 'all' || keyword.intentCluster === filter);
  $: grouped = ['commercial', 'informational', 'transactional'].map((intent) => ({
    label: intent,
    value: keywords
      .filter((keyword) => keyword.intentCluster === intent)
      .reduce((sum, keyword) => sum + keyword.searchVolumeEst, 0)
  }));
  $: tableRows = filtered.map((keyword) => ({
    keyword: keyword.keyword,
    intent: keyword.intentCluster,
    volume: keyword.searchVolumeEst,
    difficulty: keyword.kdEst,
    locale: `${keyword.hl}-${keyword.gl}`,
    summary: keyword.llmSummary
  }));
</script>

<section class="page-head">
  <div>
    <p class="eyebrow">{$t('keywords.eyebrow')}</p>
    <h1>{$t('keywords.title')}</h1>
    <p>{$t('keywords.body')}</p>
  </div>
  <label class="label filter">
    <span>{$t('keywords.filter')}</span>
    <select class="select" bind:value={filter} aria-label={$t('keywords.filter')}>
      <option value="all">{$t('keywords.all')}</option>
      <option value="commercial">commercial</option>
      <option value="informational">informational</option>
      <option value="transactional">transactional</option>
    </select>
  </label>
</section>

{#if loading}
  <div class="loading">{$t('app.loading')}</div>
{:else if error}
  <ErrorPanel message={error} retry={load} />
{:else}
  <section class="grid two">
    <div class="panel panel-inner">
      <h2>{$t('dashboard.intentMix')}</h2>
      <BarChart labels={grouped.map((item) => item.label)} values={grouped.map((item) => item.value)} ariaLabel={$t('dashboard.intentMix')} />
    </div>
    <div class="panel panel-inner summary">
      {#each grouped as group}
        <div>
          <span>{group.label}</span>
          <strong>{compactNumber(group.value)}</strong>
        </div>
      {/each}
    </div>
  </section>

  <section class="panel panel-inner" style="margin-top: 16px;">
    <DataTable
      rows={tableRows}
      columns={[
        { key: 'keyword', label: $t('ranks.keyword') },
        { key: 'intent', label: $t('keywords.intent') },
        { key: 'volume', label: $t('keywords.volume'), align: 'right', format: (value) => numberFormat.format(Number(value)) },
        { key: 'difficulty', label: $t('keywords.difficulty'), align: 'right' },
        { key: 'locale', label: $t('app.localeCode') },
        { key: 'summary', label: $t('keywords.summary') }
      ]}
    />
  </section>
{/if}

<style>
  .filter {
    min-width: 220px;
  }

  .summary {
    align-content: center;
  }

  .summary div {
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid var(--border);
    padding: 14px 0;
  }

  .summary div:last-child {
    border-bottom: 0;
  }

  .summary span {
    color: var(--muted);
    font-weight: 800;
  }

  .summary strong {
    color: var(--strong);
    font-size: 26px;
  }
</style>
