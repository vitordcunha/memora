import SwiftUI

struct AutomationStepView: View {

    @EnvironmentObject private var coordinator: OnboardingCoordinator

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "trash.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.orange)
            }

            VStack(spacing: Spacing.xs) {
                Text("Mover para a Lixeira")
                    .font(AppFont.screenTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Text("O Memora **nunca deleta arquivos permanentemente**. Tudo é movido para a Lixeira do seu Mac — você pode recuperar qualquer item antes de esvaziá-la.")
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
            }

            // Garantias de segurança
            VStack(alignment: .leading, spacing: Spacing.sm) {
                GuaranteeRow(icon: "checkmark.shield.fill", color: .green,
                             text: "Sempre via Lixeira — nunca remoção direta")
                GuaranteeRow(icon: "hand.raised.fill", color: .blue,
                             text: "Confirmação obrigatória antes de qualquer remoção")
                GuaranteeRow(icon: "clock.arrow.circlepath", color: .purple,
                             text: "Histórico completo de todas as operações realizadas")
                GuaranteeRow(icon: "lock.fill", color: .orange,
                             text: "Arquivos do sistema nunca são tocados")
            }
            .padding(.horizontal, Spacing.xl)

            Text("Na primeira limpeza, o macOS pedirá permissão para controlar o Finder. Basta clicar em \"Permitir\".")
                .font(AppFont.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            Spacer()

            PrimaryButton("Entendi, continuar", systemImage: "arrow.right") {
                coordinator.advance()
            }
            .padding(.bottom, Spacing.xl)
        }
    }
}

private struct GuaranteeRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 24)
            Text(text)
                .font(AppFont.body)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}