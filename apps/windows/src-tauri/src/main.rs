mod commands;
mod datasource;
mod settings;

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_store::Builder::default().build())
        .invoke_handler(tauri::generate_handler![
            commands::health_check,
            commands::read_fixture,
            commands::submit_job,
            commands::get_settings,
            commands::save_settings
        ])
        .run(tauri::generate_context!())
        .expect("failed to run monkeyword")
}
