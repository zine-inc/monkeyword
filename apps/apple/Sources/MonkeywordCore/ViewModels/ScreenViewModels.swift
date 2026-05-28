import Foundation
import Observation

@MainActor
public protocol LoadableScreen: AnyObject {
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
    var didLoad: Bool { get set }
}

extension LoadableScreen {
    func beginLoading(force: Bool) -> Bool {
        if didLoad && !force { return false }
        isLoading = true
        errorMessage = nil
        return true
    }

    func finishLoading() {
        isLoading = false
        didLoad = true
    }

    func failLoading(_ error: Error) {
        errorMessage = error.localizedDescription
        isLoading = false
    }
}

@Observable
@MainActor
public final class OnboardingViewModel {
    public var step = 0

    public init() {}

    public var canGoBack: Bool { step > 0 }
    public var isLastStep: Bool { step == 2 }

    public func next() {
        step = min(2, step + 1)
    }

    public func back() {
        step = max(0, step - 1)
    }
}

@Observable
@MainActor
public final class DashboardViewModel: LoadableScreen {
    public var isLoading = false
    public var errorMessage: String?
    public var didLoad = false
    public var projects: [Project] = []
    public var jobs: [Job] = []
    public var keywords: [KeywordResult] = []
    public var ranks: [RankSnapshot] = []
    public var audits: [AuditResult] = []
    public var coachActions: [CoachAction] = []

    private let repository: any MonkeywordRepository

    public init(repository: any MonkeywordRepository) {
        self.repository = repository
    }

    public func load(force: Bool = false) async {
        guard beginLoading(force: force) else { return }
        do {
            projects = try await repository.fetchProjects()
            jobs = try await repository.fetchJobs()
            keywords = try await repository.fetchKeywords()
            ranks = try await repository.fetchRanks()
            audits = try await repository.fetchAudits()
            coachActions = try await repository.fetchCoachActions()
            finishLoading()
        } catch {
            failLoading(error)
        }
    }

    public func selectedProject(id: String?) -> Project? {
        guard let id else { return projects.first }
        return projects.first { $0.id == id } ?? projects.first
    }

    public var kpis: [KPI] {
        let latest = latestRanks
        let average = latest.compactMap(\.position).average
        let topTen = latest.filter { ($0.position ?? 101) <= 10 }.count
        let volume = keywords.map(\.searchVolumeEst).reduce(0, +)
        return [
            KPI(id: "keywords", titleKey: "dashboard.kpi.keywords", value: "\(keywords.count)", detailKey: "dashboard.kpi.keywords.detail", systemImage: "magnifyingglass"),
            KPI(id: "rank", titleKey: "dashboard.kpi.rank", value: average == nil ? "-" : String(format: "%.1f", average ?? 0), detailKey: "dashboard.kpi.rank.detail", systemImage: "chart.line.uptrend.xyaxis"),
            KPI(id: "top10", titleKey: "dashboard.kpi.top10", value: "\(topTen)", detailKey: "dashboard.kpi.top10.detail", systemImage: "rosette"),
            KPI(id: "volume", titleKey: "dashboard.kpi.volume", value: volume.formatted(), detailKey: "dashboard.kpi.volume.detail", systemImage: "chart.bar")
        ]
    }

    public var latestRanks: [RankSnapshot] {
        Dictionary(grouping: ranks, by: \.keyword)
            .compactMap { _, values in values.sorted { $0.date > $1.date }.first }
            .sorted { ($0.position ?? 101) < ($1.position ?? 101) }
    }

    public var rankTrend: [DailyRankPoint] {
        Dictionary(grouping: ranks, by: \.date)
            .map { date, values in
                DailyRankPoint(date: date, averagePosition: values.compactMap(\.position).average ?? 0)
            }
            .sorted { $0.date < $1.date }
    }

    public var intentDistribution: [IntentDistribution] {
        Dictionary(grouping: keywords, by: \.intentCluster)
            .map { intent, values in IntentDistribution(intent: intent, count: values.count) }
            .sorted { $0.count > $1.count }
    }

    public var recentJobs: [Job] {
        jobs.sorted { $0.scheduledAt > $1.scheduledAt }.prefix(5).map { $0 }
    }

    public var nextActions: [CoachAction] {
        coachActions.sorted { lhs, rhs in
            if lhs.status != rhs.status { return lhs.status == .todo }
            return lhs.priority > rhs.priority
        }
        .prefix(5)
        .map { $0 }
    }
}

@Observable
@MainActor
public final class KeywordResearchViewModel: LoadableScreen {
    public var isLoading = false
    public var errorMessage: String?
    public var didLoad = false
    public var searchText = ""
    public var keywords: [KeywordResult] = []

    private let repository: any MonkeywordRepository

    public init(repository: any MonkeywordRepository) {
        self.repository = repository
    }

    public func load(force: Bool = false) async {
        guard beginLoading(force: force) else { return }
        do {
            keywords = try await repository.fetchKeywords()
            finishLoading()
        } catch {
            failLoading(error)
        }
    }

