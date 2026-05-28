import type { Rank } from './types';

export const numberFormat = new Intl.NumberFormat('en-US');
export const percentFormat = new Intl.NumberFormat('en-US', { maximumFractionDigits: 1 });

export function compactNumber(value: number) {
  return new Intl.NumberFormat('en-US', { notation: 'compact', maximumFractionDigits: 1 }).format(value);
}

export function average(values: number[]) {
  if (!values.length) return 0;
  return values.reduce((sum, value) => sum + value, 0) / values.length;
}

export function latestRanks(ranks: Rank[]) {
  const byKeyword = new Map<string, Rank>();
  for (const rank of ranks) {
    const current = byKeyword.get(rank.keyword);
    if (!current || rank.date > current.date) {
      byKeyword.set(rank.keyword, rank);
    }
  }
  return Array.from(byKeyword.values()).sort((a, b) => (a.position ?? 999) - (b.position ?? 999));
}

export function rankTrend(ranks: Rank[]) {
  const dates = Array.from(new Set(ranks.map((rank) => rank.date))).sort();
  const values = dates.map((date) => {
    const positions = ranks
      .filter((rank) => rank.date === date && rank.position !== null)
      .map((rank) => rank.position as number);
    return Number(average(positions).toFixed(1));
  });
  return { dates, values };
}

export function rows<T extends Record<string, unknown>>(items: T[]) {
  return items as Record<string, unknown>[];
}
