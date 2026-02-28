import SwiftUI

/// Linha de uma categoria na lista do Dashboard.
///
/// Exibe: ícone da categoria, nome, contagem de arquivos,
/// barra de impacto relativo, tamanho total e badge de risco.
struct CategoryRow: View {
    let result: CategoryResult
    /// Tamanho total do maior item na lista — usado para normalizar a barra de impacto
    var maxSize: Int64 = 1

    var body: some View {
        HStack(spacing: Spacing.sm) {

            // ── Ícone ──────────────────────────────────────────────────────────
            ZStack {
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(result.riskLevel.backgroundAppColor)
                    .frame(width: 36, height: 36)

                Image(systemName: result.category.systemImage)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(result.riskLevel.appColor)
            }

            // ── Nome e metadados ───────────────────────────────────────────────
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(result.category.displayName)
                    .font(AppFont.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)

                // Barra de impacto relativo
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppColors.surfaceSecondary)
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(result.riskLevel.appColor.opacity(0.7))
                            .frame(
                                width: geo.size.width * impactRatio,
                                height: 4
                            )
                    }
                }
                .frame(height: 4)

                Text("\(result.fileCount) arquivo(s)")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            // ── Tamanho e badge ────────────────────────────────────────────────
            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                Text(result.formattedTotalSize)
                    .font(AppFont.metricSmall)
                    .foregroundStyle(AppColors.textPrimary)
                    .monospacedDigit()

                RiskBadge(riskLevel: result.riskLevel, style: .compact)
            }
        }
        .padding(Spacing.sm)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: Radius.md))
    }

    private var impactRatio: CGFloat {
        guard maxSize > 0 else { return 0 }
        return min(CGFloat(result.totalSize) / CGFloat(maxSize), 1.0)
    }
}

// ─── Extensão de ícone por categoria ──────────────────────────────────────────

extension FileCategory {
    var systemImage: String {
        switch self {
        case .systemCaches:       return "internaldrive"
        case .appCaches:          return "app.badge"
        case .logs:               return "doc.text"
        case .oldDownloads:       return "arrow.down.circle"
        case .duplicates:         return "doc.on.doc"
        case .appResiduals:       return "trash.slash"
        case .largeInactiveFiles: return "archivebox"
        case .iosBackups:         return "iphone"
        case .devBuilds:          return "hammer"
        case .junkFiles:          return "xmark.circle"
        }
    }
}
