<script lang="ts">
  import { onMount } from 'svelte';
  import uPlot from 'uplot';
  import 'uplot/dist/uPlot.min.css';

  export let labels: string[] = [];
  export let values: number[] = [];
  export let ariaLabel = 'Bar chart';

  let host: HTMLDivElement;
  let chart: uPlot | undefined;

  function drawBars(u: uPlot) {
    const ctx = u.ctx;
    const color = getComputedStyle(document.documentElement).getPropertyValue('--accent');
    const xValues = u.data[0] as number[];
    const yValues = u.data[1] as number[];
    const plotWidth = u.bbox.width / devicePixelRatio;
    const barWidth = Math.max(16, Math.min(42, plotWidth / Math.max(xValues.length, 1) - 14));
    ctx.save();
    ctx.fillStyle = color;
    xValues.forEach((x, index) => {
      const value = yValues[index] ?? 0;
      const left = u.valToPos(x, 'x', true) - barWidth / 2;
      const top = u.valToPos(value, 'y', true);
      const bottom = u.valToPos(0, 'y', true);
      ctx.fillRect(left, top, barWidth, Math.max(0, bottom - top));
    });
    ctx.restore();
  }

  function draw() {
    if (!host) return;
    chart?.destroy();
    const muted = getComputedStyle(document.documentElement).getPropertyValue('--muted');
    const border = getComputedStyle(document.documentElement).getPropertyValue('--border');
    chart = new uPlot(
      {
        width: Math.max(host.clientWidth, 320),
        height: 260,
        cursor: { show: false },
        legend: { show: false },
        scales: { x: { time: false }, y: { range: (_u, _min, max) => [0, max * 1.18] } },
        axes: [
          {
            stroke: muted,
            grid: { show: false },
            values: (_u, vals) => vals.map((value) => labels[Math.round(value)] ?? '')
          },
          { stroke: muted, grid: { stroke: border } }
        ],
        series: [{}, { stroke: 'transparent', points: { show: false } }],
        hooks: { draw: [drawBars] }
      },
      [labels.map((_, index) => index), values],
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
</style>
