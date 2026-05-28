<script lang="ts">
  import { onMount } from 'svelte';
  import uPlot from 'uplot';
  import 'uplot/dist/uPlot.min.css';

  export let values: number[] = [];
  export let ariaLabel = 'Sparkline';
  export let inverted = false;

  let host: HTMLDivElement;
  let chart: uPlot | undefined;

  function draw() {
    if (!host) return;
    chart?.destroy();
    const color = getComputedStyle(document.documentElement).getPropertyValue('--accent');
    chart = new uPlot(
      {
        width: Math.max(host.clientWidth, 140),
        height: 48,
        cursor: { show: false },
        legend: { show: false },
        scales: { x: { time: false }, y: { dir: inverted ? -1 : 1 } },
        axes: [],
        series: [{}, { stroke: color, width: 2, points: { show: false } }]
      },
      [values.map((_, index) => index), values],
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

  $: if (chart && values) draw();
</script>

<div bind:this={host} class="spark" role="img" aria-label={ariaLabel}></div>

<style>
  .spark {
    width: 100%;
    min-width: 140px;
    min-height: 48px;
  }
</style>
