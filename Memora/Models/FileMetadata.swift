import Foundation

/// Representa os metadados de um arquivo encontrado durante a varredura do disco.
/// Nenhum conteúdo do arquivo é lido — apenas informações do sistema de arquivos.
struct FileMetadata: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let path: URL
    let size: Int64
    let mimeType: String?
    let createdAt: Date
    let modifiedAt: Date
    let lastAccessedAt: Date
    let isSIPProtected: Bool

    /// Conveniência: retorna o tamanho formatado para exibição (ex: "8,4 GB")
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    /// Tempo desde o último acesso ao arquivo
    var daysSinceLastAccess: Int {
        Calendar.current.dateComponents([.day], from: lastAccessedAt, to: .now).day ?? 0
    }
}
