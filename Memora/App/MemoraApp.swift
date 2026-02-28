import SwiftUI

@main
struct MemoraApp: App {

    init() {
        do {
            AppDatabase.shared = try AppDatabase()
        } catch {
            // Em produção, exibir tela de erro e encerrar o app de forma controlada.
            // Durante o desenvolvimento, um crash aqui indica problema de permissão ou schema.
            fatalError("Falha ao inicializar o banco de dados: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

