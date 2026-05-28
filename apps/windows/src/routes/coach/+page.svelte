<script lang="ts">
  import { onMount } from 'svelte';
  import { Bot, CheckCircle2, Clock3 } from '@lucide/svelte';
  import { readFixture } from '$lib/api';
  import { t } from '$lib/i18n';
  import type { CoachAction } from '$lib/types';
  import AtpWheel from '$lib/charts/AtpWheel.svelte';
  import ErrorPanel from '$lib/components/ErrorPanel.svelte';
  import JobStatus from '$lib/components/JobStatus.svelte';
  import KpiCard from '$lib/components/KpiCard.svelte';

  let actions: CoachAction[] = [];
  let loading = true;
  let error = '';

  async function load() {
    loading = true;
    error = '';
    try {
      actions = await readFixture('coach');
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'Unknown error';
    } finally {
      loading = false;
    }
  }

  onMount(load);

  $: sorted = actions.slice().sort((a, b) => b.priority - a.priority);
  $: todoCount = actions.filter((item) => item.status === 'todo').length;
  $: doneCount = actions.filter((item) => item.status === 'done').length;
  $: wheelItems = sorted.map((item, index) => ({
    label: item.relatedKeyword,
    value: item.priority,
    tone: (['accent', 'info', 'warning', 'success', 'violet'] as const)[index % 5]
  }));
</script>

<section class="page-head">
  <div>
    <p class="eyebrow">{$t('coach.eyebrow')}</p>
    <h1>{$t('coach.title')}</h1>
    <p>{$t('coach.body')}</p>
  </div>
</section>

{#if loading}
  <div class="loading">{$t('app.loading')}</div>
{:else if error}
  <ErrorPanel message={error} retry={load} />
{:else}
  <section class="grid three">
    <KpiCard label={$t('coach.priority')} value={Math.max(...actions.map((item) => item.priority))} icon={Bot} />
    <KpiCard label={$t('status.todo')} value={todoCount} tone="warning" icon={Clock3} />
    <KpiCard label={$t('status.done')} value={doneCount} tone="success" icon={CheckCircle2} />
  </section>

  <section class="grid two" style="margin-top: 16px;">
    <div class="panel panel-inner">
      <h2>{$t('coach.priority')}</h2>
      <AtpWheel items={wheelItems} ariaLabel={$t('coach.priority')} />
    </div>
    <div class="actions">
      {#each sorted as action}
        <article class="panel panel-inner action">
          <div class="row space-between">
            <h2>{action.title}</h2>
            <JobStatus status={action.status} />
          </div>
          <dl>
            <div>
              <dt>{$t('coach.priority')}</dt>
              <dd>{action.priority}</dd>
            </div>
            <div>
              <dt>{$t('coach.related')}</dt>
              <dd>{action.relatedKeyword}</dd>
            </div>
            <div>
              <dt>{$t('coach.reason')}</dt>
              <dd>{action.reasonOneLine}</dd>
            </div>
            <div>
              <dt>{$t('coach.effect')}</dt>
              <dd>{action.expectedEffect}</dd>
            </div>
          </dl>
        </article>
      {/each}
    </div>
  </section>
{/if}

<style>
  .actions {
    display: grid;
    gap: 12px;
  }

  .action {
    display: grid;
    gap: 14px;
  }

  dl {
    display: grid;
    gap: 10px;
    margin: 0;
  }

  dl div {
    display: grid;
    grid-template-columns: 120px minmax(0, 1fr);
    gap: 12px;
  }

  dt {
    color: var(--muted);
    font-weight: 900;
  }

  dd {
    margin: 0;
    color: var(--text);
    line-height: 1.45;
  }

  @media (max-width: 640px) {
    dl div {
      grid-template-columns: 1fr;
    }
  }
</style>
