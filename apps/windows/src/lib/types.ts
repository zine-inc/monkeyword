export type JobKind =
  | 'monkeyword/suggest'
  | 'monkeyword/rank'
  | 'monkeyword/backlink'
  | 'monkeyword/competitor'
  | 'monkeyword/audit'
  | 'monkeyword/brief'
  | 'monkeyword/gap'
  | 'monkeyword/topic_cluster'
  | 'monkeyword/content_optimize'
  | 'monkeyword/internal_link'
  | 'monkeyword/ai_coach';

export type JobWorker = 'worker-scraping' | 'worker-audit' | 'worker-llm';
export type JobStatusValue = 'queued' | 'running' | 'done';
export type IntentCluster = 'commercial' | 'informational' | 'transactional';
export type SerpFeature = 'paa' | 'image_pack' | 'local_pack' | 'video';
export type AuditCheckStatus = 'pass' | 'warn' | 'fail';
export type CoachStatus = 'todo' | 'done' | 'snoozed';
export type Locale = 'ja' | 'en';
export type Theme = 'light' | 'dark';

export interface Project {
  id: string;
  name: string;
  targetDomain: string;
  competitors: string[];
  createdAt: string;
}

export interface Job {
  id: string;
  projectId: string;
  kind: JobKind;
  status: JobStatusValue;
  scheduledAt: string;
  completedAt: string | null;
}

export interface Keyword {
  keyword: string;
  hl: string;
  gl: string;
  searchVolumeEst: number;
  intentCluster: IntentCluster;
  kdEst: number;
  llmSummary: string;
}

export interface Rank {
  keyword: string;
  position: number | null;
  url: string;
  snippet: string;
  featuredSnippet: boolean;
  serpFeatures: SerpFeature[];
  date: string;
  prevPosition: number | null;
}

export interface Backlink {
  sourceUrl: string;
  sourceDomain: string;
  targetUrl: string;
  anchor: string;
  sourcePagerank: number;
  nofollow: boolean;
}

export interface AuditCheck {
  name: string;
  status: AuditCheckStatus;
  detail: string;
}

export interface AuditReport {
  url: string;
  lighthouseScore: number;
  lcp: number;
  inp: number;
  cls: number;
  checks: AuditCheck[];
}

export interface Competitor {
  domain: string;
  topKeywords: string[];
  estimatedTraffic: number;
  keywordGap: string[];
}

export interface Brief {
  keyword: string;
  intent: string;
  outline: string[];
  faq: string[];
  internalLinks: string[];
}

export interface CoachAction {
  id: string;
  title: string;
  reasonOneLine: string;
  expectedEffect: string;
  status: CoachStatus;
  relatedKeyword: string;
  priority: number;
}

export interface JobKindDefinition {
  value: JobKind;
  worker: JobWorker;
  usesLlm: boolean;
  usesScraping: boolean;
}

export interface JobKindsSchema {
  kinds: JobKindDefinition[];
  generatedFrom: string;
  version: 1;
}

export interface PublicSettings {
  apiUrl: string;
  locale: Locale;
  theme: Theme;
  mockMode: true;
  hasApiKey: boolean;
}

export interface SettingsUpdate {
  apiUrl?: string;
  apiKey?: string;
  clearApiKey?: boolean;
  locale?: Locale;
  theme?: Theme;
  mockMode?: boolean;
}

export type FixtureName =
  | 'projects'
  | 'jobs'
  | 'keywords'
  | 'ranks'
  | 'backlinks'
  | 'audit'
  | 'competitors'
  | 'briefs'
  | 'coach'
  | 'job_kinds';

export interface FixtureMap {
  projects: Project[];
  jobs: Job[];
  keywords: Keyword[];
  ranks: Rank[];
  backlinks: Backlink[];
  audit: AuditReport[];
  competitors: Competitor[];
  briefs: Brief[];
  coach: CoachAction[];
  job_kinds: JobKindsSchema;
}

export interface HealthResponse {
  ok: boolean;
  mockMode: boolean;
  version: string;
}

export interface SubmitJobRequest {
  projectId: string;
  kind: JobKind;
  payload?: Record<string, unknown>;
}
