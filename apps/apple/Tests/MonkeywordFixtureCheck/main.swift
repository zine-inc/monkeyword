import Foundation
import MonkeywordCore

do {
    try MonkeywordFixtureCheck.run()
    if let stampPath = CommandLine.arguments.dropFirst().first {
        try "ok\n".write(toFile: stampPath, atomically: true, encoding: .utf8)
    }
    print("MonkeywordFixtureCheck: fixture decode, repository, and JobKind contract checks passed.")
} catch {
    fputs("MonkeywordFixtureCheck failed: \(error)\n", stderr)
    exit(1)
}

private enum MonkeywordFixtureCheck {
    static func run() throws {
        try assertRoundTrip([Project].self, named: "projects")
        try assertRoundTrip([Job].self, named: "jobs")
        try assertRoundTrip([KeywordResult].self, named: "keywords")
        try assertRoundTrip([RankSnapshot].self, named: "ranks")
        try assertRoundTrip([BacklinkResult].self, named: "backlinks")
        try assertRoundTrip([AuditResult].self, named: "audit")
        try assertRoundTrip([CompetitorResult].self, named: "competitors")
        try assertRoundTrip([BriefResult].self, named: "briefs")
        try assertRoundTrip([CoachAction].self, named: "coach")
        try assertJobKinds()
        try assertMockRepositoryNonEmpty()
    }

    private static func assertRoundTrip<T: Codable & Equatable>(_ type: T.Type, named name: String) throws {
        let decoded = try FixtureLoader.load(T.self, named: name)
        let encoded = try FixtureLoader.encoder.encode(decoded)
        let roundTripped = try FixtureLoader.decoder.decode(T.self, from: encoded)
        try require(roundTripped == decoded, "\(name).json failed Codable round-trip")
    }

    private static func assertJobKinds() throws {
        let expected = [
            "monkeyword/suggest",
            "monkeyword/rank",
            "monkeyword/backlink",
            "monkeyword/competitor",
            "monkeyword/audit",
            "monkeyword/brief",
            "monkeyword/gap",
            "monkeyword/topic_cluster",
            "monkeyword/content_optimize",
            "monkeyword/internal_link",
            "monkeyword/ai_coach"
        ]

        try require(JobKind.allCases.map(\.rawValue) == expected, "JobKind raw values do not match schema contract")

        let registry = try FixtureLoader.load(JobKindRegistry.self, named: "job_kinds", subdirectory: "Fixtures/schema")
        try require(registry.kinds.map(\.value.rawValue) == expected, "job_kinds.json values do not match JobKind")
        try require(registry.kinds.count == 11, "job_kinds.json must contain exactly 11 kinds")
    }

    private static func assertMockRepositoryNonEmpty() throws {
        let repository = MockRepository()
        let result = try BlockingTask.run {
            [
                (try await repository.fetchProjects()).isEmpty,
                (try await repository.fetchJobs()).isEmpty,
                (try await repository.fetchKeywords()).isEmpty,
                (try await repository.fetchRanks()).isEmpty,
                (try await repository.fetchBacklinks()).isEmpty,
                (try await repository.fetchAudits()).isEmpty,
                (try await repository.fetchCompetitors()).isEmpty,
                (try await repository.fetchBriefs()).isEmpty,
                (try await repository.fetchCoachActions()).isEmpty
            ]
        }
        try require(!result.contains(true), "MockRepository returned an empty fixture collection")
    }

    private static func require(_ condition: Bool, _ message: String) throws {
        if !condition {
            throw CheckFailure(message)
        }
    }
}

private enum BlockingTask {
    static func run<T>(_ operation: @escaping () async throws -> T) throws -> T {
        let semaphore = DispatchSemaphore(value: 0)
        let box = ResultBox<T>()

        Task {
            do {
                box.result = .success(try await operation())
            } catch {
                box.result = .failure(error)
            }
            semaphore.signal()
        }

        semaphore.wait()
        return try box.result!.get()
    }
}

private final class ResultBox<T> {
    var result: Result<T, Error>?
}

private struct CheckFailure: Error, CustomStringConvertible {
    let description: String

    init(_ description: String) {
        self.description = description
    }
}
