import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
public final class AppState {
    public var selectedProjectId: String?
    public var mockMode = true
    public var locale: AppLocale = .ja
    public var theme: AppTheme = .system
    public var hasCompletedOnboarding = false
    public var apiURL = ""
    public var apiKey = ""

    public init() {}

    public func selectDefaultProject(from projects: [Project]) {
        guard selectedProjectId == nil else { return }
        selectedProjectId = projects.first?.id
    }
}

public enum AppLocale: String, CaseIterable, Identifiable {
    case ja
    case en

    public var id: String { rawValue }

    public var locale: Locale {
        Locale(identifier: rawValue)
    }

    public var titleKey: LocalizedStringKey {
        switch self {
        case .ja:
            "settings.language.ja"
        case .en:
            "settings.language.en"
        }
    }
}

public enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    public var id: String { rawValue }

    public var titleKey: LocalizedStringKey {
        switch self {
        case .system:
            "settings.theme.system"
        case .light:
            "settings.theme.light"
        case .dark:
            "settings.theme.dark"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}
