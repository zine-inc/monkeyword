<script lang="ts">
  import { onMount } from 'svelte';
  import { Gauge, Timer, Zap } from '@lucide/svelte';
  import { readFixture } from '$lib/api';
  import { t } from '$lib/i18n';
  import type { AuditReport } from '$lib/types';
  import AtpWheel from '$lib/charts/AtpWheel.svelte';
  import PieChart from '$lib/charts/PieChart.svelte';
  import ErrorPanel from '$lib/components/ErrorPanel.svelte';
  import JobStatus from '$lib/components/JobStatus.svelte';
  import KpiCard from '$lib/components/KpiCard.svelte';

  let reports: AuditReport[] = [];
  let loading = true;
  let error = '';

  async function load() {
    loading = true;
    error = '';
    try {
      reports = await readFixture('audit');
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'Unknown error';
    } finally {
      loading = false;
    }
  }

  onMount(load);

  $: report = reports[0];
  $: passCount = report?.checks.filter((check) => check.status === 'pass').length ?? 0;
  $: warnCount = report?.checks.filter((check) => check.status === 'warn').length ?? 0;
  $: failCount = report?.checks.filter((check) => check.status === 'fail').length ?? 0;
  $: vitals = report
    ? [
        { label: 'LCP', value: Math.max(0, 5 - report.lcp), tone: 'success' as const },
        { label: 'INP', value: Math.max(0, 300 - report.inp) / 40, tone: 'info' as const },
        { label: 'CLS', value: Math.max(0, 0.25 - report.cls) * 28, tone: 'violet' as const },
        { label: 'Score', value: report.lighthouseScore / 12, tone: 'accent' as const }
      ]
    : [];
</script>

<section class="page-head">
  <div>
    <p class="eyebrow">{$t('audit.eyebrow')}</p>
    <h1>{$t('audit.title')}</h1>
    <p>{$t('audit.body')}</p>
  </div>
</section>

{#if loading}
  <div class="loading">{$t('app.loading')}</div>
{:else if error}
  <ErrorPanel message={error} retry={load} />
{:else if report}
  <section class="grid four">
    <KpiCard label={$t('audit.score')} value={report.lighthouseScore} detail={report.url} icon={Gauge} />
    <KpiCard label="LCP" value={`${report.lcp}s`} tone="success" icon={Timer} />
    <KpiCard label="INP" value={`${report.inp}ms`} tone="info" icon={Zap} />
    <KpiCard label="CLS" value={report.cls.toFixed(2)} tone="violet" icon={Gauge} />
  </section>

  <section class="grid two" style="margin-top: 16px;">
    <div class="panel panel-inner">
      <h2>{$t('audit.checks')}</h2>
      <PieChart labels={[$t('audit.passed'), $t('audit.warning'), $t('audit.failed')]} values={[passCount, warnCount, failCount]} ariaLabel={$t('audit.checks')} />
    </div>
    <div class="panel panel-inner">
      <h2>{$t('audit.coreWebVitals')}</h2>
      <AtpWheel items={vitals} ariaLabel={$t('audit.coreWebVitals')} />
    </div>
  </section>

  <section class="panel checks" style="margin-top: 16px;">
    {#each report.checks as check}
      <article>
        <div>
          <h3>{check.name}</h3>
          <p>{check.detail}</p>
        </div>
        <JobStatus status={check.status} />
      </article>
    {/each}
  </section>
{/if}

<style>
  .checks {
    display: grid;
  }

  article {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 18px;
    border-bottom: 1px solid var(--border);
    padding: 16px 18px;
  }

  article:last-child {
    border-bottom: 0;
  }

  article div {
    min-width: 0;
  }
</style>
