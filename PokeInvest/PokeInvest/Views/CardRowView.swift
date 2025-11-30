//
//  CardRowView.swift
//  PokeInvest
//
//  Created by Augustin Dufetelle on 30/11/2025.
//


import SwiftUI
import SwiftData
import Charts

// ************************************************
// MARK: - VUES DE LIGNE (Rows)
// ************************************************

struct CardRowView: View {
    let card: PokemonCard
    var body: some View {
        HStack(spacing: 12) {
            if let urlStr = card.imageURLString, let url = URL(string: urlStr) {
                AsyncImage(url: url) { p in if let i = p.image { i.resizable().aspectRatio(contentMode: .fit) } else { Color.gray.opacity(0.3) } }.frame(width: 50, height: 70).cornerRadius(4)
            } else { Rectangle().fill(.gray).frame(width: 50, height: 70).cornerRadius(4) }
            
            VStack(alignment: .leading) {
                Text(card.name).font(.headline).foregroundStyle(.white).lineLimit(1)
                Text(card.rarity).font(.caption).foregroundStyle(.indigo)
                Text("#\(card.cardNumber)").font(.caption2).foregroundStyle(.gray)
            }
            Spacer()
            if card.estimatedValue > 0 { Text(String(format: "%.0f €", card.estimatedValue)).font(.subheadline).bold().foregroundStyle(.white) }
            else { Text("--- €").font(.subheadline).bold().foregroundStyle(.gray) }
        }
        .padding(10)
    }
}

struct SealedRowView: View {
    let product: SealedProduct
    var body: some View {
        HStack(spacing: 12) {
            if let urlStr = product.imageURLString, let url = URL(string: urlStr) {
                AsyncImage(url: url) { p in if let i = p.image { i.resizable().aspectRatio(contentMode: .fit) } else { Color.gray.opacity(0.3) } }.frame(width: 60, height: 60).cornerRadius(8)
            } else {
                ZStack { Rectangle().fill(LinearGradient(colors: [.orange.opacity(0.3), .red.opacity(0.3)], startPoint: .top, endPoint: .bottom)); Image(systemName: "cube.box.fill").font(.largeTitle).foregroundStyle(.white.opacity(0.5)) }.frame(width: 60, height: 60).cornerRadius(8)
            }
            VStack(alignment: .leading) {
                Text(product.name).font(.headline).foregroundStyle(.white)
                Text("Qté: \(product.quantity)").font(.caption).foregroundStyle(.gray)
            }
            Spacer()
            Text(String(format: "%.0f €", product.totalEstimatedValue)).font(.title3).bold().foregroundStyle(.white)
        }.padding(12).background(.ultraThinMaterial).cornerRadius(16)
    }
}

// ************************************************
// MARK: - ÉCRAN PRINCIPAL
// ************************************************

