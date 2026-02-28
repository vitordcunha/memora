import SwiftUI

/// Botão primário do StoreLens — fundo colorido, texto branco.
/// Usado para ações de confirmação e CTAs principais.
struct PrimaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void
    var isDestructive: Bool = false
    var isLoading: Bool = false

    init(
        _ title: String,
        systemImage: String? = nil,
        isDestructive: Bool = false,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isDestructive = isDestructive
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                } else if let icon = systemImage {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title)
                    .font(AppFont.body)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(
                isDestructive ? Color.red : AppColors.primary,
                in: RoundedRectangle(cornerRadius: Radius.sm)
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Botão secundário — fundo transparente com borda.
/// Usado para ações secundárias como "Ver arquivos" ou "Cancelar".
struct SecondaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let icon = systemImage {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                Text(title)
                    .font(AppFont.body)
                    .fontWeight(.medium)
            }
            .foregroundStyle(AppColors.primary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .strokeBorder(AppColors.primary, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// ─── Previews ─────────────────────────────────────────────────────────────────

#Preview("Buttons") {
    VStack(spacing: Spacing.sm) {
        PrimaryButton("Limpar agora", systemImage: "trash") {}
        PrimaryButton("Remover", isDestructive: true) {}
        PrimaryButton("Aguarde...", isLoading: true) {}
        SecondaryButton("Ver arquivos", systemImage: "folder") {}
    }
    .padding(Spacing.md)
}
