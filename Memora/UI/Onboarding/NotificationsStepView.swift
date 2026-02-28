import SwiftUI

struct NotificationsStepView: View {

    @EnvironmentObject private var coordinator: OnboardingCoordinator
    @EnvironmentObject private var permissions: PermissionManager

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.purple)
            }

            VStack(spacing: Spacing.xs) {
                Text("Alertas de Armazenamento")
                    .font(AppFont.screenTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Text("Receba um aviso quando o disco estiver próximo do limite que você configurar. Opcional — você pode ativar depois nas preferências.")
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
            }

            Spacer()

            VStack(spacing: Spacing.sm) {
                if permissions.notificationStatus == .granted {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        Text("Notificações ativadas").font(AppFont.body).fontWeight(.semibold).foregroundStyle(.green)
                    }
                    PrimaryButton("Continuar", systemImage: "arrow.right") {
                        coordinator.advance()
                    }
                } else {
                    PrimaryButton("Ativar Notificações", systemImage: "bell") {
                        Task { await permissions.requestNotificationPermission() }
                    }
                    SecondaryButton("Agora não") {
                        coordinator.advance()
                    }
                }
            }
            .animation(.easeInOut(duration: AnimationDuration.normal), value: permissions.notificationStatus)
            .padding(.bottom, Spacing.xl)
        }
    }
}