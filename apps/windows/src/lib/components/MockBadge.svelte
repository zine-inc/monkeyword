<script lang="ts">
  import { FlaskConical } from '@lucide/svelte';
  import { t } from '$lib/i18n';
</script>

<span class="badge mock" aria-label={$t('app.mockMode')}>
  <FlaskConical size={15} aria-hidden="true" />
  <span>{$t('app.mockMode')}</span>
</span>

<style>
  span {
    gap: 7px;
  }
</style>
