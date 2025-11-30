import Foundation

class PokemonTCGService {
    private let baseURL = "https://api.tcgdex.net/v2/fr"
    
    // 1. Récupérer toutes les séries (Extensions)
    func fetchSets() async throws -> [TCGSet] {
        let url = URL(string: "\(baseURL)/sets")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let sets = try JSONDecoder().decode([TCGSet].self, from: data)
        return sets
    }
    
    // 2. Récupérer les cartes d'une extension spécifique
    func fetchCards(forSetId setId: String) async throws -> [TCGCard] {
        let url = URL(string: "\(baseURL)/sets/\(setId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        struct SetDetailResponse: Codable { let cards: [TCGCard] }
        let response = try JSONDecoder().decode(SetDetailResponse.self, from: data)
        return response.cards.filter { $0.image != nil }
    }
    
    // 3. Recherche globale
    func searchCards(query: String) async throws -> [TCGCard] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/cards?name=\(encodedQuery)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let cards = try JSONDecoder().decode([TCGCard].self, from: data)
        return cards.filter { $0.image != nil }
    }
    
    // 4. Prix précis (Pour la mise à jour des cotes)
    func fetchPrice(cardName: String, cardNumber: String) async throws -> Double {
        // Mise de côté de l'API Cardmarket pour l'instant
        return 0.0
    }
}

