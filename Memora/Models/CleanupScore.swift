import Foundation

/// Score composto (0–100) que orienta a priorização das recomendações de limpeza.
///
/// Três eixos independentes:
/// - **Segurança** (0–40 pts): quão seguro é remover — baseado no tipo, origem e regenerabilidade
/// - **Impacto**   (0–40 pts): tamanho absoluto e percentual do volume total
/// - **Temporal**  (0–20 pts): tempo desde o último acesso ou modificação
struct CleanupScore: Sendable {
    /// Segurança de remoção: 0 = arriscado, 40 = totalmente seguro
    let safetyScore: Int

    /// Impacto em espaço: 0 = irrelevante, 40 = impacto máximo
    let impactScore: Int

    /// Relevância temporal: 0 = acesso recente, 20 = sem acesso há muito tempo
    let temporalScore: Int

    /// Score total ponderado (0–100). Quanto maior, maior a prioridade de limpeza.
    var total: Int {
        safetyScore + impactScore + temporalScore
    }

    /// Score normalizado entre 0.0 e 1.0 para uso em componentes de UI (ex: barras de progresso)
    var normalized: Double {
        Double(total) / 100.0
    }

    static let zero = CleanupScore(safetyScore: 0, impactScore: 0, temporalScore: 0)
}
