import SwiftUI

/// Paleta de cores semântica do StoreLens.
///
/// Todas as cores respondem automaticamente ao Dark Mode e Light Mode.
/// Usar sempre estas constantes na UI — nunca valores hexadecimais diretos.
///
/// Adaptação futura para Liquid Glass (macOS 26):
/// Os modificadores de material (`.background(.ultraThinMaterial)`) serão
/// adicionados por cima destas cores base sem necessidade de reescrever a paleta.
enum AppColors {

    // ─── Fundo e Superfície ───────────────────────────────────────────────────

    /// Cor de fundo da janela principal
    static let background         = Color("colorBackground")

    /// Cor de fundo de cards e painéis elevados
    static let surface            = Color("colorSurface")

    /// Cor de fundo de painéis secundários e seções internas
    static let surfaceSecondary   = Color("colorSurfaceSecondary")

    /// Linha divisória entre seções
    static let separator          = Color("colorSeparator")

    // ─── Texto ────────────────────────────────────────────────────────────────

    /// Texto principal — títulos, valores, labels importantes
    static let textPrimary        = Color("colorTextPrimary")

    /// Texto secundário — descrições, metadados, labels auxiliares
    static let textSecondary      = Color("colorTextSecondary")

    // ─── Cor de Ação (Primária) ───────────────────────────────────────────────

    /// Cor de ação principal — botões, links, indicadores ativos
    static let primary            = Color("colorPrimary")

    /// Cor do botão primário em estado hover/pressed
    static let primaryHover       = Color("colorPrimaryHover")

    // ─── Risco — Cores de Destaque ────────────────────────────────────────────

    static let riskVeryLow        = Color("colorRiskVeryLow")
    static let riskLow            = Color("colorRiskLow")
    static let riskMedium         = Color("colorRiskMedium")
    static let riskHigh           = Color("colorRiskHigh")

    // ─── Risco — Fundos dos Badges ────────────────────────────────────────────

    static let riskVeryLowBg      = Color("colorRiskVeryLowBackground")
    static let riskLowBg          = Color("colorRiskLowBackground")
    static let riskMediumBg       = Color("colorRiskMediumBackground")
    static let riskHighBg         = Color("colorRiskHighBackground")
}

// ─── Extensão para RiskLevel ──────────────────────────────────────────────────

extension RiskLevel {
    /// Cor de destaque para este nível de risco (ícone, borda, texto colorido)
    var appColor: Color {
        switch self {
        case .veryLow: return AppColors.riskVeryLow
        case .low:     return AppColors.riskLow
        case .medium:  return AppColors.riskMedium
        case .high:    return AppColors.riskHigh
        }
    }

    /// Cor de fundo do badge para este nível de risco (baixa opacidade)
    var backgroundAppColor: Color {
        switch self {
        case .veryLow: return AppColors.riskVeryLowBg
        case .low:     return AppColors.riskLowBg
        case .medium:  return AppColors.riskMediumBg
        case .high:    return AppColors.riskHighBg
        }
    }
}
