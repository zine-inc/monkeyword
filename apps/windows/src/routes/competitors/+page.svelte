<script lang="ts">
  import { onMount } from 'svelte';
  import { readFixture } from '$lib/api';
  import { compactNumber } from '$lib/format';
  import { t } from '$lib/i18n';
  import type { Competitor } from '$lib/types';
  import BarChart from '$lib/charts/BarChart.svelte';
  import ErrorPanel from '$lib/components/ErrorPanel.svelte';

  let competitors: Competitor[] = [];
  let loading = true;
  let error = '';

  async function load() {
    loading = true;
    error = '';
    try {
      competitors = await readFixture('competitors');
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'Unknown error';
    } finally {
      loading = false;
    }
  }

  onMount(load);
</script>

<section class="page-head">
  <div>
    <p class="eyebrow">{$t('competitors.eyebrow')}</p>
    <h1>{$t('competitors.title')}</h1>
    <p>{$t('competitors.body')}</p>
  </div>
</section>

{#if loading}
  <div class="loading">{$t('app.loading')}</div>
{:else if error}
  <ErrorPanel message={error} retry={load} />
{:else}
  <section class="panel panel-inner">
    <h2>{$t('competitors.traffic')}</h2>
    <BarChart labels={competitors.map((item) => item.domain.replace('.example', ''))} values={competitors.map((item) => item.estimatedTraffic)} ariaLabel={$t('competitors.traffic')} />
  </section>

  <section class="grid three" style="margin-top: 16px;">
    {#each competitors as competitor}
      <article class="panel panel-inner competitor">
        <div class="row space-between">
          <h2>{competitor.domain}</h2>
          <span class="badge">{compactNumber(competitor.estimatedTraffic)}</span>
        </div>
        <div>
          <h3>{$t('competitors.topKeywords')}</h3>
          <ul>
            {#each competitor.topKeywords as keyword}
              <li>{keyword}</li>
            {/each}
          </ul>
        </div>
        <div>
          <h3>{$t('competitors.gap')}</h3>
          <ul>
            {#each competitor.keywordGap as keyword}
              <li>{keyword}</li>
            {/each}
          </ul>
        </div>
      </article>
    {/each}
  </section>
{/if}

<style>
  .competitor {
    display: grid;
    gap: 16px;
  }

  ul {
    display: grid;
    gap: 8px;
    margin: 10px 0 0;
    padding-left: 18px;
  }

  li {
    color: var(--text);
    line-height: 1.45;
  }
</style>
