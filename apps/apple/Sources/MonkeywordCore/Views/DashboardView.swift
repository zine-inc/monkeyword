import Charts
import SwiftUI

public struct DashboardView: View {
    private let viewModel: DashboardViewModel
    private let appState: AppState

    public init(viewModel: DashboardViewModel, appState: AppState) {
        self.viewModel = viewModel
        self.appState = appState
    }

    public var body: some View {
        ScreenScaffold(
            titleKey: "dashboard.title",
            subtitleKey: "dashboard.subtitle",
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            retryAction: { await viewModel.load(force: true) }
        ) {
            VStack(alignment: .leading, spacing: 20) {
                projectHeader
                kpiGrid
                chartGrid
                recentWorkGrid
            }
        }
        .task {
            await viewModel.load()
            appState.selectDefaultProject(from: viewModel.projects)
        }
    }

    private var projectHeader: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.selectedProject(id: appState.selectedProjectId)?.name ?? "monkeyword")
                    .font(.title3.bold())
                Text(viewModel.selectedProject(id: appState.selectedProjectId)?.targetDomain ?? "example.invalid")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 12)
            Picker("project.selector", selection: Binding(
                get: { appState.selectedProjectId ?? viewModel.projects.first?.id },
                set: { appState.selectedProjectId = $0 }
            )) {
                ForEach(viewModel.projects) { project in
                    Text(project.name).tag(Optional(project.id))
                }
            }
            .labelsHidden()
            .frame(maxWidth: 280)
            .accessibilityLabel(Text("project.selector"))
        }
        .padding()
        .cardStyle()
    }

    private var kpiGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
            ForEach(viewModel.kpis) { kpi in
                MetricCard(titleKey: kpi.titleKey, value: kpi.value, detailKey: kpi.detailKey, systemImage: kpi.systemImage)
            }
        }
    }

    private var chartGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 16)], spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("dashboard.rankTrend")
                    .font(.headline)
                Chart(viewModel.rankTrend) { point in
                    LineMark(
                        x: .value("dashboard.chart.date", point.date),
                        y: .value("dashboard.chart.visibility", point.visibilityScore)
                    )
                    .interpolationMethod(.catmullRom)
                    PointMark(
                        x: .value("dashboard.chart.date", point.date),
                        y: .value("dashboard.chart.visibility", point.visibilityScore)
                    )
                }
                .frame(height: 240)
                .chartYAxisLabel("dashboard.chart.visibility")
                .accessibilityLabel(Text("dashboard.rankTrend.accessibility"))
            }
            .padding()
            .cardStyle()

            VStack(alignment: .leading, spacing: 12) {
                Text("dashboard.intentDistribution")
                    .font(.headline)
                Chart(viewModel.intentDistribution) { item in
                    BarMark(
                        x: .value("dashboard.chart.intentCount", item.count),
                        y: .value("dashboard.chart.intent", String(describing: item.intent.rawValue))
                    )
                    .foregroundStyle(by: .value("dashboard.chart.intent", item.intent.rawValue))
                }
                .frame(height: 240)
                .chartLegend(.hidden)
                .accessibilityLabel(Text("dashboard.intentDistribution.accessibility"))
                intentLegend
            }
            .padding()
            .cardStyle()
        }
    }

    private var intentLegend: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.intentDistribution) { item in
                StatusPill(text: localizedKey(for: item.intent), color: color(for: item.intent))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var recentWorkGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 16)], spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("dashboard.recentJobs")
                    .font(.headline)
                ForEach(viewModel.recentJobs) { job in
                    HStack(spacing: 10) {
                        Image(systemName: job.kind == .rank ? "chart.line.uptrend.xyaxis" : "checklist")
                            .foregroundStyle(.tint)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(localizedName(for: job.kind))
                                .font(.subheadline.weight(.semibold))
                            Text(job.scheduledAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        StatusPill(text: localizedKey(for: job.status), color: color(for: job.status))
                    }
                    .padding(.vertical, 6)
                }
            }
            .padding()
            .cardStyle()

            VStack(alignment: .leading, spacing: 12) {
                Text("dashboard.nextActions")
                    .font(.headline)
                ForEach(viewModel.nextActions) { action in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(action.priority)")
                            .font(.caption.weight(.bold))
                            .frame(width: 26, height: 26)
                            .background(.blue.opacity(0.14), in: Circle())
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(action.title)
                                .font(.subheadline.weight(.semibold))
                            Text(action.expectedEffect)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .cardStyle()
        }
    }
}

private func color(for intent: IntentCluster) -> Color {
    switch intent {
    case .informational:
        .blue
    case .commercial:
        .purple
    case .transactional:
        .green
    }
}
