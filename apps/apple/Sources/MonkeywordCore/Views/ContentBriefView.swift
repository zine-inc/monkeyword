import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct ContentBriefView: View {
    private let viewModel: ContentBriefViewModel
    @State private var copiedSection: String?

    public init(viewModel: ContentBriefViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScreenScaffold(
            titleKey: "brief.title",
            subtitleKey: "brief.subtitle",
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            retryAction: { await viewModel.load(force: true) }
        ) {
            if let brief = viewModel.currentBrief {
                VStack(alignment: .leading, spacing: 20) {
                    header(brief)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 16)], spacing: 16) {
                        OutlineCard(titleKey: "brief.outline", items: brief.outline) {
                            copy(brief.outline.joined(separator: "\n"), section: "outline")
                        }
                        OutlineCard(titleKey: "brief.faq", items: brief.faq) {
                            copy(brief.faq.joined(separator: "\n"), section: "faq")
                        }
                    }
                    copyPanel(brief)
                }
            } else {
                EmptyStateView(titleKey: "brief.empty.title", detailKey: "brief.empty.detail")
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private func header(_ brief: BriefResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(brief.keyword)
                .font(.title2.bold())
            Text(brief.intent)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func copyPanel(_ brief: BriefResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("brief.copy.title")
                    .font(.headline)
                Spacer()
                Button {
                    copy(composedCopy(for: brief), section: "all")
                } label: {
                    Label(copiedSection == "all" ? "brief.copied" : "brief.copy", systemImage: copiedSection == "all" ? "checkmark" : "doc.on.doc")
                }
                .buttonStyle(.bordered)
            }
            Text(composedCopy(for: brief))
                .font(.body.monospaced())
                .textSelection(.enabled)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding()
        .cardStyle()
    }

    private func composedCopy(for brief: BriefResult) -> String {
        let outline = brief.outline.map { "- \($0)" }.joined(separator: "\n")
        let faq = brief.faq.map { "- \($0)" }.joined(separator: "\n")
        let links = brief.internalLinks.map { "- \($0)" }.joined(separator: "\n")
        return """
        Keyword: \(brief.keyword)
        Intent: \(brief.intent)

        Outline:
        \(outline)

        FAQ:
        \(faq)

        Internal links:
        \(links)
        """
    }

    private func copy(_ text: String, section: String) {
        Clipboard.write(text)
        copiedSection = section
    }
}

private struct OutlineCard: View {
    let titleKey: LocalizedStringKey
    let items: [String]
    let copyAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(titleKey)
                    .font(.headline)
                Spacer()
                Button(action: copyAction) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.bordered)
                .accessibilityLabel(Text("brief.copy"))
            }
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.caption.bold())
                        .monospacedDigit()
                        .frame(width: 24, height: 24)
                        .background(.blue.opacity(0.14), in: Circle())
                        .foregroundStyle(.blue)
                    Text(item)
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .cardStyle()
    }
}

private enum Clipboard {
    static func write(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
}
