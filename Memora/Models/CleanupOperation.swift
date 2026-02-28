import Foundation

/// Representa uma operação de limpeza executada pelo CleanupExecutor.
/// É registrada no HistoryStore após a conclusão.
struct CleanupOperation: Identifiable, Sendable {
    let id: UUID
    let performedAt: Date
    let category: FileCategory

    /// Arquivos que foram movidos para a Lixeira nesta operação
    let affectedFiles: [FileMetadata]

    /// Espaço total liberado em bytes
    let spaceFreed: Int64

    let status: OperationStatus

    var formattedSpaceFreed: String {
        ByteCountFormatter.string(fromByteCount: spaceFreed, countStyle: .file)
    }
}

/// Status de conclusão de uma operação de limpeza
enum OperationStatus: Sendable {
    /// Todos os arquivos foram movidos com sucesso para a Lixeira
    case success

    /// Parte dos arquivos foi movida; os demais falharam (ex: arquivo em uso)
    case partialSuccess(failedCount: Int)

    /// A operação falhou completamente
    case failed(reason: String)

    var displayName: String {
        switch self {
        case .success:
            return "Concluído"
        case .partialSuccess(let count):
            return "Parcial (\(count) arquivo(s) não removido(s))"
        case .failed(let reason):
            return "Falhou: \(reason)"
        }
    }

    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}
