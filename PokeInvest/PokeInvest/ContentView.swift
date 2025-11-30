import SwiftUI

struct ContentView: View {
    init() {
        // Configuration de la TabBar pour l'effet Glassmorphism
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor(white: 0, alpha: 0.1)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            // Ces vues doivent exister dans le dossier Views/
            CollectionListView()
                .tabItem {
                    Label("Collection", systemImage: "rectangle.stack.fill")
                }
            
            DashboardView()
                .tabItem {
                    Label("Analyse", systemImage: "chart.xyaxis.line")
                }
            
            ScannerView()
                .tabItem {
                    Label("Scanner", systemImage: "camera.viewfinder")
                }
        }
        .tint(.indigo)
    }
}

