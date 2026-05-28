<script lang="ts">
  import { onMount } from 'svelte';
  import '../app.css';
  import Sidebar from '$lib/components/Sidebar.svelte';
  import TopBar from '$lib/components/TopBar.svelte';
  import { getSettings } from '$lib/api';
  import { setLocale } from '$lib/i18n';
  import { applyTheme, initTheme } from '$lib/theme';

  onMount(async () => {
    initTheme();
    try {
      const settings = await getSettings();
      setLocale(settings.locale);
      applyTheme(settings.theme);
    } catch {
      setLocale('ja');
    }
  });
</script>

<div class="app-shell">
  <Sidebar />
  <div class="main-area">
    <TopBar />
    <main class="content" aria-label="monkeyword workspace">
      <slot />
    </main>
  </div>
</div>