struct CollectionListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: [SortDescriptor(\PokemonCard.setParams), SortDescriptor(\PokemonCard.cardNumber)]) 
    private var cards: [PokemonCard]
    
    @Query(sort: \SealedProduct.purchaseDate, order: .reverse) private var sealedProducts: [SealedProduct]
    
    @StateObject private var viewModel = CollectionViewModel()
    @State private var selectedTab = 0 
    
    @State private var showingAddCard = false
    @State private var showingAddSealed = false
    @State private var editingProduct: SealedProduct?
    @State private var editingCard: PokemonCard?
    
    var cardsBySet: [String: [PokemonCard]] { Dictionary(grouping: cards, by: { $0.setParams }) }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.12).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Picker("Type", selection: $selectedTab) { Text("Cartes").tag(0); Text("Scellé").tag(1) }
                    .pickerStyle(.segmented).padding().background(.ultraThinMaterial)
                    
                    if selectedTab == 0 {
                        // VUE CARTES
                        if cards.isEmpty {
                            ContentUnavailableView("Collection Vide", systemImage: "menucard", description: Text("Ajoutez des cartes via le bouton +")).foregroundStyle(.gray)
                        } else {
                            List {
                                if viewModel.isLoading { HStack { Spacer(); ProgressView().tint(.white); Spacer() }.listRowBackground(Color.clear) }
                                
                                ForEach(cardsBySet.keys.sorted(), id: \.self) { setName in
                                    Section(header: Text(setName).font(.headline).foregroundStyle(.indigo)) {
                                        ForEach(cardsBySet[setName] ?? []) { card in
                                            NavigationLink(destination: CardDetailView(card: card)) { CardRowView(card: card) }
                                            .listRowBackground(Color.white.opacity(0.05))
                                            .swipeActions(edge: .leading) { Button("Modifier") { editingCard = card }.tint(.blue) }
                                            .swipeActions(edge: .trailing) { Button("Supprimer", role: .destructive) { modelContext.delete(card) } }
                                        }
                                    }
                                }
                            }
                            .listStyle(.sidebar).scrollContentBackground(.hidden)
                            .refreshable { await viewModel.refreshPrices(for: cards) }.task { if !cards.isEmpty { await viewModel.refreshPrices(for: cards) } }
                        }
                    } else {
                        // VUE SCELLÉ
                        if sealedProducts.isEmpty {
                            ContentUnavailableView("Aucun Scellé", systemImage: "box.truck", description: Text("Ajoutez un coffret")).foregroundStyle(.gray)
                        } else {
                            List {
                                if viewModel.isLoading { HStack { Spacer(); ProgressView().tint(.white); Spacer() }.listRowBackground(Color.clear) }
                                
                                ForEach(sealedProducts) { product in
                                    NavigationLink(destination: SealedDetailView(product: product)) { SealedRowView(product: product) }
                                    .listRowBackground(Color.white.opacity(0.05))
                                    .swipeActions(edge: .leading) { Button("Modifier") { editingProduct = product }.tint(.blue) }
                                    .swipeActions(edge: .trailing) { Button("Supprimer", role: .destructive) { modelContext.delete(product) } }
                                }
                            }
                            .listStyle(.plain).scrollContentBackground(.hidden)
                            .refreshable { await viewModel.refreshSealed(for: sealedProducts) }.task { if !sealedProducts.isEmpty { await viewModel.refreshSealed(for: sealedProducts) } }
                        }
                    }
                }
            }
            .navigationTitle(selectedTab == 0 ? "Mes Cartes" : "Objets Scellés")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { if selectedTab == 0 { showingAddCard = true } else { showingAddSealed = true } }) { Image(systemName: "plus.circle.fill").font(.title2).foregroundStyle(.indigo) }
                }
            }
            .sheet(isPresented: $showingAddCard) { ExpansionBrowserView() }
            .sheet(isPresented: $showingAddSealed) { AddSealedView() }
            .sheet(item: $editingProduct) { product in EditSealedView(product: product) }
            .sheet(item: $editingCard) { card in EditCardView(card: card) }
        }
    }
}

// ************************************************
// MARK: - ÉCRAN DASHBOARD
// ************************************************

struct DashboardView: View {
    @Query private var cards: [PokemonCard]
    @Query private var sealedProducts: [SealedProduct]
    
    // CALCULS
    var totalCardsVal: Double { cards.reduce(0) { $0 + $1.estimatedValue } }
    var totalSealedVal: Double { sealedProducts.reduce(0) { $0 + $1.totalEstimatedValue } }
    var totalValue: Double { totalCardsVal + totalSealedVal }
    
    var totalInvested: Double { cards.reduce(0) { $0 + $1.purchasePrice } + sealedProducts.reduce(0) { $0 + $1.totalPurchasePrice } }
    var profit: Double { totalValue - totalInvested }
    var profitPercent: Double { totalInvested > 0 ? (profit / totalInvested) * 100 : 0 }
    var bestCard: PokemonCard? { cards.max(by: { $0.estimatedValue < $1.estimatedValue }) }
    var totalItems: Int { cards.count + sealedProducts.count }
    
