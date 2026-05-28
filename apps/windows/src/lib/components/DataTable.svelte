<script lang="ts">
  import { t } from '$lib/i18n';

  interface Column {
    key: string;
    label: string;
    align?: 'left' | 'right';
    format?: (value: unknown, row: Record<string, unknown>) => string | number | boolean;
  }

  export let columns: Column[] = [];
  export let rows: Record<string, unknown>[] = [];
  export let caption = '';
</script>

<div class="table-wrap">
  <table>
    {#if caption}
      <caption>{caption}</caption>
    {/if}
    <thead>
      <tr>
        {#each columns as column}
          <th class:right={column.align === 'right'} scope="col">{column.label}</th>
        {/each}
      </tr>
    </thead>
    <tbody>
      {#each rows as row}
        <tr>
          {#each columns as column}
            <td class:right={column.align === 'right'}>
              {column.format ? column.format(row[column.key], row) : row[column.key]}
            </td>
          {/each}
        </tr>
      {:else}
        <tr>
          <td colspan={columns.length || 1} class="empty">{$t('app.noRows')}</td>
        </tr>
      {/each}
    </tbody>
  </table>
</div>

<style>
  .table-wrap {
    width: 100%;
    overflow-x: auto;
  }

  table {
    width: 100%;
    min-width: 680px;
    border-collapse: collapse;
  }

  caption {
    text-align: left;
    color: var(--muted);
    padding: 0 0 10px;
  }

  th,
  td {
    border-bottom: 1px solid var(--border);
    padding: 12px 14px;
    text-align: left;
    vertical-align: top;
  }

  th {
    color: var(--muted);
    font-size: 12px;
    font-weight: 900;
    text-transform: uppercase;
    letter-spacing: 0;
  }

  td {
    color: var(--text);
  }

  tr:last-child td {
    border-bottom: 0;
  }

  .right {
    text-align: right;
  }

  .empty {
    color: var(--muted);
    text-align: center;
  }
</style>
