import Foundation

// --- MODÈLES POUR L'API TCGDex (FR) ---

struct TCGCard: Codable, Identifiable {
    let id: String
    let name: String
    let image: String?
    let localId: String?
    let rarity: String?
    let set: TCGSet?
    let cardmarket: TCGCardMarket?
    
    var fullName: String { name }
    
    var imageURL: URL? {
        guard let imageString = image else { return nil }
        let urlString = imageString.hasSuffix(".jpg") || imageString.hasSuffix(".png") ? imageString : "\(imageString)/high.png"
        return URL(string: urlString)
    }
}

struct TCGSet: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let logo: String?
    let symbol: String?
    let serie: TCGSerie?
    let releaseDate: String?
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: TCGSet, rhs: TCGSet) -> Bool { lhs.id == rhs.id }
}

struct TCGSerie: Codable, Hashable {
    let id: String
    let name: String
}

struct TCGCardMarket: Codable {
    let url: String?
    let updatedAt: String?
    let prices: TCGPrices?
}

struct TCGPrices: Codable {
    let trendPrice: Double?
    let avg30: Double?
    let avg1: Double?
    let avg7: Double?
    let lowPrice: Double?
}

