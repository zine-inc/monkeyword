use crate::datasource::{DataSource, JobRequest, MockSource};
use crate::settings::{PublicSettings, SettingsUpdate};
use serde::Serialize;
use serde_json::Value;
use tauri::AppHandle;

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct CommandError {
    pub code: &'static str,
    pub message: String,
}

impl CommandError {
    pub fn new(code: &'static str, message: impl Into<String>) -> Self {
        Self {
            code,
            message: message.into(),
        }
    }
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct HealthResponse {
    pub ok: bool,
    pub mock_mode: bool,
    pub version: &'static str,
}

#[tauri::command]
pub fn health_check() -> HealthResponse {
    HealthResponse {
        ok: true,
        mock_mode: true,
        version: env!("CARGO_PKG_VERSION"),
    }
}

#[tauri::command]
pub fn read_fixture(app: AppHandle, name: String) -> Result<Value, CommandError> {
    MockSource::new(app).read_fixture(&name)
}

#[tauri::command]
pub fn submit_job(app: AppHandle, request: JobRequest) -> Result<Value, CommandError> {
    MockSource::new(app).submit_job(request)
}

#[tauri::command]
pub fn get_settings(app: AppHandle) -> Result<PublicSettings, CommandError> {
    crate::settings::get_settings(&app)
}

#[tauri::command]
pub fn save_settings(
    app: AppHandle,
    update: SettingsUpdate,
) -> Result<PublicSettings, CommandError> {
    crate::settings::save_settings(&app, update)
}
