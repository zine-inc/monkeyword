import Foundation

public struct MockRepository: MonkeywordRepository {
    private let bundle: Bundle

    public init() {
        self.bundle = .module
    }

    init(bundle: Bundle) {
        self.bundle = bundle
    }

    public func fetchProjects() async throws -> [Project] {
        try FixtureLoader.load([Project].self, named: "projects", bundle: bundle)
    }

    public func fetchJobs() async throws -> [Job] {
        try FixtureLoader.load([Job].self, named: "jobs", bundle: bundle)
    }

    public func fetchKeywords() async throws -> [KeywordResult] {
        try FixtureLoader.load([KeywordResult].self, named: "keywords", bundle: bundle)
    }

    public func fetchRanks() async throws -> [RankSnapshot] {
        try FixtureLoader.load([RankSnapshot].self, named: "ranks", bundle: bundle)
    }

    public func fetchBacklinks() async throws -> [BacklinkResult] {
        try FixtureLoader.load([BacklinkResult].self, named: "backlinks", bundle: bundle)
    }

    public func fetchAudits() async throws -> [AuditResult] {
        try FixtureLoader.load([AuditResult].self, named: "audit", bundle: bundle)
    }

    public func fetchCompetitors() async throws -> [CompetitorResult] {
        try FixtureLoader.load([CompetitorResult].self, named: "competitors", bundle: bundle)
    }

    public func fetchBriefs() async throws -> [BriefResult] {
        try FixtureLoader.load([BriefResult].self, named: "briefs", bundle: bundle)
    }

    public func fetchCoachActions() async throws -> [CoachAction] {
        try FixtureLoader.load([CoachAction].self, named: "coach", bundle: bundle)
    }
}
