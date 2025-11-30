import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class CollectionViewModel: ObservableObject {
    private let tcgService = PokemonTCGService()
    
    @Published var isLoading = false
    
    // 1. Mise à jour des CARTES (Mise de côté)
    func refreshPrices(for cards: [PokemonCard]) async {
        isLoading = true
        defer { isLoading = false }
        for card in cards {
            // Simulation d'attente
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }
    
    // 2. Mise à jour du SCELLÉ (Mise de côté)
    func refreshSealed(for products: [SealedProduct]) async {
        isLoading = true
        defer { isLoading = false }
        for product in products {
            // Simulation d'attente
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }
}

