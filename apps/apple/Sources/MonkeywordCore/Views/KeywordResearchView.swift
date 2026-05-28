import Charts
import SwiftUI

public struct KeywordResearchView: View {
    @Bindable private var viewModel: KeywordResearchViewModel

    public init(viewModel: KeywordResearchViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScreenScaffold(
            titleKey: "keyword.title",
            subtitleKey: "keyword.subtitle",
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            retryAction: { await viewModel.load(force: true) }
        ) {
            VStack(alignment: .leading, spacing: 20) {
                searchBar
                if viewModel.filteredKeywords.isEmpty {
                    EmptyStateView(titleKey: "keyword.empty.title", detailKey: "keyword.empty.detail")
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 360), spacing: 16)], spacing: 16) {
                        keywordWheel
                        keywordTable
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("keyword.search.placeholder", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .accessibilityLabel(Text("keyword.search.label"))
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("keyword.search.clear"))
            }
        }
        .padding()
        .cardStyle()
    }

    private var keywordWheel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("keyword.wheel.title")
                .font(.headline)
            AnswerWheelView(keywords: viewModel.wheelKeywords)
                .frame(minHeight: 360)
        }
        .padding()
        .cardStyle()
    }

    private var keywordTable: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("keyword.table.title")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.filteredKeywords.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            LazyVStack(spacing: 0) {
                KeywordRowHeader()
                ForEach(viewModel.filteredKeywords) { keyword in
                    KeywordResultRow(keyword: keyword)
                    Divider()
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct AnswerWheelView: View {
    let keywords: [KeywordResult]

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let radius = max(96, side * 0.36)
            ZStack {
                Circle()
                    .stroke(.secondary.opacity(0.18), lineWidth: 1)
                    .frame(width: radius * 1.65, height: radius * 1.65)
                    .position(center)
                VStack(spacing: 4) {
                    Text("keyword.wheel.center")
                        .font(.headline)
                    Text("\(keywords.count)")
                        .font(.title2.bold())
                        .monospacedDigit()
                }
                .padding()
                .frame(width: 132, height: 132)
                .background(.thinMaterial, in: Circle())
                .position(center)

                ForEach(Array(keywords.enumerated()), id: \.element.id) { index, keyword in
                    let angle = (Double(index) / Double(max(keywords.count, 1))) * 2 * Double.pi - Double.pi / 2
                    let x = center.x + CGFloat(cos(angle)) * radius
                    let y = center.y + CGFloat(sin(angle)) * radius
                    Text(keyword.keyword)
                        .font(.caption.weight(.semibold))
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 7)
                        .frame(width: 128)
                        .background(Color.accentColor.opacity(0.12), in: Capsule())
                        .overlay {
                            Capsule().stroke(Color.accentColor.opacity(0.22), lineWidth: 1)
                        }
                        .position(x: x, y: y)
                        .accessibilityLabel(Text(keyword.keyword))
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("keyword.wheel.accessibility"))
    }
}

private struct KeywordRowHeader: View {
    var body: some View {
        HStack {
            Text("keyword.column.keyword")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("keyword.column.volume")
                .frame(width: 88, alignment: .trailing)
            Text("keyword.column.difficulty")
                .frame(width: 88, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.vertical, 8)
    }
}

private struct KeywordResultRow: View {
    let keyword: KeywordResult

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(keyword.keyword)
                        .font(.subheadline.weight(.semibold))
                    HStack(spacing: 8) {
                        StatusPill(text: localizedKey(for: keyword.intentCluster), color: intentColor)
                        Text("\(keyword.hl.uppercased()) / \(keyword.gl)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Text(keyword.searchVolumeEst.formatted())
                    .font(.subheadline.monospacedDigit())
                    .frame(width: 88, alignment: .trailing)
                Text("\(keyword.kdEst)")
                    .font(.subheadline.monospacedDigit())
                    .frame(width: 88, alignment: .trailing)
            }
            Text(keyword.llmSummary)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
    }

    private var intentColor: Color {
        switch keyword.intentCluster {
        case .informational:
            .blue
        case .commercial:
            .purple
        case .transactional:
            .green
        }
    }
}
