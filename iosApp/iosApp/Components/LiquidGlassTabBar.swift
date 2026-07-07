import SwiftUI

struct LiquidGlassTabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) var colorScheme
    
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
            // True iOS liquid glass effect
            ZStack {
                // Glass blur material
                Rectangle()
                    .fill(.regularMaterial)
                
                // Subtle white gradient for glass reflection
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .blendMode(.overlay)
                
                // Glass border
                Rectangle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
        )
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 16)
        .padding(.bottom, 30)
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var iconColor: Color {
        if isSelected {
            return .blue
        } else {
            return .gray
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .blue
        } else {
            return .gray
        }
    }
}

#Preview {
    ZStack {
        Color(UIColor.systemBackground)
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            LiquidGlassTabBar(selectedTab: .constant(0))
        }
    }
}
