import Foundation

// ─── Protocolo principal ──────────────────────────────────────────────────────

/// Contrato público do módulo ClassificationEngine.
///
/// Responsabilidades:
/// - Receber a lista de FileMetadata do ScanEngine
/// - Aplicar as regras do RuleSet para categorizar cada arquivo
/// - Calcular o CleanupScore de cada categoria
/// - Retornar CategoryResults ordenados por impacto
///
/// Fluxo de dados: [FileMetadata] → ClassificationEngine → [CategoryResult] → RecommendationEngine
protocol ClassificationEngineProtocol: AnyObject, Sendable {

    /// Classifica um conjunto de arquivos em categorias e calcula os scores.
    ///
    /// - Parameter files: Lista de metadados produzida pelo ScanEngine
    /// - Returns: Lista de resultados por categoria, ordenada do maior para o menor score total
    func classify(_ files: [FileMetadata]) async -> [CategoryResult]

    /// Reclassifica apenas os arquivos de uma categoria específica.
    /// Útil para atualizar uma categoria sem reprocessar o disco inteiro.
    ///
    /// - Parameters:
    ///   - files: Subconjunto de arquivos a reclassificar
    ///   - category: A categoria alvo da reclassificação
    func reclassify(_ files: [FileMetadata], in category: FileCategory) async -> CategoryResult
}
