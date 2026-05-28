import { invoke } from '@tauri-apps/api/core';
import projects from '../../../shared-fixtures/data/projects.json';
import jobs from '../../../shared-fixtures/data/jobs.json';
import keywords from '../../../shared-fixtures/data/keywords.json';
import ranks from '../../../shared-fixtures/data/ranks.json';
import backlinks from '../../../shared-fixtures/data/backlinks.json';
import audit from '../../../shared-fixtures/data/audit.json';
import competitors from '../../../shared-fixtures/data/competitors.json';
import briefs from '../../../shared-fixtures/data/briefs.json';
import coach from '../../../shared-fixtures/data/coach.json';
import jobKinds from '../../../shared-fixtures/schema/job_kinds.json';
import type {
  FixtureMap,
  FixtureName,
  HealthResponse,
  Job,
  PublicSettings,
  SettingsUpdate,
  SubmitJobRequest
} from './types';

const localFixtures = {
  projects,
  jobs,
  keywords,
  ranks,
  backlinks,
  audit,
  competitors,
  briefs,
  coach,
  job_kinds: jobKinds
} as FixtureMap;

const defaultSettings: PublicSettings = {
  apiUrl: '',
  locale: 'ja',
  theme: 'light',
  mockMode: true,
  hasApiKey: false
};

function isTauriRuntime() {
  return typeof window !== 'undefined' && '__TAURI_INTERNALS__' in window;
}

function clone<T>(value: T): T {
  return JSON.parse(JSON.stringify(value)) as T;
}

function browserSettings(): PublicSettings {
  if (typeof localStorage === 'undefined') return defaultSettings;
  const raw = localStorage.getItem('monkeyword.settings');
  if (!raw) return defaultSettings;
  try {
    return { ...defaultSettings, ...JSON.parse(raw), mockMode: true, hasApiKey: false };
  } catch {
    return defaultSettings;
  }
}

export async function readFixture<Name extends FixtureName>(
  name: Name
): Promise<FixtureMap[Name]> {
  if (isTauriRuntime()) {
    return invoke<FixtureMap[Name]>('read_fixture', { name });
  }
  return clone(localFixtures[name]);
}

export async function healthCheck(): Promise<HealthResponse> {
  if (isTauriRuntime()) {
    return invoke<HealthResponse>('health_check');
  }
  return { ok: true, mockMode: true, version: 'web-preview' };
}

export async function submitJob(request: SubmitJobRequest): Promise<Job> {
  if (isTauriRuntime()) {
    return invoke<Job>('submit_job', { request });
  }
  const now = new Date().toISOString();
  return {
    id: `job_mock_${Date.now()}`,
    projectId: request.projectId,
    kind: request.kind,
    status: 'queued',
    scheduledAt: now,
    completedAt: null
  };
}

export async function getSettings(): Promise<PublicSettings> {
  if (isTauriRuntime()) {
    return invoke<PublicSettings>('get_settings');
  }
  return browserSettings();
}

export async function saveSettings(update: SettingsUpdate): Promise<PublicSettings> {
  if (isTauriRuntime()) {
    return invoke<PublicSettings>('save_settings', { update });
  }
  const next: PublicSettings = {
    ...browserSettings(),
    ...update,
    mockMode: true,
    hasApiKey: false
  };
  if (typeof localStorage !== 'undefined') {
    const { apiUrl, locale, theme, mockMode } = next;
    localStorage.setItem(
      'monkeyword.settings',
      JSON.stringify({ apiUrl, locale, theme, mockMode })
    );
  }
  return next;
}

export async function loadCoreData() {
  const [projects, jobs, keywords, ranks, backlinks, audit, competitors, briefs, coach] =
    await Promise.all([
      readFixture('projects'),
      readFixture('jobs'),
      readFixture('keywords'),
      readFixture('ranks'),
      readFixture('backlinks'),
      readFixture('audit'),
      readFixture('competitors'),
      readFixture('briefs'),
      readFixture('coach')
    ]);
  return { projects, jobs, keywords, ranks, backlinks, audit, competitors, briefs, coach };
}