    // Simulation
    struct PortfolioValue: Identifiable { let id = UUID(); let date: Date; let value: Double }
    let mockHistory: [PortfolioValue] = { /* ... */ return [] }() // (Simulé)
    @State private var selectedTimeframe: String = "6M"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.12).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 25) {
                        // CARTE PRINCIPALE
                        VStack(alignment: .leading, spacing: 20) {
                            Text("PORTFOLIO").font(.caption).fontWeight(.bold).tracking(2).foregroundStyle(.white.opacity(0.6))
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Valeur Totale").font(.subheadline).foregroundStyle(.white.opacity(0.7))
                                Text(String(format: "%.2f €", totalValue)).font(.system(size: 42, weight: .bold, design: .rounded)).foregroundStyle(.white)
                            }
                            HStack {
                                VStack(alignment: .leading) { Text("Investi").font(.caption2).foregroundStyle(.white.opacity(0.6)); Text(String(format: "%.0f €", totalInvested)).font(.headline).foregroundStyle(.white) }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("P&L Total").font(.caption2).foregroundStyle(.white.opacity(0.6))
                                    Text(String(format: "%+.0f € (%.1f%%)", profit, profitPercent)).fontWeight(.bold).foregroundStyle(profit >= 0 ? Color.green : Color.red).padding(.horizontal, 8).padding(.vertical, 4).background(Color.black.opacity(0.3)).cornerRadius(8)
                                }
                            }
                        }.padding(25).background(LinearGradient(colors: [Color(hex: "4338ca"), Color(hex: "312e81")], startPoint: .topLeading, endPoint: .bottomTrailing)).cornerRadius(24)
                        
                        // GRID KPIs
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            KpiTile(title: "Top Carte", value: bestCard != nil ? String(format: "%.0f €", bestCard!.estimatedValue) : "---", subtitle: bestCard?.name ?? "Non défini", icon: "crown.fill", color: .yellow)
                            KpiTile(title: "Total Items", value: "\(totalItems)", subtitle: "Collection", icon: "square.stack.3d.up.fill", color: .blue)
                            KpiTile(title: "Cartes", value: String(format: "%.0f €", totalCardsVal), subtitle: "\(cards.count) cartes", icon: "menucard", color: .indigo)
                            KpiTile(title: "Scellé", value: String(format: "%.0f €", totalSealedVal), subtitle: "\(sealedProducts.count) items", icon: "box.truck.fill", color: .orange)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Analyse")
        }
    }
}

// Composant pour les carrés de stats
struct KpiTile: View {
    let title: String, value: String, subtitle: String, icon: String, color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack { Image(systemName: icon).foregroundStyle(color); Spacer() }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).foregroundStyle(.gray)
                Text(value).font(.title3).bold().foregroundStyle(.white)
                Text(subtitle).font(.caption2).foregroundStyle(.gray).lineLimit(1)
            }
        }.padding().background(Color.white.opacity(0.05)).cornerRadius(16)
    }
}

extension Color {
    init(hex: String) { let scanner = Scanner(string: hex); var rgbValue: UInt64 = 0; scanner.scanHexInt64(&rgbValue); let r = Double((rgbValue & 0xff0000) >> 16) / 255.0; let g = Double((rgbValue & 0xff00) >> 8) / 255.0; let b = Double(rgbValue & 0xff) / 255.0; self.init(red: r, green: g, blue: b) }
}

// ************************************************
// MARK: - EXPLORATEUR ET FICHES (MODALS)
// ************************************************

// --- POINT D'ENTRÉE EXPLORATEUR ---
struct ExpansionBrowserView: View {
    var body: some View { SeriesListView() }
}

// --- EXPLORATEUR : NIVEAU 1 (BLOCS) ---
struct SeriesListView: View {
    @Environment(\.dismiss) var dismiss
    @State private var sets: [TCGSet] = []
    @State private var isLoading = true
    private let service = PokemonTCGService()
    
