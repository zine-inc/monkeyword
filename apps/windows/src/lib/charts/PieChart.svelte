<script lang="ts">
  export let labels: string[] = [];
  export let values: number[] = [];
  export let ariaLabel = 'Pie chart';

  $: total = values.reduce((sum, value) => sum + value, 0) || 1;
  $: segments = values.map((value, index) => {
    const start = values.slice(0, index).reduce((sum, current) => sum + current, 0) / total;
    const end = start + value / total;
    const large = end - start > 0.5 ? 1 : 0;
    const startAngle = start * Math.PI * 2 - Math.PI / 2;
    const endAngle = end * Math.PI * 2 - Math.PI / 2;
    const x1 = 50 + 38 * Math.cos(startAngle);
    const y1 = 50 + 38 * Math.sin(startAngle);
    const x2 = 50 + 38 * Math.cos(endAngle);
    const y2 = 50 + 38 * Math.sin(endAngle);
    return {
      d: `M 50 50 L ${x1} ${y1} A 38 38 0 ${large} 1 ${x2} ${y2} Z`,
      label: labels[index] ?? '',
      value,
      color: ['var(--success)', 'var(--warning)', 'var(--danger)', 'var(--info)'][index % 4]
    };
  });
</script>

<div class="pie-wrap">
  <svg viewBox="0 0 100 100" role="img" aria-label={ariaLabel}>
    {#each segments as segment}
      <path d={segment.d} fill={segment.color}>
        <title>{segment.label}: {segment.value}</title>
      </path>
    {/each}
  </svg>
  <div class="legend" aria-hidden="true">
    {#each segments as segment}
      <span><i style={`background:${segment.color}`}></i>{segment.label} {segment.value}</span>
    {/each}
  </div>
</div>

<style>
  .pie-wrap {
    display: grid;
    grid-template-columns: 160px 1fr;
    gap: 18px;
    align-items: center;
  }

  svg {
    width: 160px;
    height: 160px;
  }

  .legend {
    display: grid;
    gap: 8px;
  }

  span {
    display: flex;
    align-items: center;
    gap: 8px;
    color: var(--text);
    font-weight: 700;
  }

  i {
    width: 12px;
    height: 12px;
    border-radius: 3px;
  }

  @media (max-width: 520px) {
    .pie-wrap {
      grid-template-columns: 1fr;
    }
  }
</style>
