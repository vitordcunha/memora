import SwiftUI

/// Badge de nível de risco — o "semáforo" exibido em categorias e recomendações.
///
/// Exibe um ícone + label com fundo colorido translúcido.
/// Disponível em dois tamanhos: `.regular` (padrão) e `.compact` (só ícone).
struct RiskBadge: View {
    let riskLevel: RiskLevel
    var style: Style = .regular

    enum Style {
        case regular    // ícone + texto
        case compact    // só ícone (para espaços reduzidos)
    }

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: riskLevel.systemImage)
                .font(.system(size: style == .regular ? 11 : 13, weight: .semibold))

            if style == .regular {
                Text(riskLevel.displayName)
                    .font(AppFont.caption)
                    .fontWeight(.medium)
            }
        }
        .foregroundStyle(riskLevel.appColor)
        .padding(.horizontal, style == .regular ? Spacing.xs : Spacing.xxs)
        .padding(.vertical, Spacing.xxs)
        .background(riskLevel.backgroundAppColor, in: RoundedRectangle(cornerRadius: Radius.sm))
    }
}

// ─── Previews ─────────────────────────────────────────────────────────────────

#Preview("Risk Badges") {
    VStack(alignment: .leading, spacing: Spacing.sm) {
        ForEach(RiskLevel.allCases, id: \.rawValue) { level in
            HStack(spacing: Spacing.sm) {
                RiskBadge(riskLevel: level)
                RiskBadge(riskLevel: level, style: .compact)
            }
        }
    }
    .padding(Spacing.md)
}

// ─── Conformance auxiliar para Previews ───────────────────────────────────────

extension RiskLevel: CaseIterable {
    public static var allCases: [RiskLevel] { [.veryLow, .low, .medium, .high] }
}