    var groupedSets: [String: [TCGSet]] { Dictionary(grouping: sets, by: { $0.serie?.name ?? "Autres" }) }
    let seriesOrder = ["Écarlate et Violet", "Épée et Bouclier", "Soleil et Lune", "XY", "Noir et Blanc", "Autres"]
    var sortedSeriesKeys: [String] { groupedSets.keys.sorted { (a, b) -> Bool in (seriesOrder.firstIndex(of: a) ?? 999) < (seriesOrder.firstIndex(of: b) ?? 999) } }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.12).ignoresSafeArea()
                if isLoading { ProgressView("Chargement...").tint(.white) } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            NavigationLink(destination: APISearchView()) {
                                HStack { Image(systemName: "magnifyingglass"); Text("Recherche globale par nom"); Spacer() }
                                .padding().background(Color.white.opacity(0.1)).cornerRadius(12).foregroundStyle(.gray)
                            }.padding(.horizontal).padding(.top, 10)
                            
                            ForEach(sortedSeriesKeys, id: \.self) { serieName in
                                NavigationLink(destination: SetsListView(serieName: serieName, sets: groupedSets[serieName] ?? [])) {
                                    HStack { Text(serieName).font(.title3).fontWeight(.bold).foregroundStyle(.white); Spacer(); Text("\(groupedSets[serieName]?.count ?? 0) séries").font(.caption).padding(6).background(Capsule().fill(Color.indigo)).foregroundStyle(.white); Image(systemName: "chevron.right").foregroundStyle(.gray) }.padding().background(Color(red: 0.1, green: 0.1, blue: 0.2)).cornerRadius(16)
                                }.padding(.horizontal)
                            }
                        }.padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Ajouter").navigationBarTitleDisplayMode(.inline)
            .toolbar { Button("Fermer") { dismiss() } }
            .task { do { self.sets = try await service.fetchSets(); self.isLoading = false } catch { self.isLoading = false } }
        }
    }
}

// --- EXPLORATEUR : NIVEAU 2 (EXTENSIONS) ---
struct SetsListView: View {
    let serieName: String
    let sets: [TCGSet]
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.12).ignoresSafeArea()
            List {
                ForEach(sets.sorted(by: { ($0.releaseDate ?? "0000") > ($1.releaseDate ?? "0000") })) { set in
                    NavigationLink(destination: CardsGridView(set: set)) {
                        HStack(spacing: 16) {
                            ZStack { Color.white; if let logo = set.logo { AsyncImage(url: URL(string: "\(logo).png")) { i in i.resizable().scaledToFit() } placeholder: { Color.clear }.padding(4) } }.frame(width: 80, height: 45).cornerRadius(8)
                            VStack(alignment: .leading) { Text(set.name).font(.headline).foregroundStyle(.white); if let d = set.releaseDate { Text(d).font(.caption2).foregroundStyle(.gray) } }
                        }.padding(.vertical, 6)
                    }.listRowBackground(Color.clear)
                }
            }.listStyle(.plain)
        }.navigationTitle(serieName)
    }
}

// --- EXPLORATEUR : NIVEAU 3 (GRILLE DES CARTES) ---
struct CardsGridView: View {
    let set: TCGSet
    @State private var cards: [TCGCard] = []
    @State private var isLoading = true
    @State private var selectedCard: TCGCard?
    private let service = PokemonTCGService()
    let columns = [GridItem(.adaptive(minimum: 100), spacing: 15)]
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.12).ignoresSafeArea()
            if isLoading { ProgressView("Récupération...").tint(.white) } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(cards) { card in
                            Button { selectedCard = card } label: {
                                VStack {
                                    AsyncImage(url: card.imageURL) { i in i.resizable().aspectRatio(contentMode: .fit) } placeholder: { Rectangle().fill(.gray.opacity(0.2)).aspectRatio(0.7, contentMode: .fit) }.cornerRadius(8)
                                    HStack {
                                        Text(card.localId ?? "").font(.caption2).bold().foregroundStyle(.gray)
                                        Spacer()
                                        if let rare = card.rarity { Circle().fill(rare.contains("Rare") ? Color.yellow : Color.gray).frame(width: 6, height: 6) }
                                    }.padding(.horizontal, 4)
                                }
                            }
                        }
                    }.padding()
                }
            }
        }.navigationTitle(set.name)
        .task { do { self.cards = try await service.fetchCards(forSetId: set.id); self.isLoading = false } catch { isLoading = false } }
        .sheet(item: $selectedCard) { card in CardAddSheet(card: card) }
    }
}

