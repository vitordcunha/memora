//
//  ContentView.swift
//  Memora
//
//  Created by Vitor Cunha on 28/02/26.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var coordinator  = OnboardingCoordinator.shared
    @StateObject private var permissions  = PermissionManager.shared

    var body: some View {
        Group {
            if coordinator.isCompleted {
                // Fase 1.2+ — Dashboard (placeholder por enquanto)
                EmptyStateView(
                    systemImage: "internaldrive",
                    title: "Nenhum scan ainda",
                    description: "O primeiro scan será iniciado em breve."
                )
            } else {
                OnboardingView()
            }
        }
        .environmentObject(coordinator)
        .environmentObject(permissions)
    }
}
