import SwiftUI

/// Overlay de carregamento exibido durante o scan ou operações longas.
///
/// Uso:
/// ```swift
/// ContentView()
///     .overlay { if isScanning { LoadingOverlay(message: "Varrendo disco...") } }
/// ```
struct LoadingOverlay: View {
    let message: String
    var progress: Double? = nil  // nil = indeterminado

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: Spacing.md) {
                if let progress {
                    VStack(spacing: Spacing.xs) {
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                            .frame(width: 240)
                            .tint(AppColors.primary)

                        Text("\(Int(progress * 100))%")
                            .font(AppFont.metricSmall)
                            .foregroundStyle(AppColors.textSecondary)
                            .monospacedDigit()
                    }
                } else {
                    ProgressView()
                        .controlSize(.large)
                        .tint(AppColors.primary)
                }

                Text(message)
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(Spacing.xl)
            .background(AppColors.surface, in: RoundedRectangle(cornerRadius: Radius.lg))
            .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        }
        .transition(.opacity.animation(.easeInOut(duration: AnimationDuration.normal)))
    }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Estado vazio — exibido quando não há dados para mostrar.
struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let description: String
    var action: (label: String, handler: () -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(AppColors.textSecondary)

            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(AppFont.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Text(description)
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }

            if let action {
                PrimaryButton(action.label, action: action.handler)
                    .padding(.top, Spacing.xs)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xxl)
    }
}

// ─── Previews ─────────────────────────────────────────────────────────────────

#Preview("Empty State") {
    EmptyStateView(
        systemImage: "internaldrive",
        title: "Nenhum arquivo encontrado",
        description: "Inicie um scan para analisar o armazenamento do seu Mac.",
        action: ("Iniciar scan", {})
    )
    .frame(width: 500, height: 400)
}
