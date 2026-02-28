import SwiftUI

struct FullDiskAccessStepView: View {

    @EnvironmentObject private var coordinator: OnboardingCoordinator
    @EnvironmentObject private var permissions: PermissionManager

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            // Ícone
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(AppColors.primary)
            }

            VStack(spacing: Spacing.xs) {
                Text("Acesso Total ao Disco")
                    .font(AppFont.screenTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Text("O Memora precisa desta permissão para analisar sua pasta Library e identificar caches, logs e builds de desenvolvimento.")
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
            }

            // Instruções
            VStack(alignment: .leading, spacing: Spacing.sm) {
                StepInstruction(number: 1, text: "Clique em \"Abrir Preferências\" abaixo")
                StepInstruction(number: 2, text: "Vá em Privacidade e Segurança → Acesso Total ao Disco")
                StepInstruction(number: 3, text: "Ative a chave ao lado de \"Memora\"")
                StepInstruction(number: 4, text: "Volte aqui — o app detecta automaticamente")
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()

            // Status e botões
            if permissions.fullDiskAccessStatus == .granted {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Permissão concedida!")
                        .font(AppFont.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                }
                .transition(.scale.combined(with: .opacity))

                PrimaryButton("Continuar", systemImage: "arrow.right") {
                    coordinator.advance()
                }
                .padding(.bottom, Spacing.xl)

            } else {
                VStack(spacing: Spacing.xs) {
                    PrimaryButton("Abrir Preferências", systemImage: "gear") {
                        permissions.requestFullDiskAccess()
                    }
                    Text("Nenhuma informação é enviada para fora do seu Mac.")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.bottom, Spacing.xl)
            }
        }
        .animation(.easeInOut(duration: AnimationDuration.normal), value: permissions.fullDiskAccessStatus)
    }
}

private struct StepInstruction: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(AppColors.primary)
                    .frame(width: 22, height: 22)
                Text("\(number)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
            Text(text)
                .font(AppFont.body)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}