import Foundation

public struct Project: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let targetDomain: String
    public let competitors: [String]
    public let createdAt: Date
}

public struct Job: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let projectId: String
    public let kind: JobKind
    public let status: JobStatus
    public let scheduledAt: Date
    public let completedAt: Date?
}

public enum JobKind: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
    case suggest = "monkeyword/suggest"
    case rank = "monkeyword/rank"
    case backlink = "monkeyword/backlink"
    case competitor = "monkeyword/competitor"
    case audit = "monkeyword/audit"
    case brief = "monkeyword/brief"
    case gap = "monkeyword/gap"
    case topicCluster = "monkeyword/topic_cluster"
    case contentOptimize = "monkeyword/content_optimize"
    case internalLink = "monkeyword/internal_link"
    case aiCoach = "monkeyword/ai_coach"

    public var id: String { rawValue }
}

public enum JobStatus: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
    case done
    case running
    case queued

    public var id: String { rawValue }
}

public struct JobKindRegistry: Codable, Hashable, Sendable {
    public let kinds: [JobKindMetadata]
    public let generatedFrom: String
    public let version: Int
}

public struct JobKindMetadata: Codable, Hashable, Sendable {
    public let value: JobKind
    public let worker: String
    public let usesLlm: Bool
    public let usesScraping: Bool
}

public struct KeywordResult: Codable, Hashable, Identifiable, Sendable {
    public let keyword: String
    public let hl: String
    public let gl: String
    public let searchVolumeEst: Int
    public let intentCluster: IntentCluster
    public let kdEst: Int
    public let llmSummary: String

    public var id: String { "\(keyword)-\(hl)-\(gl)" }
}

public enum IntentCluster: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
    case informational
    case commercial
    case transactional

    public var id: String { rawValue }
}

public struct RankSnapshot: Codable, Hashable, Identifiable, Sendable {
    public let keyword: String
    public let position: Int?
    public let url: String
    public let snippet: String
    public let featuredSnippet: Bool
    public let serpFeatures: [SerpFeature]
    public let date: String
    public let prevPosition: Int?

    public var id: String { "\(keyword)-\(date)" }
}

public enum SerpFeature: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
    case paa
    case imagePack = "image_pack"
    case localPack = "local_pack"
    case video

    public var id: String { rawValue }
}

public struct BacklinkResult: Codable, Hashable, Identifiable, Sendable {
    public let sourceUrl: String
    public let sourceDomain: String
    public let targetUrl: String
    public let anchor: String
    public let sourcePagerank: Double
    public let nofollow: Bool

    public var id: String { sourceUrl }
}

public struct AuditResult: Codable, Hashable, Identifiable, Sendable {
    public let url: String
    public let lighthouseScore: Int
    public let lcp: Double
    public let inp: Int
    public let cls: Double
    public let checks: [AuditCheck]

    public var id: String { url }
}

public struct AuditCheck: Codable, Hashable, Identifiable, Sendable {
    public let name: String
    public let status: AuditStatus
    public let detail: String

    public var id: String { "\(name)-\(status.rawValue)" }
}

public enum AuditStatus: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
    case pass
    case warn
    case fail

    public var id: String { rawValue }
}

public struct CompetitorResult: Codable, Hashable, Identifiable, Sendable {
    public let domain: String
    public let topKeywords: [String]
    public let estimatedTraffic: Int
    public let keywordGap: [String]

    public var id: String { domain }
}

public struct BriefResult: Codable, Hashable, Identifiable, Sendable {
    public let keyword: String
    public let intent: String
    public let outline: [String]
    public let faq: [String]
    public let internalLinks: [String]

    public var id: String { keyword }
}

public struct CoachAction: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let reasonOneLine: String
    public let expectedEffect: String
    public let status: CoachStatus
    public let relatedKeyword: String
    public let priority: Int
}

public enum CoachStatus: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
    case todo
    case done
    case snoozed

    public var id: String { rawValue }
}

public struct DailyRankPoint: Hashable, Identifiable, Sendable {
    public let date: String
    public let averagePosition: Double

    public var id: String { date }
    public var visibilityScore: Double { max(0, 101 - averagePosition) }
}

public struct IntentDistribution: Hashable, Identifiable, Sendable {
    public let intent: IntentCluster
    public let count: Int

    public var id: IntentCluster { intent }
}

public struct KPI: Hashable, Identifiable, Sendable {
    public let id: String
    public let titleKey: String
    public let value: String
    public let detailKey: String
    public let systemImage: String
}
