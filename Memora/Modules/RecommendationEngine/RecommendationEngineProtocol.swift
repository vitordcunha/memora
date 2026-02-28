import Foundation

// ─── Protocolo principal ──────────────────────────────────────────────────────

/// Contrato público do módulo RecommendationEngine.
///
/// Responsabilidades:
/// - Transformar CategoryResults em recomendações acionáveis com contexto textual
/// - Priorizar recomendações pelo score e nível de risco
/// - Fornecer o texto de contexto (por que pode ser removido) para cada categoria
///
/// Fluxo de dados: [CategoryResult] → RecommendationEngine → [CleanupRecommendation] → UI
protocol RecommendationEngineProtocol: AnyObject, Sendable {

    /// Gera a lista de recomendações a partir de todos os resultados de classificação.
    ///
    /// - Parameter results: Resultados produzidos pelo ClassificationEngine
    /// - Returns: Lista de recomendações ordenada por prioridade (score mais alto primeiro)
    func generateRecommendations(from results: [CategoryResult]) -> [CleanupRecommendation]

    /// Gera a recomendação para uma única categoria.
    ///
    /// - Parameters:
    ///   - category: A categoria alvo
    ///   - result: O resultado de classificação desta categoria
    func recommendation(for category: FileCategory, result: CategoryResult) -> CleanupRecommendation
}
