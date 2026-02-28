import Foundation

// ─── Erros do HistoryStore ────────────────────────────────────────────────────

enum HistoryStoreError: Error, Sendable {
    case databaseUnavailable
    case writeFailed(reason: String)
    case readFailed(reason: String)
}

// ─── Protocolo principal ──────────────────────────────────────────────────────

/// Contrato público do módulo HistoryStore.
///
/// Responsabilidades:
/// - Persistir todas as operações de limpeza executadas pelo CleanupExecutor
/// - Fornecer o histórico completo para exibição na tela de History
/// - Calcular o total acumulado de espaço liberado desde a instalação
/// - Manter sincronizados o banco SQLite e o arquivo history.json
///
/// Caminhos de dados:
/// - Banco SQLite: ~/Library/Application Support/Memora/db.sqlite
/// - Log JSON:     ~/.storelens/history.json
protocol HistoryStoreProtocol: AnyObject, Sendable {

    /// Registra uma operação de limpeza concluída.
    ///
    /// - Parameter operation: A operação finalizada pelo CleanupExecutor
    /// - Throws: `HistoryStoreError` em caso de falha de escrita
    func record(_ operation: CleanupOperation) async throws

    /// Retorna todas as entradas do histórico, ordenadas da mais recente para a mais antiga.
    func fetchAll() async throws -> [HistoryEntry]

    /// Retorna o total acumulado de espaço liberado em todas as operações registradas, em bytes.
    func totalSpaceFreed() async throws -> Int64

    /// Remove todas as entradas do histórico. Não afeta arquivos na Lixeira.
    func clear() async throws
}
