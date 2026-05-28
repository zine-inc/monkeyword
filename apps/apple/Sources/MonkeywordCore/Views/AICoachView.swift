import SwiftUI

public struct AICoachView: View {
    private let viewModel: AICoachViewModel

    public init(viewModel: AICoachViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScreenScaffold(
            titleKey: "coach.title",
            subtitleKey: "coach.subtitle",
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            retryAction: { await viewModel.load(force: true) }
        ) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 16)], spacing: 16) {
                ForEach(Array(viewModel.prioritizedActions.prefix(5))) { action in
                    CoachActionCard(action: action)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

private struct CoachActionCard: View {
    let action: CoachAction

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text("\(action.priority)")
                    .font(.headline.bold())
                    .monospacedDigit()
                    .frame(width: 38, height: 38)
                    .background(priorityColor.opacity(0.15), in: Circle())
                    .foregroundStyle(priorityColor)
                Spacer()
                StatusPill(text: localizedKey(for: action.status), color: color(for: action.status))
            }
            Text(action.title)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
            Text(action.reasonOneLine)
                .font(.callout)
                .foregroundStyle(.secondary)
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                Label(action.expectedEffect, systemImage: "chart.line.uptrend.xyaxis")
                Label(action.relatedKeyword, systemImage: "tag")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 230, alignment: .topLeading)
        .cardStyle()
        .accessibilityElement(children: .combine)
    }

    private var priorityColor: Color {
        action.priority >= 4 ? .blue : .secondary
    }
}
