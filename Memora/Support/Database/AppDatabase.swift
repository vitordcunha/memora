import Foundation
import GRDB

/// Gerenciador central do banco de dados SQLite do StoreLens.
///
/// Responsável por:
/// - Criar e abrir o banco em ~/Library/Application Support/Memora/db.sqlite
/// - Executar as migrações de schema na inicialização
/// - Fornecer acesso à `DatabaseQueue` para leituras e escritas
///
/// Uso:
/// ```swift
/// let db = try AppDatabase()
/// try await db.queue.write { db in
///     try FileRecord(from: metadata).insert(db)
/// }
/// ```
///
/// ## Estratégia de Migração
///
/// Migrações são registradas com nomes únicos e crescentes (ex: "v1_initial", "v2_add_index").
/// O GRDB garante que cada migração roda exatamente uma vez — ao atualizar o app,
/// apenas as migrações novas são executadas. Nunca altere uma migração já publicada;
/// sempre adicione uma nova.
final class AppDatabase {

    /// Instância compartilhada. Deve ser inicializada uma vez no AppDelegate ou na App struct.
    static var shared: AppDatabase!

    /// A fila de acesso ao banco. Serializa leituras e escritas de forma thread-safe.
    let queue: DatabaseQueue

    // ─── Inicialização ────────────────────────────────────────────────────────

    init() throws {
        try AppPaths.createDirectoriesIfNeeded()

        var config = Configuration()
        config.label = "StoreLens.AppDatabase"

        // Em Debug, ativa o log de todas as queries SQL executadas
        #if DEBUG
        config.prepareDatabase { db in
            db.trace(options: .statement) { event in
                print("[SQL] \(event)")
            }
        }
        #endif

        queue = try DatabaseQueue(path: AppPaths.databaseURL.path, configuration: config)
        try runMigrations()
    }

    // ─── Migrações ────────────────────────────────────────────────────────────

    private func runMigrations() throws {
        var migrator = DatabaseMigrator()

        // ── v1: Schema inicial ─────────────────────────────────────────────────
        //
        // Cria todas as tabelas do MVP. Futuras versões adicionam
        // migrações "v2_...", "v3_..." sem modificar esta.
        migrator.registerMigration("v1_initial") { db in

            // Índice de arquivos escaneados pelo ScanEngine
            try db.create(table: "files") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull()
                t.column("path", .text).notNull().unique()
                t.column("size", .integer).notNull()
                t.column("mimeType", .text)
                t.column("createdAt", .double).notNull()
                t.column("modifiedAt", .double).notNull()
                t.column("lastAccessedAt", .double).notNull()
                t.column("isSIPProtected", .boolean).notNull().defaults(to: false)
                t.column("scannedAt", .double).notNull()
            }

            // Resultado agregado por categoria (ClassificationEngine)
            try db.create(table: "category_results") { t in
                t.primaryKey("id", .text)
                t.column("category", .text).notNull().unique()
                t.column("fileCount", .integer).notNull()
                t.column("safetyScore", .integer).notNull()
                t.column("impactScore", .integer).notNull()
                t.column("temporalScore", .integer).notNull()
                t.column("updatedAt", .double).notNull()
            }

            // Histórico de operações de limpeza (CleanupExecutor)
            try db.create(table: "cleanup_operations") { t in
                t.primaryKey("id", .text)
                t.column("performedAt", .double).notNull()
                t.column("category", .text).notNull()
                t.column("spaceFreed", .integer).notNull()
                t.column("fileCount", .integer).notNull()
                t.column("status", .text).notNull()
                t.column("statusDetail", .text)
            }

            // Arquivos afetados por cada operação (relação 1:N)
            try db.create(table: "operation_files") { t in
                t.column("operationId", .text).notNull()
                    .references("cleanup_operations", onDelete: .cascade)
                t.column("filePath", .text).notNull()
                t.column("fileName", .text).notNull()
                t.column("fileSize", .integer).notNull()
            }

            // Preferências do app (chave-valor)
            try db.create(table: "preferences") { t in
                t.primaryKey("key", .text)
                t.column("value", .text).notNull()
                t.column("updatedAt", .double).notNull()
            }

            // Índices para queries frequentes
            try db.create(
                index: "files_on_lastAccessedAt",
                on: "files",
                columns: ["lastAccessedAt"]
            )
            try db.create(
                index: "files_on_size",
                on: "files",
                columns: ["size"]
            )
            try db.create(
                index: "cleanup_operations_on_performedAt",
                on: "cleanup_operations",
                columns: ["performedAt"]
            )
            try db.create(
                index: "operation_files_on_operationId",
                on: "operation_files",
                columns: ["operationId"]
            )
        }

        // Migrações futuras são adicionadas aqui:
        // migrator.registerMigration("v2_add_duplicate_hash") { db in ... }
        // migrator.registerMigration("v3_add_external_volumes") { db in ... }

        try migrator.migrate(queue)
    }
}
