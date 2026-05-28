<script lang="ts">
  import { onMount } from 'svelte';
  import uPlot from 'uplot';
  import 'uplot/dist/uPlot.min.css';

  export let labels: string[] = [];
  export let values: number[] = [];
  export let ariaLabel = 'Line chart';
  export let inverted = false;

  let host: HTMLDivElement;
  let chart: uPlot | undefined;

  function draw() {
    if (!host) return;
    chart?.destroy();
    const width = Math.max(host.clientWidth, 320);
    const data: uPlot.AlignedData = [labels.map((_, index) => index), values];
    chart = new uPlot(
      {
        width,
        height: 260,
        cursor: { show: false },
        legend: { show: false },
        scales: { x: { time: false }, y: { dir: inverted ? -1 : 1 } },
        axes: [
          {
            stroke: getComputedStyle(document.documentElement).getPropertyValue('--muted'),
            grid: { show: false },
            values: (_u, vals) => vals.map((value) => labels[Math.round(value)] ?? '')
          },
          {
            stroke: getComputedStyle(document.documentElement).getPropertyValue('--muted'),
            grid: { stroke: getComputedStyle(document.documentElement).getPropertyValue('--border') }
          }
        ],
        series: [
          {},
          {
            stroke: getComputedStyle(document.documentElement).getPropertyValue('--accent'),
            width: 3,
            points: { size: 6 }
          }
        ]
      },
      data,
      host
    );
  }

  onMount(() => {
    draw();
    const observer = new ResizeObserver(draw);
    observer.observe(host);
    return () => {
      observer.disconnect();
      chart?.destroy();
    };
  });

  $: if (chart && labels && values) draw();
</script>

<div bind:this={host} class="chart-host" role="img" aria-label={ariaLabel}></div>

<style>
  .chart-host {
    width: 100%;
    min-height: 260px;
  }

  :global(.uplot) {
    max-width: 100%;
    color: var(--text);
    font-family: inherit;
  }
</style>
