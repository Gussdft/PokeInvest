//
//  CardDetailView.swift
//  PokeInvest
//
//  Created by Augustin Dufetelle on 30/11/2025.
//

import SwiftUI
import SwiftData

// MARK: - Détail d'une carte
struct CardDetailView: View {
    let card: PokemonCard
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text(card.name)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                
                if let urlString = card.imageURLString,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(height: 260)
                }
                
                VStack(spacing: 8) {
                    Text("Extension : \(card.setParams)")
                        .foregroundStyle(.gray)
                    Text("Rareté : \(card.rarity)")
                        .foregroundStyle(.gray)
                    Text("Numéro : #\(card.cardNumber)")
                        .foregroundStyle(.gray)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Détail d'un produit scellé
struct SealedDetailView: View {
    let product: SealedProduct
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text(product.name)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                
                if let urlString = product.imageURLString,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(height: 220)
                }
                
                VStack(spacing: 8) {
                    Text("Quantité : \(product.quantity)")
                        .foregroundStyle(.gray)
                    Text(String(format: "Valeur estimée : %.0f €", product.totalEstimatedValue))
                        .foregroundStyle(.gray)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Ajout / édition (placeholders simples)
struct AddSealedView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Écran d’ajout de produit scellé (à implémenter)")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding()
        }
    }
}

struct EditSealedView: View {
    let product: SealedProduct
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Édition de \(product.name) (à implémenter)")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding()
        }
    }
}

struct EditCardView: View {
    let card: PokemonCard
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Édition de \(card.name) (à implémenter)")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding()
        }
    }
}
