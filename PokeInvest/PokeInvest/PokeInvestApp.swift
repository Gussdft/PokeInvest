import SwiftUI
import SwiftData

@main
struct PokeInvestApp: App {
    let container: ModelContainer

    init() {
        do {
            // Déclaration de tous les modèles pour la base de données
            let schema = Schema([
                PokemonCard.self,
                SealedProduct.self,
                PricingHistory.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Erreur critique SwiftData: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}

