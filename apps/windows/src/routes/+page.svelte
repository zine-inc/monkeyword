<script lang="ts">
  import { onMount } from 'svelte';
  import { Activity, CheckCircle2, Clock3, Search } from '@lucide/svelte';
  import { loadCoreData } from '$lib/api';
  import { average, compactNumber, latestRanks, numberFormat, rankTrend } from '$lib/format';
  import { t } from '$lib/i18n';
  import type { Job } from '$lib/types';
  import KpiCard from '$lib/components/KpiCard.svelte';
  import DataTable from '$lib/components/DataTable.svelte';
  import ErrorPanel from '$lib/components/ErrorPanel.svelte';
  import JobStatus from '$lib/components/JobStatus.svelte';
  import BarChart from '$lib/charts/BarChart.svelte';
  import LineChart from '$lib/charts/LineChart.svelte';

  let data: Awaited<ReturnType<typeof loadCoreData>> | null = null;
  let loading = true;
  let error = '';

  async function load() {
    loading = true;
    error = '';
    try {
      data = await loadCoreData();
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'Unknown error';
    } finally {
      loading = false;
    }
  }

  onMount(load);

  $: latest = data ? latestRanks(data.ranks) : [];
  $: avgRank = average(latest.filter((rank) => rank.position !== null).map((rank) => rank.position as number));
  $: openJobs = data ? data.jobs.filter((job) => job.status !== 'done') : [];
  $: trend = data ? rankTrend(data.ranks) : { dates: [], values: [] };
  let intentGroups: { label: string; value: number }[] = [];
  $: {
    const current = data;
    intentGroups = current
      ? ['commercial', 'informational', 'transactional'].map((intent) => ({
          label: intent,
          value: current.keywords
            .filter((keyword) => keyword.intentCluster === intent)
            .reduce((sum, keyword) => sum + keyword.searchVolumeEst, 0)
        }))
      : [];
  }
  $: actionRows = data
    ? data.coach
        .filter((item) => item.status !== 'done')
        .sort((a, b) => b.priority - a.priority)
        .slice(0, 5)
        .map((item) => ({
          title: item.title,
          priority: item.priority,
          keyword: item.relatedKeyword,
          effect: item.expectedEffect
        }))
    : [];
  $: recentJobs = data ? data.jobs.slice(0, 6) : [];

  function kindLabel(job: Job) {
    return job.kind.replace('monkeyword/', '');
  }
</script>

<section class="page-head">
  <div>
    <p class="eyebrow">{$t('dashboard.eyebrow')}</p>
    <h1>{$t('dashboard.title')}</h1>
    <p>{$t('dashboard.body')}</p>
  </div>
</section>

{#if loading}
  <div class="loading">{$t('app.loading')}</div>
{:else if error}
  <ErrorPanel message={error} retry={load} />
{:else if data}
  <section class="grid four" aria-label="Dashboard KPIs">
    <KpiCard label={$t('dashboard.trackedKeywords')} value={numberFormat.format(data.keywords.length)} detail={data.projects[0]?.targetDomain ?? ''} icon={Search} />
    <KpiCard label={$t('dashboard.averageRank')} value={avgRank.toFixed(1)} detail={$t('app.fixtureWindow')} tone="info" icon={Activity} />
    <KpiCard label={$t('dashboard.openJobs')} value={openJobs.length} detail={openJobs.map(kindLabel).join(', ')} tone="warning" icon={Clock3} />
    <KpiCard label={$t('dashboard.coachItems')} value={data.coach.filter((item) => item.status !== 'done').length} detail={compactNumber(data.keywords.reduce((sum, keyword) => sum + keyword.searchVolumeEst, 0)) + ' volume'} tone="success" icon={CheckCircle2} />
  </section>

  <section class="grid two" style="margin-top: 16px;">
    <div class="panel panel-inner">
      <h2>{$t('dashboard.rankTrend')}</h2>
      <LineChart labels={trend.dates} values={trend.values} inverted ariaLabel={$t('dashboard.rankTrend')} />
    </div>
    <div class="panel panel-inner">
      <h2>{$t('dashboard.intentMix')}</h2>
      <BarChart labels={intentGroups.map((item) => item.label)} values={intentGroups.map((item) => item.value)} ariaLabel={$t('dashboard.intentMix')} />
    </div>
  </section>

  <section class="grid two" style="margin-top: 16px;">
    <div class="panel">
      <div class="panel-inner">
        <h2>{$t('dashboard.recentJobs')}</h2>
      </div>
      <div class="job-list">
        {#each recentJobs as job}
          <div class="job-row">
            <div>
              <strong>{kindLabel(job)}</strong>
              <span>{job.scheduledAt}</span>
            </div>
            <JobStatus status={job.status} />
          </div>
        {/each}
      </div>
    </div>
    <div class="panel panel-inner">
      <h2>{$t('dashboard.nextActions')}</h2>
      <DataTable
        rows={actionRows}
        columns={[
          { key: 'title', label: $t('coach.reason') },
          { key: 'keyword', label: $t('coach.related') },
          { key: 'priority', label: $t('coach.priority'), align: 'right' },
          { key: 'effect', label: $t('coach.effect') }
        ]}
      />
    </div>
  </section>
{/if}

<style>
  .job-list {
    display: grid;
  }

  .job-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 14px;
    border-top: 1px solid var(--border);
    padding: 14px 18px;
  }

  .job-row strong,
  .job-row span {
    display: block;
  }

  .job-row span {
    color: var(--muted);
    font-size: 12px;
    margin-top: 4px;
  }
</style>
