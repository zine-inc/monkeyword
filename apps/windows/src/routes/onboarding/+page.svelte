<script lang="ts">
  import { onMount } from 'svelte';
  import { ArrowRight, CheckCircle2, Globe2, ListChecks, Search } from '@lucide/svelte';
  import { readFixture, submitJob } from '$lib/api';
  import { t } from '$lib/i18n';
  import type { Job, Project } from '$lib/types';
  import ErrorPanel from '$lib/components/ErrorPanel.svelte';
  import JobStatus from '$lib/components/JobStatus.svelte';

  let projects: Project[] = [];
  let queuedJob: Job | null = null;
  let loading = true;
  let submitting = false;
  let error = '';

  async function load() {
    loading = true;
    error = '';
    try {
      projects = await readFixture('projects');
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'Unknown error';
    } finally {
      loading = false;
    }
  }

  async function startDemo() {
    submitting = true;
    error = '';
    try {
      queuedJob = await submitJob({
        projectId: projects[0]?.id ?? 'proj_demo',
        kind: 'monkeyword/suggest',
        payload: { source: 'onboarding' }
      });
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'Unknown error';
    } finally {
      submitting = false;
    }
  }

  onMount(load);
</script>

<section class="page-head">
  <div>
    <p class="eyebrow">{$t('onboarding.eyebrow')}</p>
    <h1>{$t('onboarding.title')}</h1>
    <p>{$t('onboarding.body')}</p>
  </div>
  <button class="button primary" type="button" on:click={startDemo} disabled={submitting || loading} aria-label={$t('onboarding.start')}>
    <ArrowRight size={16} aria-hidden="true" />
    {$t('onboarding.start')}
  </button>
</section>

{#if loading}
  <div class="loading">{$t('app.loading')}</div>
{:else if error}
  <ErrorPanel message={error} retry={load} />
{:else}
  <section class="grid three">
    <article class="panel panel-inner step">
      <Globe2 size={24} aria-hidden="true" />
      <h2>{$t('onboarding.step1')}</h2>
      <strong>{projects[0]?.targetDomain}</strong>
      <p>{projects[0]?.competitors.join(' / ')}</p>
    </article>
    <article class="panel panel-inner step">
      <Search size={24} aria-hidden="true" />
      <h2>{$t('onboarding.step2')}</h2>
      <strong>{$t('onboarding.keywordCount')}</strong>
      <p>2026-05-22 - 2026-05-28</p>
    </article>
    <article class="panel panel-inner step">
      <ListChecks size={24} aria-hidden="true" />
      <h2>{$t('onboarding.step3')}</h2>
      <strong>{$t('onboarding.actionCount')}</strong>
      <p>{$t('app.mockDetail')}</p>
    </article>
  </section>

  {#if queuedJob}
    <section class="panel panel-inner queued" role="status">
      <CheckCircle2 size={22} aria-hidden="true" />
      <div>
        <h2>{$t('onboarding.queued')}</h2>
        <p>{queuedJob.id}</p>
      </div>
      <JobStatus status={queuedJob.status} />
    </section>
  {/if}
{/if}

<style>
  .step {
    display: grid;
    gap: 12px;
  }

  .step :global(svg) {
    color: var(--accent-strong);
  }

  .step strong {
    color: var(--strong);
    font-size: 20px;
  }

  .queued {
    display: flex;
    align-items: center;
    gap: 14px;
    margin-top: 16px;
  }

  .queued :global(svg) {
    color: var(--success);
  }

  .queued div {
    min-width: 0;
    flex: 1;
  }
</style>
