<script lang="ts">
  import { RotateCw } from '@lucide/svelte';
  import { t } from '$lib/i18n';

  export let message = '';
  export let retry: (() => void) | undefined;
</script>

<section class="error-state" role="alert">
  <div class="stack">
    <div>
      <h2>{$t('app.offlineTitle')}</h2>
      <p>{$t('app.offlineBody')}</p>
      {#if message}
        <p>{message}</p>
      {/if}
    </div>
    {#if retry}
      <button class="button" type="button" on:click={retry} aria-label={$t('app.retry')}>
        <RotateCw size={16} aria-hidden="true" />
        {$t('app.retry')}
      </button>
    {/if}
  </div>
</section>
