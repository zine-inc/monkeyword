import SwiftUI

public struct SiteAuditView: View {
    private let viewModel: SiteAuditViewModel

    public init(viewModel: SiteAuditViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScreenScaffold(
            titleKey: "audit.title",
            subtitleKey: "audit.subtitle",
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            retryAction: { await viewModel.load(force: true) }
        ) {
            if let audit = viewModel.primaryAudit {
                VStack(alignment: .leading, spacing: 20) {
                    scorePanel(audit)
                    vitalsGrid(audit)
                    checksList(audit.checks)
                }
            } else {
                EmptyStateView(titleKey: "audit.empty.title", detailKey: "audit.empty.detail")
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private func scorePanel(_ audit: AuditResult) -> some View {
        HStack(alignment: .center, spacing: 20) {
            Gauge(value: Double(audit.lighthouseScore), in: 0...100) {
                Text("audit.score")
            } currentValueLabel: {
                Text("\(audit.lighthouseScore)")
                    .font(.title.bold())
                    .monospacedDigit()
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(scoreColor(audit.lighthouseScore))
            .frame(width: 120, height: 120)
            .accessibilityLabel(Text("audit.score.accessibility"))

            VStack(alignment: .leading, spacing: 6) {
                Text(audit.url)
                    .font(.title3.bold())
                Text("audit.score.detail")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .cardStyle()
    }

    private func vitalsGrid(_ audit: AuditResult) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 190), spacing: 12)], spacing: 12) {
            VitalCard(titleKey: "audit.vital.lcp", value: String(format: "%.1fs", audit.lcp), detailKey: "audit.vital.lcp.detail", color: audit.lcp <= 2.5 ? .green : .orange)
            VitalCard(titleKey: "audit.vital.inp", value: "\(audit.inp)ms", detailKey: "audit.vital.inp.detail", color: audit.inp <= 200 ? .green : .orange)
            VitalCard(titleKey: "audit.vital.cls", value: String(format: "%.2f", audit.cls), detailKey: "audit.vital.cls.detail", color: audit.cls <= 0.1 ? .green : .orange)
        }
    }

    private func checksList(_ checks: [AuditCheck]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("audit.checks.title")
                .font(.headline)
            ForEach(checks) { check in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: icon(for: check.status))
                        .foregroundStyle(color(for: check.status))
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(check.name)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            StatusPill(text: localizedKey(for: check.status), color: color(for: check.status))
                        }
                        Text(check.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
                Divider()
            }
        }
        .padding()
        .cardStyle()
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 90 { return .green }
        if score >= 70 { return .orange }
        return .red
    }

    private func icon(for status: AuditStatus) -> String {
        switch status {
        case .pass:
            "checkmark.circle.fill"
        case .warn:
            "exclamationmark.triangle.fill"
        case .fail:
            "xmark.octagon.fill"
        }
    }
}

private struct VitalCard: View {
    let titleKey: String
    let value: String
    let detailKey: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedStringKey(titleKey))
                .font(.headline)
            Text(value)
                .font(.title2.bold())
                .monospacedDigit()
                .foregroundStyle(color)
            Text(LocalizedStringKey(detailKey))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}
