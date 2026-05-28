import Foundation

public protocol MonkeywordRepository {
    func fetchProjects() async throws -> [Project]
    func fetchJobs() async throws -> [Job]
    func fetchKeywords() async throws -> [KeywordResult]
    func fetchRanks() async throws -> [RankSnapshot]
    func fetchBacklinks() async throws -> [BacklinkResult]
    func fetchAudits() async throws -> [AuditResult]
    func fetchCompetitors() async throws -> [CompetitorResult]
    func fetchBriefs() async throws -> [BriefResult]
    func fetchCoachActions() async throws -> [CoachAction]
}

public enum RepositoryError: Error, LocalizedError, Equatable {
    case liveRepositoryUnavailable

    public var errorDescription: String? {
        switch self {
        case .liveRepositoryUnavailable:
            "Live data is not available in Phase 1. Mock fixtures are bundled for offline use."
        }
    }
}
