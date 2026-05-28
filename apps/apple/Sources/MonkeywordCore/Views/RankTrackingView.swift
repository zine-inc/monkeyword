import Charts
import SwiftUI

public struct RankTrackingView: View {
    private let viewModel: RankTrackingViewModel

    public init(viewModel: RankTrackingViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScreenScaffold(
            titleKey: "rank.title",
            subtitleKey: "rank.subtitle",
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            retryAction: { await viewModel.load(force: true) }
        ) {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(viewModel.keywordHistories, id: \.keyword) { history in
                    RankHistoryRow(keyword: history.keyword, values: history.values)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

private struct RankHistoryRow: View {
    let keyword: String
    let values: [RankSnapshot]

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(keyword)
                    .font(.headline)
                HStack(spacing: 8) {
                    StatusPill(text: trendText, color: trendColor)
                    if latest?.featuredSnippet == true {
                        StatusPill(text: "rank.featuredSnippet", color: .purple)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 2) {
                Text(positionText)
                    .font(.title2.bold())
                    .monospacedDigit()
                Text("rank.current")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 92, alignment: .trailing)

            Chart(values) { snapshot in
                if let position = snapshot.position {
                    LineMark(
                        x: .value("rank.chart.date", snapshot.date),
                        y: .value("rank.chart.position", 101 - position)
                    )
                    .interpolationMethod(.catmullRom)
                    AreaMark(
                        x: .value("rank.chart.date", snapshot.date),
                        y: .value("rank.chart.position", 101 - position)
                    )
                    .opacity(0.12)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(width: 180, height: 64)
            .accessibilityLabel(Text("rank.sparkline.accessibility"))
        }
        .padding()
        .cardStyle()
        .accessibilityElement(children: .combine)
    }

    private var latest: RankSnapshot? {
        values.sorted { $0.date > $1.date }.first
    }

    private var positionText: String {
        guard let position = latest?.position else { return "-" }
        return "#\(position)"
    }

    private var trendText: LocalizedStringKey {
        guard let latest, let position = latest.position, let previous = latest.prevPosition else {
            return "rank.trend.new"
        }
        if position < previous { return "rank.trend.up" }
        if position > previous { return "rank.trend.down" }
        return "rank.trend.flat"
    }

    private var trendColor: Color {
        guard let latest, let position = latest.position, let previous = latest.prevPosition else {
            return .secondary
        }
        if position < previous { return .green }
        if position > previous { return .red }
        return .secondary
    }
}
