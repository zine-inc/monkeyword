<script lang="ts">
  import { t } from '$lib/i18n';
  import type { AuditCheckStatus, CoachStatus, JobStatusValue } from '$lib/types';

  export let status: JobStatusValue | CoachStatus | AuditCheckStatus;

  $: tone =
    status === 'done' || status === 'pass'
      ? 'success'
      : status === 'running' || status === 'warn' || status === 'snoozed'
        ? 'warning'
        : status === 'fail'
          ? 'danger'
          : 'neutral';
</script>

<span class:tone-success={tone === 'success'} class:tone-warning={tone === 'warning'} class:tone-danger={tone === 'danger'} class="status">
  {$t(`status.${status}`)}
</span>

<style>
  .status {
    display: inline-flex;
    min-height: 24px;
    align-items: center;
    justify-content: center;
    border-radius: 999px;
    background: var(--surface-muted);
    color: var(--muted);
    font-size: 12px;
    font-weight: 800;
    padding: 0 9px;
    white-space: nowrap;
  }

  .tone-success {
    background: color-mix(in srgb, var(--success) 14%, var(--surface));
    color: var(--success);
  }

  .tone-warning {
    background: color-mix(in srgb, var(--warning) 14%, var(--surface));
    color: var(--warning);
  }

  .tone-danger {
    background: color-mix(in srgb, var(--danger) 14%, var(--surface));
    color: var(--danger);
  }
</style>
