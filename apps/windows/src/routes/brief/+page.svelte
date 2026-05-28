<script lang="ts">
  import { onMount } from 'svelte';
  import { RefreshCw } from '@lucide/svelte';
  import { readFixture, submitJob } from '$lib/api';
  import { t } from '$lib/i18n';
  import type { Brief, Job } from '$lib/types';
  import ErrorPanel from '$lib/components/ErrorPanel.svelte';
  import JobStatus from '$lib/components/JobStatus.svelte';

  let briefs: Brief[] = [];
  let job: Job | null = null;
  let loading = true;
  let submitting = false;
  let error = '';

  async function load() {
    loading = true;
    error = '';
    try {
      briefs = await readFixture('briefs');
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'Unknown error';
    } finally {
      loading = false;
    }
  }

  async function optimize() {
    submitting = true;
    error = '';
    try {
      job = await submitJob({
        projectId: 'proj_demo',
        kind: 'monkeyword/content_optimize',
        payload: { keyword: brief?.keyword }
      });
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'Unknown error';
    } finally {
      submitting = false;
    }
  }

  onMount(load);

  $: brief = briefs[0];
</script>

<section class="page-head">
  <div>
    <p class="eyebrow">{$t('brief.eyebrow')}</p>
    <h1>{$t('brief.title')}</h1>
    <p>{$t('brief.body')}</p>
  </div>
  <button class="button primary" type="button" on:click={optimize} disabled={submitting || !brief} aria-label={$t('brief.optimize')}>
    <RefreshCw size={16} aria-hidden="true" />
    {$t('brief.optimize')}
  </button>
</section>

{#if loading}
  <div class="loading">{$t('app.loading')}</div>
{:else if error}
  <ErrorPanel message={error} retry={load} />
{:else if brief}
  <section class="grid two">
    <article class="panel panel-inner">
      <p class="eyebrow">{brief.keyword}</p>
      <h2>{$t('brief.intent')}</h2>
      <p>{brief.intent}</p>
      {#if job}
        <div class="job">
          <JobStatus status={job.status} />
          <span>{job.id}</span>
        </div>
      {/if}
    </article>
    <article class="panel panel-inner">
      <h2>{$t('brief.internalLinks')}</h2>
      <ul>
        {#each brief.internalLinks as link}
          <li>{link}</li>
        {/each}
      </ul>
    </article>
  </section>

  <section class="grid two" style="margin-top: 16px;">
    <article class="panel panel-inner">
      <h2>{$t('brief.outline')}</h2>
      <ol>
        {#each brief.outline as item}
          <li>{item}</li>
        {/each}
      </ol>
    </article>
    <article class="panel panel-inner">
      <h2>{$t('brief.faq')}</h2>
      <ul>
        {#each brief.faq as item}
          <li>{item}</li>
        {/each}
      </ul>
    </article>
  </section>
{/if}

<style>
  ul,
  ol {
    display: grid;
    gap: 10px;
    margin: 0;
    padding-left: 22px;
  }

  li {
    line-height: 1.55;
  }

  .job {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-top: 18px;
  }

  .job span {
    color: var(--muted);
    font-size: 12px;
  }
</style>
