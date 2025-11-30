import Foundation

class PokemonTCGService {
    private let tcgdexURL = "https://api.tcgdex.net/v2/fr"
    private let rapidBaseURL = "https://pokemon-tcg.p.rapidapi.com"
    private let rapidHostHeader = "pokemon-tcg.p.rapidapi.com"

    private var rapidAPIKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "RAPID_API_KEY") as? String
    }

    private var shouldUseRapidAPI: Bool { rapidAPIKey?.isEmpty == false }

    private func makeRequest(path: String, queryItems: [URLQueryItem] = []) throws -> URLRequest {
        let urlString: String
        if shouldUseRapidAPI {
            urlString = "\(rapidBaseURL)/\(path)"
        } else {
            urlString = "\(tcgdexURL)/\(path)"
        }

        guard var components = URLComponents(string: urlString) else { throw URLError(.badURL) }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let finalURL = components.url else { throw URLError(.badURL) }

        var request = URLRequest(url: finalURL)
        if let key = rapidAPIKey, shouldUseRapidAPI {
            request.addValue(key, forHTTPHeaderField: "X-RapidAPI-Key")
            request.addValue(rapidHostHeader, forHTTPHeaderField: "X-RapidAPI-Host")
        }
        return request
    }
    
    // 1. Récupérer toutes les séries (Extensions)
    func fetchSets() async throws -> [TCGSet] {
        let request = try makeRequest(path: "sets")
        let (data, _) = try await URLSession.shared.data(for: request)

        if let response = try? JSONDecoder().decode(TCGListResponse<TCGSet>.self, from: data) {
            return response.data
        }

        let sets = try JSONDecoder().decode([TCGSet].self, from: data)
        return sets
    }
    
    // 2. Récupérer les cartes d'une extension spécifique
    func fetchCards(forSetId setId: String) async throws -> [TCGCard] {
        let path: String
        var queryItems: [URLQueryItem] = []

        if shouldUseRapidAPI {
            path = "cards"
            queryItems = [URLQueryItem(name: "q", value: "set.id:\(setId)")]
        } else {
            path = "sets/\(setId)/cards"
        }

        let request = try makeRequest(path: path, queryItems: queryItems)
        let (data, _) = try await URLSession.shared.data(for: request)

        if let response = try? JSONDecoder().decode(TCGListResponse<TCGCard>.self, from: data) {
            return response.data.filter { $0.image != nil }
        }

        let cards = try JSONDecoder().decode([TCGCard].self, from: data)
        return cards.filter { $0.image != nil }
    }
    
    // 3. Recherche globale
    func searchCards(query: String) async throws -> [TCGCard] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw URLError(.badURL)
        }

        let path: String
        var queryItems: [URLQueryItem] = []

        if shouldUseRapidAPI {
            path = "cards"
            queryItems = [URLQueryItem(name: "q", value: "name:\(encodedQuery)")]
        } else {
            path = "cards"
            queryItems = [URLQueryItem(name: "name", value: encodedQuery)]
        }

        let request = try makeRequest(path: path, queryItems: queryItems)
        let (data, _) = try await URLSession.shared.data(for: request)

        if let response = try? JSONDecoder().decode(TCGListResponse<TCGCard>.self, from: data) {
            return response.data.filter { $0.image != nil }
        }

        let cards = try JSONDecoder().decode([TCGCard].self, from: data)
        return cards.filter { $0.image != nil }
    }
    
    // 4. Prix précis (Pour la mise à jour des cotes)
    func fetchPrice(cardName: String, cardNumber: String) async throws -> Double {
        let results = try await searchCards(query: "\(cardName) \(cardNumber)")
        if let price = results.first?.marketPrice {
            return price
        }
        throw URLError(.badServerResponse)
    }
}

struct TCGListResponse<T: Decodable>: Decodable {
    let data: [T]
}

