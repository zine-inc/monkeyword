import SwiftUI

public struct OnboardingView: View {
    @Bindable private var viewModel: OnboardingViewModel
    let complete: () -> Void

    public init(viewModel: OnboardingViewModel, complete: @escaping () -> Void) {
        self.viewModel = viewModel
        self.complete = complete
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 20)
            VStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
                Text(titleKey)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Text(detailKey)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 620)
            }
            .padding()
            StepProgressView(currentStep: viewModel.step, totalSteps: 3)
            HStack {
                Button {
                    viewModel.back()
                } label: {
                    Label("onboarding.back", systemImage: "chevron.left")
                }
                .disabled(!viewModel.canGoBack)

                Spacer()

                Button {
                    if viewModel.isLastStep {
                        complete()
                    } else {
                        viewModel.next()
                    }
                } label: {
                    Label(viewModel.isLastStep ? "onboarding.start" : "onboarding.next", systemImage: viewModel.isLastStep ? "checkmark" : "chevron.right")
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: 620)
            .padding(.horizontal)
            Spacer(minLength: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appWindowBackground)
    }

    private var titleKey: LocalizedStringKey {
        switch viewModel.step {
        case 0:
            "onboarding.step1.title"
        case 1:
            "onboarding.step2.title"
        default:
            "onboarding.step3.title"
        }
    }

    private var detailKey: LocalizedStringKey {
        switch viewModel.step {
        case 0:
            "onboarding.step1.detail"
        case 1:
            "onboarding.step2.detail"
        default:
            "onboarding.step3.detail"
        }
    }

    private var iconName: String {
        switch viewModel.step {
        case 0:
            "lock.shield"
        case 1:
            "chart.xyaxis.line"
        default:
            "sparkles"
        }
    }
}

private struct StepProgressView: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index == currentStep ? Color.accentColor : Color.secondary.opacity(0.25))
                    .frame(width: index == currentStep ? 34 : 10, height: 8)
            }
        }
        .accessibilityLabel(Text("onboarding.progress"))
    }
}
