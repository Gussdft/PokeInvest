import Foundation
import SwiftData

// --- ENUMS ---

enum CardCondition: String, Codable, CaseIterable, Identifiable {
    case mint = "Mint (Neuf)"
    case nearMint = "Near Mint (Proche Neuf)"
    case excellent = "Excellent"
    case good = "Bon"
    case played = "Joué"
    case damaged = "Abîmé"
    
    var id: String { rawValue }
}

enum SealedType: String, Codable, CaseIterable, Identifiable {
    case booster = "Booster"
    case display = "Display (Boîte)"
    case etb = "ETB (Coffret Dresseur)"
    case coffret = "Coffret Collection"
    case tin = "Pokébox"
    case upc = "Ultra Premium (UPC)"
    case other = "Autre"
    
    var id: String { rawValue }
}

enum GradingCompany: String, Codable, CaseIterable, Identifiable {
    case raw = "Non gradée"
    case psa = "PSA"
    case bgs = "Beckett"
    case cgc = "CGC"
    case pca = "PCA"
    
    var id: String { rawValue }
}

// --- MODÈLE : CARTE À L'UNITÉ ---

@Model
final class PokemonCard {
    var id: UUID
    var name: String
    var setParams: String
    var series: String
    var cardNumber: String
    var rarity: String
    var condition: CardCondition
    var gradingCompany: GradingCompany
    var gradeValue: Double?
    
    var purchasePrice: Double
    var purchaseDate: Date
    var estimatedValue: Double
    
    @Relationship(deleteRule: .cascade) var priceHistory: [PricingHistory] = []
    
    var profit: Double { estimatedValue - purchasePrice }
    
    var imageURLString: String?
    
    init(name: String, setParams: String, series: String = "Inconnue", cardNumber: String, rarity: String = "Commune", condition: CardCondition = .nearMint, purchasePrice: Double, estimatedValue: Double? = nil, imageURL: String? = nil) {
        self.id = UUID()
        self.name = name
        self.setParams = setParams
        self.series = series
        self.cardNumber = cardNumber
        self.rarity = rarity
        self.condition = condition
        self.gradingCompany = .raw
        self.purchasePrice = purchasePrice
        self.purchaseDate = Date()
        self.estimatedValue = estimatedValue ?? purchasePrice
        self.imageURLString = imageURL
    }
}

// --- MODÈLE : PRODUIT SCELLÉ ---

@Model
final class SealedProduct {
    var id: UUID
    var name: String
    var type: SealedType
    var setParams: String?
    
    var quantity: Int
    var imageURLString: String?
    
    var purchasePrice: Double
    var purchaseDate: Date
    var estimatedValue: Double
    
    @Relationship(deleteRule: .cascade) var priceHistory: [PricingHistory] = []
    
    var totalPurchasePrice: Double { purchasePrice * Double(quantity) }
    var totalEstimatedValue: Double { estimatedValue * Double(quantity) }
    var profit: Double { (estimatedValue - purchasePrice) * Double(quantity) }
    
    init(name: String, type: SealedType, purchasePrice: Double, quantity: Int = 1, imageURL: String? = nil) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.purchasePrice = purchasePrice
        self.quantity = quantity
        self.imageURLString = imageURL
        self.purchaseDate = Date()
        self.estimatedValue = purchasePrice
    }
}

// --- HISTORIQUE DES PRIX ---

@Model
final class PricingHistory {
    var date: Date
    var value: Double
    var source: String
    
    init(value: Double, source: String = "Auto") {
        self.date = Date()
        self.value = value
        self.source = source
    }
}

