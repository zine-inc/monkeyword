<script lang="ts">
  import { page } from '$app/stores';
  import {
    BarChart3,
    Bot,
    ClipboardCheck,
    FileText,
    Gauge,
    Home,
    Link as LinkIcon,
    Rocket,
    Search,
    Settings,
    TrendingUp,
    Users
  } from '@lucide/svelte';
  import MockBadge from './MockBadge.svelte';
  import { t } from '$lib/i18n';

  const items = [
    { href: '/onboarding', key: 'onboarding', icon: Rocket },
    { href: '/', key: 'dashboard', icon: Home },
    { href: '/keywords', key: 'keywords', icon: Search },
    { href: '/ranks', key: 'ranks', icon: TrendingUp },
    { href: '/backlinks', key: 'backlinks', icon: LinkIcon },
    { href: '/audit', key: 'audit', icon: ClipboardCheck },
    { href: '/competitors', key: 'competitors', icon: Users },
    { href: '/brief', key: 'brief', icon: FileText },
    { href: '/coach', key: 'coach', icon: Bot },
    { href: '/settings', key: 'settings', icon: Settings }
  ];

  $: current = $page.url.pathname;
</script>

<aside class="sidebar" aria-label="monkeyword navigation">
  <div class="brand">
    <div class="mark" aria-hidden="true">
      <Gauge size={22} />
    </div>
    <div>
      <strong>{$t('app.name')}</strong>
      <span>{$t('app.subtitle')}</span>
    </div>
  </div>

  <MockBadge />

  <nav aria-label="Primary">
    {#each items as item}
      <a class:active={current === item.href} href={item.href} aria-current={current === item.href ? 'page' : undefined}>
        <svelte:component this={item.icon} size={18} aria-hidden="true" />
        <span>{$t(`nav.${item.key}`)}</span>
      </a>
    {/each}
  </nav>
</aside>

<style>
  .brand {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 16px;
  }

  .mark {
    display: grid;
    width: 42px;
    height: 42px;
    place-items: center;
    border-radius: 8px;
    background: var(--accent);
    color: #ffffff;
  }

  strong,
  span {
    display: block;
  }

  strong {
    color: var(--strong);
    font-size: 17px;
  }

  .brand span {
    color: var(--muted);
    font-size: 12px;
  }

  nav {
    display: grid;
    gap: 4px;
    margin-top: 18px;
  }

  a {
    display: flex;
    min-height: 38px;
    align-items: center;
    gap: 10px;
    border-radius: 7px;
    color: var(--muted);
    font-weight: 750;
    padding: 0 10px;
    text-decoration: none;
  }

  a:hover,
  a.active {
    background: var(--surface);
    color: var(--strong);
  }

  a.active {
    box-shadow: inset 3px 0 0 var(--accent);
  }
</style>
