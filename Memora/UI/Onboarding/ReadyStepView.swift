import SwiftUI

struct ReadyStepView: View {

    @EnvironmentObject private var coordinator: OnboardingCoordinator
    @EnvironmentObject private var permissions: PermissionManager

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(.green)
            }

            VStack(spacing: Spacing.xs) {
                Text("Tudo pronto!")
                    .font(AppFont.screenTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Text("O Memora vai analisar seu disco agora. O primeiro scan pode levar até 30 segundos.")
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)
            }

            // Resumo de permissões
            VStack(spacing: Spacing.xs) {
                PermissionSummaryRow(
                    label: "Acesso Total ao Disco",
                    granted: permissions.fullDiskAccessStatus == .granted
                )
                PermissionSummaryRow(
                    label: "Notificações",
                    granted: permissions.notificationStatus == .granted,
                    optional: true
                )
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()

            PrimaryButton("Iniciar primeiro scan", systemImage: "magnifyingglass") {
                coordinator.complete()
            }
            .padding(.bottom, Spacing.xl)
        }
    }
}

private struct PermissionSummaryRow: View {
    let label: String
    let granted: Bool
    var optional: Bool = false

    var body: some View {
        HStack {
            Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(granted ? .green : (optional ? .orange : .red))
            Text(label)
                .font(AppFont.body)
                .foregroundStyle(AppColors.textPrimary)
            if optional {
                Text("(opcional)")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.md)
    }
}