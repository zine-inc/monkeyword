<script lang="ts">
  import { onMount } from 'svelte';
  import { readFixture } from '$lib/api';
  import { latestRanks } from '$lib/format';
  import { t } from '$lib/i18n';
  import type { Rank } from '$lib/types';
  import ErrorPanel from '$lib/components/ErrorPanel.svelte';
  import LineChart from '$lib/charts/LineChart.svelte';
  import Sparkline from '$lib/charts/Sparkline.svelte';

  let ranks: Rank[] = [];
  let selected = '';
  let loading = true;
  let error = '';

  async function load() {
    loading = true;
    error = '';
    try {
      ranks = await readFixture('ranks');
      selected = ranks[0]?.keyword ?? '';
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'Unknown error';
    } finally {
      loading = false;
    }
  }

  onMount(load);

  $: keywords = Array.from(new Set(ranks.map((rank) => rank.keyword)));
  $: latest = latestRanks(ranks);
  $: selectedRows = ranks.filter((rank) => rank.keyword === selected).sort((a, b) => a.date.localeCompare(b.date));
  $: selectedValues = selectedRows.map((rank) => rank.position ?? 100);
  $: selectedDates = selectedRows.map((rank) => rank.date);

  function historyFor(keyword: string) {
    return ranks
      .filter((rank) => rank.keyword === keyword)
      .sort((a, b) => a.date.localeCompare(b.date))
      .map((rank) => rank.position ?? 100);
  }

  function delta(rank: Rank) {
    if (rank.prevPosition === null || rank.position === null) return '–';
    const diff = rank.prevPosition - rank.position;
    return diff > 0 ? `+${diff}` : String(diff);
  }
</script>

<section class="page-head">
  <div>
    <p class="eyebrow">{$t('ranks.eyebrow')}</p>
    <h1>{$t('ranks.title')}</h1>
    <p>{$t('ranks.body')}</p>
  </div>
  <label class="label picker">
    <span>{$t('ranks.keyword')}</span>
    <select class="select" bind:value={selected} aria-label={$t('ranks.keyword')}>
      {#each keywords as keyword}
        <option value={keyword}>{keyword}</option>
      {/each}
    </select>
  </label>
</section>

{#if loading}
  <div class="loading">{$t('app.loading')}</div>
{:else if error}
  <ErrorPanel message={error} retry={load} />
{:else}
  <section class="panel panel-inner">
    <h2>{$t('ranks.trend')}</h2>
    <LineChart labels={selectedDates} values={selectedValues} inverted ariaLabel={`${selected} ${$t('ranks.trend')}`} />
  </section>

  <section class="panel" style="margin-top: 16px;">
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>{$t('ranks.keyword')}</th>
            <th class="right">{$t('ranks.position')}</th>
            <th class="right">{$t('ranks.previous')}</th>
            <th>{$t('ranks.features')}</th>
            <th>{$t('ranks.trendShort')}</th>
          </tr>
        </thead>
        <tbody>
          {#each latest as rank}
            <tr>
              <td>
                <strong>{rank.keyword}</strong>
                <span>{rank.url}</span>
              </td>
              <td class="right">{rank.position ?? '–'}</td>
              <td class="right">{delta(rank)}</td>
              <td>{rank.serpFeatures.join(', ') || '–'}</td>
              <td><Sparkline values={historyFor(rank.keyword)} inverted ariaLabel={`${rank.keyword} sparkline`} /></td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  </section>
{/if}

<style>
  .picker {
    min-width: min(320px, 100%);
  }

  .table-wrap {
    overflow-x: auto;
  }

  table {
    width: 100%;
    min-width: 760px;
    border-collapse: collapse;
  }

  th,
  td {
    border-bottom: 1px solid var(--border);
    padding: 13px 16px;
    text-align: left;
    vertical-align: middle;
  }

  th {
    color: var(--muted);
    font-size: 12px;
    font-weight: 900;
    text-transform: uppercase;
  }

  td span {
    display: block;
    color: var(--muted);
    font-size: 12px;
    margin-top: 4px;
  }

  .right {
    text-align: right;
  }
</style>
