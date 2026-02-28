import Foundation

/// Resultado da classificação de um conjunto de arquivos em uma categoria específica.
/// Produzido pelo ClassificationEngine e consumido pelo RecommendationEngine e pela UI.
struct CategoryResult: Identifiable, Sendable {
    let id: UUID
    let category: FileCategory
    let files: [FileMetadata]
    let score: CleanupScore

    /// Tamanho total de todos os arquivos da categoria, em bytes
    var totalSize: Int64 {
        files.reduce(0) { $0 + $1.size }
    }

    /// Tamanho total formatado para exibição (ex: "8,4 GB")
    var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }

    /// Nível de risco efetivo da categoria (considera o score calculado)
    var riskLevel: RiskLevel {
        category.defaultRiskLevel
    }

    var fileCount: Int {
        files.count
    }
}
