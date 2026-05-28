<script lang="ts">
  import { onMount } from 'svelte';
  import { Link2, ShieldCheck, Sigma } from '@lucide/svelte';
  import { readFixture } from '$lib/api';
  import { average, numberFormat } from '$lib/format';
  import { t } from '$lib/i18n';
  import type { Backlink } from '$lib/types';
  import BarChart from '$lib/charts/BarChart.svelte';
  import DataTable from '$lib/components/DataTable.svelte';
  import ErrorPanel from '$lib/components/ErrorPanel.svelte';
  import KpiCard from '$lib/components/KpiCard.svelte';

  let backlinks: Backlink[] = [];
  let loading = true;
  let error = '';

  async function load() {
    loading = true;
    error = '';
    try {
      backlinks = await readFixture('backlinks');
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'Unknown error';
    } finally {
      loading = false;
    }
  }

  onMount(load);

  $: followCount = backlinks.filter((link) => !link.nofollow).length;
  $: avgPagerank = average(backlinks.map((link) => link.sourcePagerank));
  $: rows = backlinks
    .slice()
    .sort((a, b) => b.sourcePagerank - a.sourcePagerank)
    .map((link) => ({
      sourceDomain: link.sourceDomain,
      anchor: link.anchor,
      sourcePagerank: link.sourcePagerank,
      nofollow: link.nofollow ? $t('backlinks.nofollow') : $t('backlinks.follow'),
      targetUrl: link.targetUrl
    }));
  $: labels = backlinks.map((link) => link.sourceDomain.replace('.example', ''));
  $: values = backlinks.map((link) => link.sourcePagerank);
</script>

<section class="page-head">
  <div>
    <p class="eyebrow">{$t('backlinks.eyebrow')}</p>
    <h1>{$t('backlinks.title')}</h1>
    <p>{$t('backlinks.body')}</p>
  </div>
</section>

{#if loading}
  <div class="loading">{$t('app.loading')}</div>
{:else if error}
  <ErrorPanel message={error} retry={load} />
{:else}
  <section class="grid three">
    <KpiCard label={$t('backlinks.totalLinks')} value={numberFormat.format(backlinks.length)} icon={Link2} />
    <KpiCard label={$t('backlinks.follow')} value={followCount} tone="success" icon={ShieldCheck} />
    <KpiCard label={$t('backlinks.pagerank')} value={avgPagerank.toFixed(1)} tone="violet" icon={Sigma} />
  </section>

  <section class="grid two" style="margin-top: 16px;">
    <div class="panel panel-inner">
      <h2>{$t('backlinks.pagerank')}</h2>
      <BarChart {labels} {values} ariaLabel={$t('backlinks.pagerank')} />
    </div>
    <div class="panel panel-inner">
      <h2>{$t('backlinks.title')}</h2>
      <DataTable
        rows={rows}
        columns={[
          { key: 'sourceDomain', label: $t('backlinks.source') },
          { key: 'anchor', label: $t('backlinks.anchor') },
          { key: 'sourcePagerank', label: $t('backlinks.pagerank'), align: 'right' },
          { key: 'nofollow', label: $t('app.type') }
        ]}
      />
    </div>
  </section>
{/if}
