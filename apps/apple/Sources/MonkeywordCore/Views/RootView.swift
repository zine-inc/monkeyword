import SwiftUI

public struct RootView: View {
    @State private var appState = AppState()
    @State private var onboardingViewModel = OnboardingViewModel()
    @State private var selectedSection: AppSection = .dashboard
    @State private var dashboardViewModel: DashboardViewModel
    @State private var keywordResearchViewModel: KeywordResearchViewModel
    @State private var rankTrackingViewModel: RankTrackingViewModel
    @State private var backlinkViewModel: BacklinkViewModel
    @State private var siteAuditViewModel: SiteAuditViewModel
    @State private var competitorViewModel: CompetitorViewModel
    @State private var contentBriefViewModel: ContentBriefViewModel
    @State private var aiCoachViewModel: AICoachViewModel
    @State private var settingsViewModel = SettingsViewModel()

    public init(repository: any MonkeywordRepository = MockRepository()) {
        _dashboardViewModel = State(initialValue: DashboardViewModel(repository: repository))
        _keywordResearchViewModel = State(initialValue: KeywordResearchViewModel(repository: repository))
        _rankTrackingViewModel = State(initialValue: RankTrackingViewModel(repository: repository))
        _backlinkViewModel = State(initialValue: BacklinkViewModel(repository: repository))
        _siteAuditViewModel = State(initialValue: SiteAuditViewModel(repository: repository))
        _competitorViewModel = State(initialValue: CompetitorViewModel(repository: repository))
        _contentBriefViewModel = State(initialValue: ContentBriefViewModel(repository: repository))
        _aiCoachViewModel = State(initialValue: AICoachViewModel(repository: repository))
    }

    public var body: some View {
        VStack(spacing: 0) {
            MockModeBanner(isMockMode: appState.mockMode)
            if appState.hasCompletedOnboarding {
                mainNavigation
            } else {
                OnboardingView(viewModel: onboardingViewModel) {
                    appState.hasCompletedOnboarding = true
                }
            }
        }
        .environment(appState)
        .environment(\.locale, appState.locale.locale)
        .preferredColorScheme(appState.theme.colorScheme)
    }

    @ViewBuilder
    private var mainNavigation: some View {
        #if os(macOS)
        NavigationSplitView {
            List(AppSection.allCases, selection: $selectedSection) { section in
                Label(section.titleKey, systemImage: section.systemImage)
                    .tag(section)
            }
            .navigationTitle("app.title")
            .frame(minWidth: 220)
        } detail: {
            sectionView(selectedSection)
        }
        #else
        TabView(selection: $selectedSection) {
            ForEach(AppSection.allCases) { section in
                NavigationStack {
                    sectionView(section)
                }
                .tabItem {
                    Label(section.titleKey, systemImage: section.systemImage)
                }
                .tag(section)
            }
        }
        #endif
    }

    @ViewBuilder
    private func sectionView(_ section: AppSection) -> some View {
        switch section {
        case .dashboard:
            DashboardView(viewModel: dashboardViewModel, appState: appState)
        case .keywordResearch:
            KeywordResearchView(viewModel: keywordResearchViewModel)
        case .rankTracking:
            RankTrackingView(viewModel: rankTrackingViewModel)
        case .backlinks:
            BacklinkView(viewModel: backlinkViewModel)
        case .siteAudit:
            SiteAuditView(viewModel: siteAuditViewModel)
        case .competitors:
            CompetitorView(viewModel: competitorViewModel)
        case .contentBrief:
            ContentBriefView(viewModel: contentBriefViewModel)
        case .aiCoach:
            AICoachView(viewModel: aiCoachViewModel)
        case .settings:
            SettingsView(viewModel: settingsViewModel, appState: appState)
        }
    }
}
