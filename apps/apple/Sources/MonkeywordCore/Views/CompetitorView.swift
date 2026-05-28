import SwiftUI

public struct CompetitorView: View {
    private let viewModel: CompetitorViewModel

    public init(viewModel: CompetitorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScreenScaffold(
            titleKey: "competitor.title",
            subtitleKey: "competitor.subtitle",
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            retryAction: { await viewModel.load(force: true) }
        ) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 16)], spacing: 16) {
                ForEach(viewModel.competitors) { competitor in
                    CompetitorCard(competitor: competitor)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

private struct CompetitorCard: View {
    let competitor: CompetitorResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(competitor.domain)
                        .font(.headline)
                    Text("competitor.traffic")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(competitor.estimatedTraffic.formatted())
                    .font(.title3.bold())
                    .monospacedDigit()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("competitor.topKeywords")
                    .font(.subheadline.weight(.semibold))
                ForEach(competitor.topKeywords, id: \.self) { keyword in
                    Label(keyword, systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("competitor.gap")
                    .font(.subheadline.weight(.semibold))
                FlowLayout(items: competitor.keywordGap) { keyword in
                    Text(keyword)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(.orange.opacity(0.14), in: Capsule())
                        .foregroundStyle(.orange)
                        .lineLimit(1)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}

private struct FlowLayout<Content: View>: View {
    let items: [String]
    let content: (String) -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }

    private var rows: [[String]] {
        stride(from: 0, to: items.count, by: 2).map {
            Array(items[$0..<min($0 + 2, items.count)])
        }
    }
}
