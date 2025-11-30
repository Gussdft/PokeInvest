//
//  ScannerView.swift
//  PokeInvest
//
//  Created by Augustin Dufetelle on 30/11/2025.
//


import SwiftUI
import VisionKit

struct ScannerView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
                
                Text("Scanner (En cours de développement)")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                
                Text("Utilisera VisionKit pour détecter les cartes.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .padding()
            }
        }
    }
}

