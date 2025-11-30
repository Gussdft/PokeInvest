import Foundation

// --- MODÈLES FLEXIBLES POUR TCGDex OU RapidAPI ---

struct TCGCard: Codable, Identifiable {
    let id: String
    let name: String
    let image: String?
    let localId: String?
    let rarity: String?
    let set: TCGSet?
    let cardmarket: TCGCardMarket?

    var fullName: String { name }

    /// URL de l'image haute définition (TCGDex ou RapidAPI)
    var imageURL: URL? {
        guard let imageString = image else { return nil }
        let urlString = imageString.hasSuffix(".jpg") || imageString.hasSuffix(".png") ? imageString : "\(imageString)/high.png"
        return URL(string: urlString)
    }

    /// Prix principal remonté par l'API (Cardmarket)
    var marketPrice: Double? {
        cardmarket?.prices?.displayPrice
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, image, images, localId, number, rarity, set, cardmarket
    }

    private struct Images: Codable { let small: String?; let large: String? }

    init(id: String, name: String, image: String?, localId: String?, rarity: String?, set: TCGSet?, cardmarket: TCGCardMarket?) {
        self.id = id
        self.name = name
        self.image = image
        self.localId = localId
        self.rarity = rarity
        self.set = set
        self.cardmarket = cardmarket
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)

        // Image : champ "image" (TCGDex) ou "images" (RapidAPI/pokemontcg.io)
        if let directImage = try container.decodeIfPresent(String.self, forKey: .image) {
            image = directImage
        } else if let images = try container.decodeIfPresent(Images.self, forKey: .images) {
            image = images.large ?? images.small
        } else {
            image = nil
        }

        // Numéro de carte : "localId" (TCGDex) ou "number" (RapidAPI)
        localId = try container.decodeIfPresent(String.self, forKey: .localId)
            ?? container.decodeIfPresent(String.self, forKey: .number)

        rarity = try container.decodeIfPresent(String.self, forKey: .rarity)
        set = try container.decodeIfPresent(TCGSet.self, forKey: .set)
        cardmarket = try container.decodeIfPresent(TCGCardMarket.self, forKey: .cardmarket)
    }
}

struct TCGSet: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let logo: String?
    let symbol: String?
    let serie: TCGSerie?
    let releaseDate: String?

    private enum CodingKeys: String, CodingKey {
        case id, name, logo, symbol, serie, series, releaseDate, images
    }

    private struct Images: Codable { let symbol: String?; let logo: String? }

    init(id: String, name: String, logo: String?, symbol: String?, serie: TCGSerie?, releaseDate: String?) {
        self.id = id
        self.name = name
        self.logo = logo
        self.symbol = symbol
        self.serie = serie
        self.releaseDate = releaseDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)

        // Logos & symboles : TCGDex (logo/symbol) ou RapidAPI (images.logo/images.symbol)
        if let images = try container.decodeIfPresent(Images.self, forKey: .images) {
            logo = images.logo
            symbol = images.symbol
        } else {
            logo = try container.decodeIfPresent(String.self, forKey: .logo)
            symbol = try container.decodeIfPresent(String.self, forKey: .symbol)
        }

        // Série : TCGDex (serie struct) ou RapidAPI (series string)
        if let seriesName = try container.decodeIfPresent(String.self, forKey: .series) {
            serie = TCGSerie(id: seriesName, name: seriesName)
        } else {
            serie = try container.decodeIfPresent(TCGSerie.self, forKey: .serie)
        }
    }

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
    let averageSellPrice: Double?

    private enum CodingKeys: String, CodingKey {
        case trendPrice, avg30, avg1, avg7, lowPrice, averageSellPrice
    }

    var displayPrice: Double? {
        averageSellPrice ?? trendPrice ?? avg7 ?? avg30 ?? lowPrice ?? avg1
    }
}

