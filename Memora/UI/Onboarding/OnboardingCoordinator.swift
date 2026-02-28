import SwiftUI

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case fullDiskAccess = 1
    case automation = 2
    case notifications = 3
    case ready = 4
}

@MainActor
final class OnboardingCoordinator: ObservableObject {

    static let shared = OnboardingCoordinator()

    @Published var currentStep: OnboardingStep = .welcome
    @Published var isCompleted: Bool

    private let completedKey = "onboarding_completed_v1"

    init() {
        #if DEBUG
        self.isCompleted = true
        #else
        self.isCompleted = UserDefaults.standard.bool(forKey: completedKey)
        #endif
    }

    func advance() {
        let all = OnboardingStep.allCases

        guard let idx = all.firstIndex(of: currentStep), idx + 1 < all.count else {
            complete()
            return
        }
        withAnimation(.easeInOut(duration: AnimationDuration.normal)) {
            currentStep = all[idx + 1]
        }
    }

    func complete() {
        UserDefaults.standard.set(true, forKey: completedKey)
        withAnimation(.easeInOut(duration: AnimationDuration.slow)) {
            isCompleted = true
        }
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: completedKey)
        currentStep = .welcome
        isCompleted = false
    }
}