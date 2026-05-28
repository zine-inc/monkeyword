import Charts
import SwiftUI

public struct BacklinkView: View {
    private let viewModel: BacklinkViewModel

    public init(viewModel: BacklinkViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScreenScaffold(
            titleKey: "backlink.title",
            subtitleKey: "backlink.subtitle",
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            retryAction: { await viewModel.load(force: true) }
        ) {
            VStack(alignment: .leading, spacing: 20) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                    MetricCard(titleKey: "backlink.kpi.total", value: "\(viewModel.backlinks.count)", detailKey: "backlink.kpi.total.detail", systemImage: "link")
                    MetricCard(titleKey: "backlink.kpi.follow", value: "\(viewModel.followCount)", detailKey: "backlink.kpi.follow.detail", systemImage: "checkmark.seal")
                    MetricCard(titleKey: "backlink.kpi.dr", value: String(format: "%.1f", viewModel.averageDomainStrength), detailKey: "backlink.kpi.dr.detail", systemImage: "chart.bar.xaxis")
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("backlink.chart.title")
                        .font(.headline)
                    Chart(viewModel.backlinks) { backlink in
                        BarMark(
                            x: .value("backlink.chart.dr", backlink.sourcePagerank),
                            y: .value("backlink.chart.domain", backlink.sourceDomain)
                        )
                        .foregroundStyle(backlink.nofollow ? Color.secondary : Color.green)
                    }
                    .frame(height: 300)
                    .accessibilityLabel(Text("backlink.chart.accessibility"))
                }
                .padding()
                .cardStyle()

                LazyVStack(spacing: 10) {
                    ForEach(viewModel.backlinks) { backlink in
                        BacklinkRow(backlink: backlink)
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

private struct BacklinkRow: View {
    let backlink: BacklinkResult

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: backlink.nofollow ? "link.badge.plus" : "link")
                .foregroundStyle(backlink.nofollow ? Color.secondary : Color.green)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 5) {
                Text(backlink.sourceDomain)
                    .font(.headline)
                Text(backlink.anchor)
                    .font(.callout)
                Text(backlink.targetUrl)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer(minLength: 10)
            VStack(alignment: .trailing, spacing: 6) {
                Text(String(format: "%.1f", backlink.sourcePagerank))
                    .font(.headline.monospacedDigit())
                StatusPill(text: backlink.nofollow ? "backlink.nofollow" : "backlink.follow", color: backlink.nofollow ? .secondary : .green)
            }
        }
        .padding()
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}
