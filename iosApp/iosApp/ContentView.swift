import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var selectedTab = 0
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        if isAuthenticated {
            MainTabView(selectedTab: $selectedTab)
                .preferredColorScheme(themeManager.colorScheme)
        } else {
            AuthView(isAuthenticated: $isAuthenticated)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Main content based on selected tab
                Group {
                    switch selectedTab {
                    case 0:
                        FeedView()
                    case 1:
                        SearchView()
                    case 2:
                        NotificationsView()
                    case 3:
                        ProfileView()
                    default:
                        FeedView()
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                
                // Liquid Glass Tab Bar
                LiquidGlassTabBar(selectedTab: $selectedTab)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}