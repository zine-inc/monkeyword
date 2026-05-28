<script lang="ts">
  import { onMount } from 'svelte';
  import { readFixture } from '$lib/api';
  import { t } from '$lib/i18n';
  import type { Project } from '$lib/types';

  let projects: Project[] = [];
  let selected = '';

  onMount(async () => {
    projects = await readFixture('projects');
    selected = projects[0]?.id ?? '';
  });
</script>

<label class="picker">
  <span>{$t('app.project')}</span>
  <select class="select" bind:value={selected} aria-label={$t('app.project')}>
    {#each projects as project}
      <option value={project.id}>{project.name}</option>
    {/each}
  </select>
</label>

<style>
  .picker {
    display: grid;
    min-width: min(280px, 100%);
    gap: 6px;
    color: var(--muted);
    font-size: 12px;
    font-weight: 800;
  }
</style>
