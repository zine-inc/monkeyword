use crate::commands::CommandError;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::{fs, path::PathBuf};
use tauri::{path::BaseDirectory, AppHandle, Manager};

pub trait DataSource {
    fn read_fixture(&self, name: &str) -> Result<Value, CommandError>;
    fn submit_job(&self, request: JobRequest) -> Result<Value, CommandError>;
}

#[derive(Clone)]
pub struct MockSource {
    app: AppHandle,
}

impl MockSource {
    pub fn new(app: AppHandle) -> Self {
        Self { app }
    }
}

#[derive(Clone)]
pub struct LiveSource {
    api_url: String,
    _client: reqwest::Client,
}

impl LiveSource {
    pub fn new(api_url: String) -> Self {
        Self {
            api_url,
            _client: reqwest::Client::new(),
        }
    }
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct JobRequest {
    pub project_id: String,
    pub kind: String,
    pub payload: Option<Value>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct MockJob {
    id: String,
    project_id: String,
    kind: String,
    status: &'static str,
    scheduled_at: String,
    completed_at: Option<String>,
    payload_echo: Option<Value>,
}

impl DataSource for MockSource {
    fn read_fixture(&self, name: &str) -> Result<Value, CommandError> {
        let path = fixture_path(&self.app, name)?;
        let data = fs::read_to_string(path)
            .map_err(|_| CommandError::new("fixture_read_failed", "Fixture could not be read"))?;
        serde_json::from_str(&data)
            .map_err(|_| CommandError::new("fixture_parse_failed", "Fixture JSON is invalid"))
    }

    fn submit_job(&self, request: JobRequest) -> Result<Value, CommandError> {
        validate_job_kind(&request.kind)?;
        let now = utc_timestamp();
        let job = MockJob {
            id: format!("job_mock_{}", now.replace('-', "").replace(':', "").replace('T', "_")),
            project_id: request.project_id,
            kind: request.kind,
            status: "queued",
            scheduled_at: now,
            completed_at: None,
            payload_echo: request.payload,
        };
        Ok(json!(job))
    }
}

impl DataSource for LiveSource {
    fn read_fixture(&self, _name: &str) -> Result<Value, CommandError> {
        Err(CommandError::new(
            "live_source_disabled",
            format!("Live source is disabled in Phase 1 mock mode: {}", self.api_url),
        ))
    }

    fn submit_job(&self, _request: JobRequest) -> Result<Value, CommandError> {
        Err(CommandError::new(
            "live_source_disabled",
            format!("Live source is disabled in Phase 1 mock mode: {}", self.api_url),
        ))
    }
}

fn fixture_path(app: &AppHandle, name: &str) -> Result<PathBuf, CommandError> {
    let relative = fixture_relative_path(name)?;
    if let Ok(path) = app.path().resolve(relative, BaseDirectory::Resource) {
        if path.exists() {
            return Ok(path);
        }
    }

    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let fallback = manifest_dir.join("../../shared-fixtures").join(match name {
        "job_kinds" => "schema/job_kinds.json".to_string(),
        safe => format!("data/{safe}.json"),
    });

    if fallback.exists() {
        Ok(fallback)
    } else {
        Err(CommandError::new(
            "fixture_missing",
            "Fixture is not bundled with the application",
        ))
    }
}

fn fixture_relative_path(name: &str) -> Result<String, CommandError> {
    let filename = match name {
        "projects" | "jobs" | "keywords" | "ranks" | "backlinks" | "audit" | "competitors"
        | "briefs" | "coach" => format!("fixtures/data/{name}.json"),
        "job_kinds" => "fixtures/schema/job_kinds.json".to_string(),
        _ => {
            return Err(CommandError::new(
                "fixture_not_allowed",
                "Requested fixture is not available",
            ))
        }
    };
    Ok(filename)
}

fn validate_job_kind(kind: &str) -> Result<(), CommandError> {
    match kind {
        "monkeyword/suggest"
        | "monkeyword/rank"
        | "monkeyword/backlink"
        | "monkeyword/competitor"
        | "monkeyword/audit"
        | "monkeyword/brief"
        | "monkeyword/gap"
        | "monkeyword/topic_cluster"
        | "monkeyword/content_optimize"
        | "monkeyword/internal_link"
        | "monkeyword/ai_coach" => Ok(()),
        _ => Err(CommandError::new(
            "job_kind_not_allowed",
            "Requested job kind is not available",
        )),
    }
}

fn utc_timestamp() -> String {
    let seconds = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|duration| duration.as_secs())
        .unwrap_or(0);
    format!("2026-05-28T{:02}:{:02}:{:02}Z", (seconds / 3600) % 24, (seconds / 60) % 60, seconds % 60)
}
