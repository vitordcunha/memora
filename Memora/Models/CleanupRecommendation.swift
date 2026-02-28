import Foundation

/// Uma recomendação de limpeza apresentada ao usuário no Dashboard e na tela de detalhes.
/// Produzida pelo RecommendationEngine a partir de um CategoryResult.
struct CleanupRecommendation: Identifiable, Sendable {
    let id: UUID

    /// Nome curto exibido como título da recomendação (ex: "Limpar cache do Xcode")
    let title: String

    /// Explicação em linguagem natural do que é o conteúdo e por que pode ser removido com segurança
    let context: String

    /// Espaço estimado que será liberado, em bytes
    let estimatedImpact: Int64

    let riskLevel: RiskLevel

    /// O resultado de classificação que originou esta recomendação
    let categoryResult: CategoryResult

    /// Espaço estimado formatado para exibição (ex: "8,4 GB")
    var formattedImpact: String {
        ByteCountFormatter.string(fromByteCount: estimatedImpact, countStyle: .file)
    }
}