    public var filteredKeywords: [KeywordResult] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return keywords.sorted { $0.searchVolumeEst > $1.searchVolumeEst }
        }
        return keywords
            .filter { $0.keyword.localizedCaseInsensitiveContains(query) || $0.llmSummary.localizedCaseInsensitiveContains(query) }
            .sorted { $0.searchVolumeEst > $1.searchVolumeEst }
    }

    public var wheelKeywords: [KeywordResult] {
        Array(filteredKeywords.prefix(10))
    }
}

@Observable
@MainActor
public final class RankTrackingViewModel: LoadableScreen {
    public var isLoading = false
    public var errorMessage: String?
    public var didLoad = false
    public var ranks: [RankSnapshot] = []

    private let repository: any MonkeywordRepository

    public init(repository: any MonkeywordRepository) {
        self.repository = repository
    }

    public func load(force: Bool = false) async {
        guard beginLoading(force: force) else { return }
        do {
            ranks = try await repository.fetchRanks()
            finishLoading()
        } catch {
            failLoading(error)
        }
    }

    public var keywordHistories: [(keyword: String, values: [RankSnapshot])] {
        Dictionary(grouping: ranks, by: \.keyword)
            .map { keyword, values in (keyword, values.sorted { $0.date < $1.date }) }
            .sorted { ($0.values.last?.position ?? 101) < ($1.values.last?.position ?? 101) }
    }
}

@Observable
@MainActor
public final class BacklinkViewModel: LoadableScreen {
    public var isLoading = false
    public var errorMessage: String?
    public var didLoad = false
    public var backlinks: [BacklinkResult] = []

    private let repository: any MonkeywordRepository

    public init(repository: any MonkeywordRepository) {
        self.repository = repository
    }

    public func load(force: Bool = false) async {
        guard beginLoading(force: force) else { return }
        do {
            backlinks = try await repository.fetchBacklinks()
            finishLoading()
        } catch {
            failLoading(error)
        }
    }

    public var averageDomainStrength: Double {
        backlinks.map(\.sourcePagerank).average ?? 0
    }

    public var followCount: Int {
        backlinks.filter { !$0.nofollow }.count
    }
}

@Observable
@MainActor
public final class SiteAuditViewModel: LoadableScreen {
    public var isLoading = false
    public var errorMessage: String?
    public var didLoad = false
    public var audits: [AuditResult] = []

    private let repository: any MonkeywordRepository

    public init(repository: any MonkeywordRepository) {
        self.repository = repository
    }

    public func load(force: Bool = false) async {
        guard beginLoading(force: force) else { return }
        do {
            audits = try await repository.fetchAudits()
            finishLoading()
        } catch {
            failLoading(error)
        }
    }

    public var primaryAudit: AuditResult? { audits.first }
}

@Observable
@MainActor
public final class CompetitorViewModel: LoadableScreen {
    public var isLoading = false
    public var errorMessage: String?
    public var didLoad = false
    public var competitors: [CompetitorResult] = []

    private let repository: any MonkeywordRepository

    public init(repository: any MonkeywordRepository) {
        self.repository = repository
    }

    public func load(force: Bool = false) async {
        guard beginLoading(force: force) else { return }
        do {
            competitors = try await repository.fetchCompetitors()
            finishLoading()
        } catch {
            failLoading(error)
        }
    }
}

@Observable
@MainActor
public final class ContentBriefViewModel: LoadableScreen {
    public var isLoading = false
    public var errorMessage: String?
    public var didLoad = false
    public var briefs: [BriefResult] = []

    private let repository: any MonkeywordRepository

    public init(repository: any MonkeywordRepository) {
        self.repository = repository
    }

    public func load(force: Bool = false) async {
        guard beginLoading(force: force) else { return }
        do {
            briefs = try await repository.fetchBriefs()
            finishLoading()
        } catch {
            failLoading(error)
        }
    }

    public var currentBrief: BriefResult? { briefs.first }
}

@Observable
@MainActor
public final class AICoachViewModel: LoadableScreen {
    public var isLoading = false
    public var errorMessage: String?
    public var didLoad = false
    public var actions: [CoachAction] = []

    private let repository: any MonkeywordRepository

    public init(repository: any MonkeywordRepository) {
        self.repository = repository
    }

    public func load(force: Bool = false) async {
        guard beginLoading(force: force) else { return }
        do {
            actions = try await repository.fetchCoachActions()
            finishLoading()
        } catch {
            failLoading(error)
        }
    }

    public var prioritizedActions: [CoachAction] {
        actions.sorted { lhs, rhs in
            if lhs.status != rhs.status { return lhs.status == .todo }
            return lhs.priority > rhs.priority
        }
    }
}

@Observable
@MainActor
public final class SettingsViewModel {
    public var connectionMessageKey = "settings.connection.mockOnly"

    public init() {}

    public func validateMockConnection() {
        connectionMessageKey = "settings.connection.mockOnly"
    }
}

extension Array where Element == Int {
    var average: Double? {
        guard !isEmpty else { return nil }
        return Double(reduce(0, +)) / Double(count)
    }
}

extension Array where Element == Double {
    var average: Double? {
        guard !isEmpty else { return nil }
        return reduce(0, +) / Double(count)
    }
}
