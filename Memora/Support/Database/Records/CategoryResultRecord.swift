import Foundation
import GRDB

/// Registro da tabela `category_results` no SQLite.
/// Armazena o resultado agregado da classificação de uma categoria.
///
/// Os arquivos individuais de cada categoria não são armazenados aqui —
/// eles vivem na tabela `files` e são relidos pelo ClassificationEngine quando necessário.
struct CategoryResultRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "category_results"

    var id: String
    var category: String        // FileCategory.rawValue
    var fileCount: Int
    var safetyScore: Int
    var impactScore: Int
    var temporalScore: Int
    var updatedAt: Double       // Unix timestamp da última classificação

    // ─── Conversão ────────────────────────────────────────────────────────────

    init(from result: CategoryResult) {
        self.id           = result.id.uuidString
        self.category     = result.category.rawValue
        self.fileCount    = result.fileCount
        self.safetyScore  = result.score.safetyScore
        self.impactScore  = result.score.impactScore
        self.temporalScore = result.score.temporalScore
        self.updatedAt    = Date.now.timeIntervalSince1970
    }
}
