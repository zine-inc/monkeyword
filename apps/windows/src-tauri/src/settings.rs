use crate::commands::CommandError;
use serde::{Deserialize, Serialize};
use serde_json::json;
use tauri::AppHandle;
use tauri_plugin_store::StoreExt;

const STORE_FILE: &str = "settings.json";

#[derive(Debug, Clone, Copy, Deserialize, Serialize)]
#[serde(rename_all = "lowercase")]
pub enum Locale {
    Ja,
    En,
}

#[derive(Debug, Clone, Copy, Deserialize, Serialize)]
#[serde(rename_all = "lowercase")]
pub enum Theme {
    Light,
    Dark,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SettingsUpdate {
    pub api_url: Option<String>,
    pub api_key: Option<String>,
    pub clear_api_key: Option<bool>,
    pub locale: Option<Locale>,
    pub theme: Option<Theme>,
    pub mock_mode: Option<bool>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct PublicSettings {
    pub api_url: String,
    pub locale: Locale,
    pub theme: Theme,
    pub mock_mode: bool,
    pub has_api_key: bool,
}

pub fn get_settings(app: &AppHandle) -> Result<PublicSettings, CommandError> {
    let store = app
        .store(STORE_FILE)
        .map_err(|_| CommandError::new("settings_store_failed", "Settings store is unavailable"))?;
    let api_url = store
        .get("apiUrl")
        .and_then(|value| value.as_str().map(ToOwned::to_owned))
        .unwrap_or_default();
    let locale = match store.get("locale").and_then(|value| value.as_str().map(ToOwned::to_owned)) {
        Some(value) if value == "en" => Locale::En,
        _ => Locale::Ja,
    };
    let theme = match store.get("theme").and_then(|value| value.as_str().map(ToOwned::to_owned)) {
        Some(value) if value == "dark" => Theme::Dark,
        _ => Theme::Light,
    };
    let has_api_key = store
        .get("apiKey")
        .and_then(|value| value.as_str().map(|text| !text.is_empty()))
        .unwrap_or(false);

    Ok(PublicSettings {
        api_url,
        locale,
        theme,
        mock_mode: true,
        has_api_key,
    })
}

pub fn save_settings(
    app: &AppHandle,
    update: SettingsUpdate,
) -> Result<PublicSettings, CommandError> {
    let store = app
        .store(STORE_FILE)
        .map_err(|_| CommandError::new("settings_store_failed", "Settings store is unavailable"))?;

    if let Some(api_url) = update.api_url {
        store.set("apiUrl", json!(api_url.trim()));
    }
    if let Some(locale) = update.locale {
        store.set("locale", json!(locale));
    }
    if let Some(theme) = update.theme {
        store.set("theme", json!(theme));
    }
    if update.clear_api_key.unwrap_or(false) {
        store.delete("apiKey");
    } else if let Some(api_key) = update.api_key {
        if !api_key.trim().is_empty() {
            store.set("apiKey", json!(api_key.trim()));
        }
    }
    if update.mock_mode == Some(false) {
        store.set("mockMode", json!(true));
    }

    store
        .save()
        .map_err(|_| CommandError::new("settings_save_failed", "Settings could not be saved"))?;
    get_settings(app)
}
