import Charts
import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

enum AppSection: String, CaseIterable, Identifiable {
    case dashboard
    case keywordResearch
    case rankTracking
    case backlinks
    case siteAudit
    case competitors
    case contentBrief
    case aiCoach
    case settings

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .dashboard:
            "nav.dashboard"
        case .keywordResearch:
            "nav.keywordResearch"
        case .rankTracking:
            "nav.rankTracking"
        case .backlinks:
            "nav.backlinks"
        case .siteAudit:
            "nav.siteAudit"
        case .competitors:
            "nav.competitors"
        case .contentBrief:
            "nav.contentBrief"
        case .aiCoach:
            "nav.aiCoach"
        case .settings:
            "nav.settings"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard:
            "gauge.with.dots.needle.67percent"
        case .keywordResearch:
            "magnifyingglass"
        case .rankTracking:
            "chart.line.uptrend.xyaxis"
        case .backlinks:
            "link"
        case .siteAudit:
            "stethoscope"
        case .competitors:
            "person.3"
        case .contentBrief:
            "doc.text"
        case .aiCoach:
            "sparkles"
        case .settings:
            "gearshape"
        }
    }
}

struct MockModeBanner: View {
    let isMockMode: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .imageScale(.medium)
            Text(isMockMode ? "mock.banner.enabled" : "mock.banner.disabled")
                .font(.callout.weight(.semibold))
            Spacer(minLength: 8)
            Text("mock.banner.detail")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.yellow.opacity(0.18))
        .overlay(alignment: .bottom) {
            Divider()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("mock.banner.accessibility"))
    }
}

struct ScreenScaffold<Content: View>: View {
    let titleKey: LocalizedStringKey
    let subtitleKey: LocalizedStringKey
    let isLoading: Bool
    let errorMessage: String?
    let retryAction: () async -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(titleKey)
                        .font(.largeTitle.bold())
                        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                    Text(subtitleKey)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 240)
                        .accessibilityLabel(Text("state.loading"))
                } else if let errorMessage {
                    RetryStateView(errorMessage: errorMessage, retryAction: retryAction)
                } else {
                    content()
                }
            }
            .padding()
            .frame(maxWidth: 1180, alignment: .topLeading)
        }
        .background(Color.appWindowBackground)
    }
}

struct RetryStateView: View {
    let errorMessage: String
    let retryAction: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("state.offline.title", systemImage: "wifi.slash")
                .font(.headline)
            Text(errorMessage)
                .font(.callout)
                .foregroundStyle(.secondary)
            Button {
                Task { await retryAction() }
            } label: {
                Label("state.retry", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}

struct MetricCard: View {
    let titleKey: String
    let value: String
    let detailKey: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(.tint)
                Spacer()
            }
            Text(value)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(titleKey))
                    .font(.headline)
                Text(LocalizedStringKey(detailKey))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}

struct StatusPill: View {
    let text: LocalizedStringKey
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.14), in: Capsule())
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
}

struct EmptyStateView: View {
    let titleKey: LocalizedStringKey
    let detailKey: LocalizedStringKey

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "tray")
                .font(.title)
                .foregroundStyle(.secondary)
            Text(titleKey)
                .font(.headline)
            Text(detailKey)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.quaternary, lineWidth: 1)
            }
    }
}

extension Color {
    static var passStatus: Color { .green }
    static var warnStatus: Color { .orange }
    static var failStatus: Color { .red }
}

#if os(macOS)
extension Color {
    static var appWindowBackground: Color { Color(nsColor: .windowBackgroundColor) }
    static var appCardBackground: Color { Color(nsColor: .controlBackgroundColor) }
}
#else
extension Color {
    static var appWindowBackground: Color { Color(uiColor: .systemGroupedBackground) }
    static var appCardBackground: Color { Color(uiColor: .secondarySystemGroupedBackground) }
}
#endif

func localizedKey(for status: JobStatus) -> LocalizedStringKey {
    switch status {
    case .done:
        "job.status.done"
    case .running:
        "job.status.running"
    case .queued:
        "job.status.queued"
    }
}

func color(for status: JobStatus) -> Color {
    switch status {
    case .done:
        .passStatus
    case .running:
        .blue
    case .queued:
        .secondary
    }
}

func localizedKey(for status: AuditStatus) -> LocalizedStringKey {
    switch status {
    case .pass:
        "audit.status.pass"
    case .warn:
        "audit.status.warn"
    case .fail:
        "audit.status.fail"
    }
}

func color(for status: AuditStatus) -> Color {
    switch status {
    case .pass:
        .passStatus
    case .warn:
        .warnStatus
    case .fail:
        .failStatus
    }
}

func localizedKey(for status: CoachStatus) -> LocalizedStringKey {
    switch status {
    case .todo:
        "coach.status.todo"
    case .done:
        "coach.status.done"
    case .snoozed:
        "coach.status.snoozed"
    }
}

func color(for status: CoachStatus) -> Color {
    switch status {
    case .todo:
        .blue
    case .done:
        .passStatus
    case .snoozed:
        .secondary
    }
}

func localizedKey(for intent: IntentCluster) -> LocalizedStringKey {
    switch intent {
    case .informational:
        "intent.informational"
    case .commercial:
        "intent.commercial"
    case .transactional:
        "intent.transactional"
    }
}

func localizedName(for kind: JobKind) -> LocalizedStringKey {
    switch kind {
    case .suggest:
        "job.kind.suggest"
    case .rank:
        "job.kind.rank"
    case .backlink:
        "job.kind.backlink"
    case .competitor:
        "job.kind.competitor"
    case .audit:
        "job.kind.audit"
    case .brief:
        "job.kind.brief"
    case .gap:
        "job.kind.gap"
    case .topicCluster:
        "job.kind.topicCluster"
    case .contentOptimize:
        "job.kind.contentOptimize"
    case .internalLink:
        "job.kind.internalLink"
    case .aiCoach:
        "job.kind.aiCoach"
    }
}
