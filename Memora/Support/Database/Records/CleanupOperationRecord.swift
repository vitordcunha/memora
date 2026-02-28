import Foundation
import GRDB

/// Registro da tabela `cleanup_operations` no SQLite.
/// Representa uma operação de limpeza concluída pelo CleanupExecutor.
struct CleanupOperationRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "cleanup_operations"

    var id: String
    var performedAt: Double     // Unix timestamp
    var category: String        // FileCategory.rawValue
    var spaceFreed: Int64
    var fileCount: Int
    var status: String          // "success" | "partial" | "failed"
    var statusDetail: String?   // detalhe para partial (count) ou failed (reason)

    // ─── Conversão ────────────────────────────────────────────────────────────

    init(from operation: CleanupOperation) {
        self.id          = operation.id.uuidString
        self.performedAt = operation.performedAt.timeIntervalSince1970
        self.category    = operation.category.rawValue
        self.spaceFreed  = operation.spaceFreed
        self.fileCount   = operation.affectedFiles.count

        switch operation.status {
        case .success:
            self.status       = "success"
            self.statusDetail = nil
        case .partialSuccess(let count):
            self.status       = "partial"
            self.statusDetail = "\(count)"
        case .failed(let reason):
            self.status       = "failed"
            self.statusDetail = reason
        }
    }

    func toOperationStatus() -> OperationStatus {
        switch status {
        case "success":
            return .success
        case "partial":
            let count = Int(statusDetail ?? "0") ?? 0
            return .partialSuccess(failedCount: count)
        default:
            return .failed(reason: statusDetail ?? "Erro desconhecido")
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Registro da tabela `operation_files` no SQLite.
/// Relaciona arquivos afetados a uma operação de limpeza (1 operação → N arquivos).
struct OperationFileRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "operation_files"

    var operationId: String
    var filePath: String
    var fileName: String
    var fileSize: Int64

    init(operationId: String, file: FileMetadata) {
        self.operationId = operationId
        self.filePath    = file.path.path
        self.fileName    = file.name
        self.fileSize    = file.size
    }
}
