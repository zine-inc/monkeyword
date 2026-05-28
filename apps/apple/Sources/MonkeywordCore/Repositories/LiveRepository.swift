import Foundation

public struct LiveRepository: MonkeywordRepository {
    public let baseURL: URL?
    private let session: URLSession

    public init(baseURL: URL? = nil, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public func fetchProjects() async throws -> [Project] {
        _ = session
        throw RepositoryError.liveRepositoryUnavailable
    }

    public func fetchJobs() async throws -> [Job] {
        _ = session
        throw RepositoryError.liveRepositoryUnavailable
    }

    public func fetchKeywords() async throws -> [KeywordResult] {
        _ = session
        throw RepositoryError.liveRepositoryUnavailable
    }

    public func fetchRanks() async throws -> [RankSnapshot] {
        _ = session
        throw RepositoryError.liveRepositoryUnavailable
    }

    public func fetchBacklinks() async throws -> [BacklinkResult] {
        _ = session
        throw RepositoryError.liveRepositoryUnavailable
    }

    public func fetchAudits() async throws -> [AuditResult] {
        _ = session
        throw RepositoryError.liveRepositoryUnavailable
    }

    public func fetchCompetitors() async throws -> [CompetitorResult] {
        _ = session
        throw RepositoryError.liveRepositoryUnavailable
    }

    public func fetchBriefs() async throws -> [BriefResult] {
        _ = session
        throw RepositoryError.liveRepositoryUnavailable
    }

    public func fetchCoachActions() async throws -> [CoachAction] {
        _ = session
        throw RepositoryError.liveRepositoryUnavailable
    }
}
