import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var coordinator: OnboardingCoordinator
    @EnvironmentObject private var permissions: PermissionManager
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                OnboardingProgressBar(
                    currentStep: coordinator.currentStep.rawValue,
                    totalSteps: OnboardingStep.allCases.count
                )
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.lg)
                
                Group {
                    switch coordinator.currentStep {
                    case .welcome:
                        WelcomeStepView()
                    case .fullDiskAccess:
                        FullDiskAccessStepView()
                    case .automation:
                        AutomationStepView()
                    case .notifications:
                        NotificationsStepView()
                    case .ready:
                        ReadyStepView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(coordinator.currentStep)
            }
        }
        .frame(minWidth: 560, minHeight: 460)
        .task { await permissions.checkAll() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            Task { await permissions.checkAll() }
        }
    }
}

private struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(0..<totalSteps, id: \.self) { idx in
                Capsule()
                    .fill(idx <= currentStep ? AppColors.primary : AppColors.surfaceSecondary)
                    .frame(height: 4)
                    .animation(.easeInOut(duration: AnimationDuration.fast), value: currentStep)
            }
        }
    }
}
