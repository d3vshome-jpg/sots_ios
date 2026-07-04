import SwiftUI

struct LiquidGlassTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(icon: "house.fill", label: "Лента", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabBarButton(icon: "magnifyingglass", label: "Поиск", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            TabBarButton(icon: "bell.fill", label: "Уведомления", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            
            TabBarButton(icon: "person.fill", label: "Профиль", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            // Liquid glass effect
            ZStack {
                // Background blur
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.white.opacity(0.4),
                                Color.blue.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blur(radius: 1)
                
                // Glass reflection
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.clear,
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .blendMode(.overlay)
                
                // Subtle border
                Rectangle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 16)
        .padding(.bottom, 30) // Safe area for iPhone home indicator
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color(hex: "ff4d6a") : .gray)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? Color(hex: "ff4d6a") : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            LiquidGlassTabBar(selectedTab: .constant(0))
        }
    }
}
