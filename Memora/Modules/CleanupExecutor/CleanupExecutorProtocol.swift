import Foundation

// ─── Tipos de suporte ao CleanupExecutor ─────────────────────────────────────

/// Progresso em tempo real emitido durante a execução de uma limpeza.
struct CleanupProgress: Sendable {
    let filesProcessed: Int
    let totalFiles: Int
    let spaceFreedSoFar: Int64

    var percentComplete: Double {
        guard totalFiles > 0 else { return 0 }
        return Double(filesProcessed) / Double(totalFiles)
    }

    var formattedSpaceFreed: String {
        ByteCountFormatter.string(fromByteCount: spaceFreedSoFar, countStyle: .file)
    }
}

// ─── Erros do CleanupExecutor ────────────────────────────────────────────────

enum CleanupError: Error, Sendable {
    /// Tentativa de remover um arquivo fora dos diretórios permitidos sem confirmação extra
    case unsafePath(URL)

    /// Tentativa de remover um arquivo protegido pelo SIP
    case sipProtected(URL)

    /// Falha ao mover o arquivo para a Lixeira (ex: arquivo em uso por outro processo)
    case trashFailed(URL, reason: String)

    /// Operação cancelada pelo usuário
    case cancelled
}

// ─── Protocolo principal ──────────────────────────────────────────────────────

/// Contrato público do módulo CleanupExecutor.
///
/// Responsabilidades:
/// - Executar a remoção aprovada pelo usuário, sempre via Lixeira (FileManager.trashItem)
/// - Aplicar todas as regras de segurança antes de cada remoção
/// - Nunca remover arquivos permanentemente no MVP
/// - Registrar cada operação no HistoryStore
///
/// Fluxo de dados: UI (confirmação) → CleanupExecutor → Trash + HistoryStore
///
/// Regras de segurança invioláveis:
/// - Sempre usar FileManager.trashItem() — nunca FileManager.removeItem()
/// - Nunca processar arquivos com isSIPProtected == true
/// - Nunca processar arquivos fora de ~/Library, ~/Downloads, ~/Desktop sem flag de confirmação extra
protocol CleanupExecutorProtocol: AnyObject, Sendable {

    /// Stream de progresso emitido durante a execução da limpeza.
    var progress: AsyncStream<CleanupProgress> { get }

    /// Executa uma operação de limpeza pré-aprovada pelo usuário.
    ///
    /// - Parameter operation: A operação com os arquivos a serem movidos para a Lixeira
    /// - Returns: A operação atualizada com o status final e o espaço real liberado
    /// - Throws: `CleanupError` em caso de violação de segurança, falha ou cancelamento
    func execute(_ operation: CleanupOperation) async throws -> CleanupOperation

    /// Cancela a operação em andamento. Arquivos já processados permanecem na Lixeira.
    func cancel()
}
