import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var selectedTab = 0
    
    var body: some View {
        if isAuthenticated {
            MainTabView(selectedTab: $selectedTab)
        } else {
            AuthView(isAuthenticated: $isAuthenticated)
        }
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content based on selected tab
            Group {
                switch selectedTab {
                case 0:
                    NavigationView {
                        FeedView()
                    }
                case 1:
                    SearchView()
                case 2:
                    NotificationsView()
                case 3:
                    ProfileView()
                default:
                    NavigationView {
                        FeedView()
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            
            // Liquid Glass Tab Bar
            LiquidGlassTabBar(selectedTab: $selectedTab)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}