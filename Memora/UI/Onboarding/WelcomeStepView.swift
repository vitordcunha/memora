import SwiftUI

struct WelcomeStepView: View {
    
    @EnvironmentObject private var coordinator: OnboardingCoordinator

    private let features: [(icon: String, color: Color, title: String, description: String)] = [
        ("magnifyingglass", AppColors.primary,
         "Varredura Rápida", "Menos de 30 segundos para analisar até 1 TB de armazenamento."),
        ("square.stack.3d.up", .purple,
         "Classificação Inteligente", "10 categorias de conteúdo com score de impacto e segurança."),
        ("bubble.left.and.text.bubble.right", .teal,
         "Contexto Claro", "Saiba exatamente o que cada arquivo é e por que pode ser removido."),
        ("shield.checkered", .green,
         "Seguro por Padrão", "Nada é deletado permanentemente — tudo vai para a Lixeira do Mac."),
    ]
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            // Ícone / logo
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "internaldrive.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(AppColors.primary)
            }

            VStack(spacing: Spacing.xs) {
                Text("Bem-vindo ao Memora")
                    .font(AppFont.screenTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Text("Inteligência de armazenamento para o seu Mac.")
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.textSecondary)
            }

            // Lista de features
            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(features, id: \.title) { feature in
                    FeatureRow(
                        icon: feature.icon,
                        color: feature.color,
                        title: feature.title,
                        description: feature.description
                    )
                }
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()

            PrimaryButton("Começar", systemImage: "arrow.right") {
                coordinator.advance()
            }
            .padding(.bottom, Spacing.xl)
        }
        .multilineTextAlignment(.center)
    }
}

private struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textPrimary)
                Text(description)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}