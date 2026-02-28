import Foundation

/// Caminhos de dados locais do StoreLens no sistema do usuário.
///
/// Todos os dados ficam dentro de ~/Library/Application Support/Memora/
/// O log de operações também é mantido em ~/.storelens/history.json
/// para compatibilidade com ferramentas de linha de comando.
enum AppPaths {

    // ─── Diretório raiz de dados ──────────────────────────────────────────────

    /// ~/Library/Application Support/Memora/
    static var appSupportDirectory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("Memora", isDirectory: true)
    }

    // ─── Banco de dados SQLite ────────────────────────────────────────────────

    /// ~/Library/Application Support/Memora/db.sqlite
    static var databaseURL: URL {
        appSupportDirectory.appendingPathComponent("db.sqlite")
    }

    // ─── Log de operações JSON ────────────────────────────────────────────────

    /// ~/.storelens/  (diretório do log)
    static var legacyLogDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".storelens", isDirectory: true)
    }

    /// ~/.storelens/history.json
    static var operationsLogURL: URL {
        legacyLogDirectory.appendingPathComponent("history.json")
    }

    // ─── Setup ───────────────────────────────────────────────────────────────

    /// Garante que todos os diretórios necessários existem no disco.
    /// Deve ser chamado na inicialização do app, antes de abrir o banco.
    static func createDirectoriesIfNeeded() throws {
        let fm = FileManager.default
        try fm.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true)
        try fm.createDirectory(at: legacyLogDirectory, withIntermediateDirectories: true)
    }
}
