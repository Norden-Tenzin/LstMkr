//
//  LstMkrApp.swift
//  LstMkr
//
//  Created by Tenzin Norden on 10/2/23.
//

import SwiftUI
import SwiftData

@main
struct LstMkrApp: App {
    @State var appState: AppState = AppState()
    let container: ModelContainer
    init() {
        do {
            container = try ModelContainer(for: ListModel.self)
        } catch {
            fatalError("Failed to create ModelContainer for Movie.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $appState.navigationPath) {
                ListView(modelContext: container.mainContext)
            }
                .environment(appState)
        }
            .modelContainer(container)
    }


}
