import SwiftUI

/// Tokens de design do StoreLens: espaçamento, raios de borda e durações de animação.
///
/// Usar sempre estas constantes — nunca valores literais como `padding(16)`.
/// Isso garante consistência e facilita ajustes globais de layout.
enum Spacing {
    /// 4 pt — espaçamento mínimo entre elementos internos
    static let xxs: CGFloat = 4
    /// 8 pt — espaçamento pequeno
    static let xs:  CGFloat = 8
    /// 12 pt — espaçamento entre label e valor
    static let sm:  CGFloat = 12
    /// 16 pt — padding padrão de cards e seções
    static let md:  CGFloat = 16
    /// 24 pt — separação entre grupos de conteúdo
    static let lg:  CGFloat = 24
    /// 32 pt — separação entre seções maiores
    static let xl:  CGFloat = 32
    /// 48 pt — margens de telas e painéis
    static let xxl: CGFloat = 48
}

enum Radius {
    /// 6 pt — badges e elementos pequenos
    static let sm:  CGFloat = 6
    /// 10 pt — cards e painéis
    static let md:  CGFloat = 10
    /// 14 pt — painéis grandes e modais
    static let lg:  CGFloat = 14
    /// 20 pt — elementos destacados (ex: ilustrações no onboarding)
    static let xl:  CGFloat = 20
}

enum AnimationDuration {
    /// 150ms — feedback imediato (hover, press)
    static let fast:   Double = 0.15
    /// 250ms — transições de estado (mostrar/ocultar)
    static let normal: Double = 0.25
    /// 400ms — animações de entrada de telas
    static let slow:   Double = 0.40
}

// ─── Tipografia ───────────────────────────────────────────────────────────────

/// Estilos tipográficos do StoreLens.
///
/// Baseado na fonte SF Pro (padrão do sistema macOS).
/// Não definir tamanhos fixos para texto de conteúdo — usar os estilos
/// do sistema (`.title`, `.body`, etc.) que respeitam as preferências
/// de acessibilidade do usuário (Dynamic Type).
enum AppFont {
    /// Título da tela ou seção principal — 28pt, bold
    static let screenTitle   = Font.system(size: 28, weight: .bold, design: .default)

    /// Título de um card ou painel — 17pt, semibold
    static let cardTitle     = Font.system(size: 17, weight: .semibold, design: .default)

    /// Label de categoria ou seção — 13pt, semibold, uppercase tratado via modifier
    static let sectionLabel  = Font.system(size: 13, weight: .semibold, design: .default)

    /// Texto de corpo — 14pt, regular
    static let body          = Font.system(size: 14, weight: .regular, design: .default)

    /// Texto secundário e metadados — 12pt, regular
    static let caption       = Font.system(size: 12, weight: .regular, design: .default)

    /// Valor numérico de destaque (ex: tamanho em GB) — 22pt, bold, monoespaçado
    static let metric        = Font.system(size: 22, weight: .bold, design: .rounded)

    /// Valor numérico menor (ex: contagem de arquivos) — 14pt, medium, monoespaçado
    static let metricSmall   = Font.system(size: 14, weight: .medium, design: .rounded)
}
