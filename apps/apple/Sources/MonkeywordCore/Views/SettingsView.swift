import SwiftUI

public struct SettingsView: View {
    private let viewModel: SettingsViewModel
    private let appState: AppState

    public init(viewModel: SettingsViewModel, appState: AppState) {
        self.viewModel = viewModel
        self.appState = appState
    }

    public var body: some View {
        ScreenScaffold(
            titleKey: "settings.title",
            subtitleKey: "settings.subtitle",
            isLoading: false,
            errorMessage: nil,
            retryAction: {}
        ) {
            VStack(alignment: .leading, spacing: 20) {
                connectionSection
                preferencesSection
                privacySection
            }
        }
    }

    private var connectionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("settings.connection")
                .font(.headline)
            TextField("settings.apiURL.placeholder", text: Binding(
                get: { appState.apiURL },
                set: { appState.apiURL = $0 }
            ))
            .textFieldStyle(.roundedBorder)
            .disabled(true)
            .accessibilityLabel(Text("settings.apiURL"))

            SecureField("settings.apiKey.placeholder", text: Binding(
                get: { appState.apiKey },
                set: { appState.apiKey = $0 }
            ))
            .textFieldStyle(.roundedBorder)
            .disabled(true)
            .accessibilityLabel(Text("settings.apiKey"))

            HStack {
                Toggle("settings.mockMode", isOn: Binding(
                    get: { appState.mockMode },
                    set: { appState.mockMode = $0 }
                ))
                .disabled(true)
                Spacer()
                Button {
                    viewModel.validateMockConnection()
                } label: {
                    Label("settings.check", systemImage: "checkmark.circle")
                }
                .buttonStyle(.bordered)
            }

            Label(LocalizedStringKey(viewModel.connectionMessageKey), systemImage: "shippingbox")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding()
        .cardStyle()
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("settings.preferences")
                .font(.headline)
            Picker("settings.language", selection: Binding(
                get: { appState.locale },
                set: { appState.locale = $0 }
            )) {
                ForEach(AppLocale.allCases) { locale in
                    Text(locale.titleKey).tag(locale)
                }
            }
            .pickerStyle(.segmented)

            Picker("settings.theme", selection: Binding(
                get: { appState.theme },
                set: { appState.theme = $0 }
            )) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.titleKey).tag(theme)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .cardStyle()
    }

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("settings.privacy")
                .font(.headline)
            Label("settings.privacy.offline", systemImage: "wifi.slash")
            Label("settings.privacy.local", systemImage: "desktopcomputer")
            Label("settings.privacy.fixtures", systemImage: "doc.text")
        }
        .font(.callout)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
