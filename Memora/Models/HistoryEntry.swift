import Foundation

/// Entrada persistida no histórico de operações do app.
/// Armazenada pelo HistoryStore no banco SQLite e em history.json.
struct HistoryEntry: Identifiable, Sendable {
    let id: UUID
    let operation: CleanupOperation

    /// Data de criação desta entrada no histórico (pode diferir de `operation.performedAt` por milissegundos)
    let createdAt: Date
}