// --- RECHERCHE GLOBALE ---
struct APISearchView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State private var searchText = ""
    @State private var searchResults: [TCGCard] = []
    @State private var isLoading = false
    private let service = PokemonTCGService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    if isLoading { ProgressView("Recherche...").tint(.white).padding(.top, 50) }
                    else if searchResults.isEmpty && !searchText.isEmpty { ContentUnavailableView("Aucun résultat", systemImage: "magnifyingglass") }
                    else { List(searchResults) { c in Button { addCard(c) } label: { Text(c.name) } }.listStyle(.plain) }
                }
            }
            .navigationTitle("Recherche directe")
            .searchable(text: $searchText, prompt: "Nom de la carte")
            .onSubmit(of: .search) { performSearch() }
        }
    }
    
    func performSearch() {
        guard !searchText.isEmpty else { return }
        isLoading = true
        Task {
            do {
                let cards = try await service.searchCards(query: searchText)
                await MainActor.run { self.searchResults = cards; self.isLoading = false }
            } catch { await MainActor.run { self.isLoading = false } }
        }
    }
    
    func addCard(_ apiCard: TCGCard) {
        let newCard = PokemonCard(
            name: apiCard.name,
            setParams: apiCard.set?.name ?? "Inconnu",
            cardNumber: apiCard.localId ?? "?",
            rarity: apiCard.rarity ?? "Commune",
            condition: .nearMint,
            purchasePrice: 0.0,
            estimatedValue: 0.0,
            imageURL: apiCard.imageURL?.absoluteString
        )
        modelContext.insert(newCard)
        dismiss()
    }
}

// --- FICHE D'AJOUT CARTE ---
struct CardAddSheet: View {
    let card: TCGCard
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var condition: CardCondition = .nearMint
    @State private var price = 0.0
    @State private var quantity = 1
    @State private var estimatedPrice: Double = 0.0
    @State private var origin = "Achetée"
    
    @State private var selectedGradingCompany: GradingCompany = .raw
    @State private var gradeInput: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack { Spacer(); AsyncImage(url: card.imageURL) { i in i.resizable().scaledToFit() } placeholder: { ProgressView() }.frame(height: 280); Spacer() }.listRowBackground(Color.clear)
                }
                
                Section("Détails") {
                    Text(card.name).font(.title3).bold()
                    Text("\(card.set?.name ?? "") • #\(card.localId ?? "")").foregroundStyle(.gray)
                }
                
                Section("Ma Carte") {
                    Picker("État", selection: $condition) { ForEach(CardCondition.allCases) { c in Text(c.rawValue).tag(c) } }
                    Stepper("Quantité: \(quantity)", value: $quantity, in: 1...100)
                }
                
                Section("Gradation (Optionnel)") {
                    Picker("Compagnie", selection: $selectedGradingCompany) { ForEach(GradingCompany.allCases) { company in Text(company.rawValue).tag(company) } }
                    .onChange(of: selectedGradingCompany) { oldValue, newValue in if newValue == .raw { gradeInput = "" } }
                    if selectedGradingCompany != .raw { TextField("Note (ex: 9.5 ou 10)", text: $gradeInput).keyboardType(.decimalPad) }
                }
                
                Section("Acquisition") {
                    Picker("Origine", selection: $origin) { Text("Achetée à l'unité").tag("Achetée"); Text("Sortie de Booster").tag("Booster") }.pickerStyle(.segmented)
                    
                    if origin == "Achetée" { TextField("Prix d'achat", value: $price, format: .currency(code: "EUR")).keyboardType(.decimalPad) }
                    else { Text("Prix d'achat : 0,00 € (Pull)").foregroundStyle(.gray) }
                    
                    HStack { Text("Cote actuelle"); Spacer(); Text(estimatedPrice > 0 ? String(format: "%.2f €", estimatedPrice) : "---").bold().foregroundStyle(.gray) }
                }
            }
            .navigationTitle("Ajouter")
            .toolbar { Button("Ajouter") { saveCard() } }
            .task { /* Mise de côté de l'API pour l'instant */ }
        }
    }
    
    func saveCard() {
        let finalPrice = (origin == "Booster") ? 0.0 : price
        let finalGradeValue = Double(gradeInput)
        let img = card.imageURL?.absoluteString
        
        for _ in 0..<quantity {
            let newCard = PokemonCard(name: card.name, setParams: card.set?.name ?? "Inconnu", series: card.set?.serie?.name ?? "Inconnu", cardNumber: card.localId ?? "?", rarity: card.rarity ?? "Commune", condition: condition, purchasePrice: finalPrice, estimatedValue: estimatedPrice > 0 ? estimatedPrice : finalPrice, imageURL: img)
            newCard.gradingCompany = selectedGradingCompany
            newCard.gradeValue = finalGradeValue
            modelContext.insert(newCard)
        }
        dismiss()
    }
}

