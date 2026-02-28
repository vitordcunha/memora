import Foundation
import GRDB

/// Registro da tabela `files` no SQLite.
/// Representa um arquivo indexado durante a varredura do disco.
///
/// Cada linha desta tabela corresponde a um FileMetadata processado pelo ScanEngine.
/// O campo `path` é único — reusar o mesmo caminho atualiza o registro existente.
struct FileRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "files"

    var id: String
    var name: String
    var path: String
    var size: Int64
    var mimeType: String?
    var createdAt: Double       // Unix timestamp
    var modifiedAt: Double
    var lastAccessedAt: Double
    var isSIPProtected: Bool
    var scannedAt: Double       // quando foi indexado pelo ScanEngine

    // ─── Conversão ────────────────────────────────────────────────────────────

    init(from metadata: FileMetadata) {
        self.id              = metadata.id.uuidString
        self.name            = metadata.name
        self.path            = metadata.path.path
        self.size            = metadata.size
        self.mimeType        = metadata.mimeType
        self.createdAt       = metadata.createdAt.timeIntervalSince1970
        self.modifiedAt      = metadata.modifiedAt.timeIntervalSince1970
        self.lastAccessedAt  = metadata.lastAccessedAt.timeIntervalSince1970
        self.isSIPProtected  = metadata.isSIPProtected
        self.scannedAt       = Date.now.timeIntervalSince1970
    }

    func toMetadata() -> FileMetadata? {
        guard let uuid = UUID(uuidString: id),
              let url  = URL(string: "file://\(path)") else { return nil }

        return FileMetadata(
            id:               uuid,
            name:             name,
            path:             url,
            size:             size,
            mimeType:         mimeType,
            createdAt:        Date(timeIntervalSince1970: createdAt),
            modifiedAt:       Date(timeIntervalSince1970: modifiedAt),
            lastAccessedAt:   Date(timeIntervalSince1970: lastAccessedAt),
            isSIPProtected:   isSIPProtected
        )
    }
}
