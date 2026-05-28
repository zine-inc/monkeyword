<script lang="ts">
  export let items: { label: string; value: number; tone?: 'accent' | 'info' | 'warning' | 'success' | 'violet' }[] = [];
  export let ariaLabel = 'Priority wheel';

  const tones = {
    accent: 'var(--accent)',
    info: 'var(--info)',
    warning: 'var(--warning)',
    success: 'var(--success)',
    violet: 'var(--violet)'
  };

  $: max = Math.max(...items.map((item) => item.value), 1);
</script>

<div class="wheel" role="img" aria-label={ariaLabel}>
  <svg viewBox="-60 -60 120 120">
    <circle r="48" fill="none" stroke="var(--border)" stroke-width="1" />
    <circle r="32" fill="none" stroke="var(--border)" stroke-width="1" />
    <circle r="16" fill="none" stroke="var(--border)" stroke-width="1" />
    {#each items as item, index}
      {@const angle = (Math.PI * 2 * index) / Math.max(items.length, 1) - Math.PI / 2}
      {@const radius = 12 + (item.value / max) * 38}
      <line x1="0" y1="0" x2={radius * Math.cos(angle)} y2={radius * Math.sin(angle)} stroke={tones[item.tone ?? 'accent']} stroke-width="7" stroke-linecap="round">
        <title>{item.label}: {item.value}</title>
      </line>
    {/each}
  </svg>
  <div class="wheel-list" aria-hidden="true">
    {#each items as item}
      <span>{item.label}<strong>{item.value}</strong></span>
    {/each}
  </div>
</div>

<style>
  .wheel {
    display: grid;
    grid-template-columns: 180px minmax(0, 1fr);
    gap: 18px;
    align-items: center;
  }

  svg {
    width: 180px;
    height: 180px;
  }

  .wheel-list {
    display: grid;
    gap: 8px;
  }

  span {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    border-bottom: 1px solid var(--border);
    color: var(--muted);
    padding-bottom: 7px;
  }

  strong {
    color: var(--strong);
  }

  @media (max-width: 520px) {
    .wheel {
      grid-template-columns: 1fr;
    }
  }
</style>
