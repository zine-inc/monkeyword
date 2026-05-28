<script lang="ts">
  export let label: string;
  export let value: string | number;
  export let detail = '';
  export let tone: 'accent' | 'info' | 'warning' | 'success' | 'violet' = 'accent';
  export let icon: any = null;
</script>

<section class="kpi panel" aria-label={label}>
  <div class="kpi-top">
    <span class:tone-info={tone === 'info'} class:tone-warning={tone === 'warning'} class:tone-success={tone === 'success'} class:tone-violet={tone === 'violet'} class="icon">
      {#if icon}
        <svelte:component this={icon} size={18} aria-hidden="true" />
      {/if}
    </span>
    <span class="label-text">{label}</span>
  </div>
  <strong>{value}</strong>
  {#if detail}
    <p>{detail}</p>
  {/if}
</section>

<style>
  .kpi {
    display: grid;
    gap: 10px;
    padding: 16px;
  }

  .kpi-top {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .label-text {
    color: var(--muted);
    font-size: 12px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0;
  }

  strong {
    color: var(--strong);
    font-size: 30px;
    line-height: 1;
  }

  p {
    font-size: 13px;
  }

  .icon {
    display: grid;
    width: 32px;
    height: 32px;
    place-items: center;
    border-radius: 7px;
    background: var(--accent-soft);
    color: var(--accent-strong);
  }

  .tone-info {
    background: color-mix(in srgb, var(--info) 16%, var(--surface));
    color: var(--info);
  }

  .tone-warning {
    background: color-mix(in srgb, var(--warning) 16%, var(--surface));
    color: var(--warning);
  }

  .tone-success {
    background: color-mix(in srgb, var(--success) 16%, var(--surface));
    color: var(--success);
  }

  .tone-violet {
    background: color-mix(in srgb, var(--violet) 16%, var(--surface));
    color: var(--violet);
  }
</style>
