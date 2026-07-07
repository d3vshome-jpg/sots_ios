import SwiftUI

struct NotificationsView: View {
    @State private var notifications: [NotificationItem] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with logo
            HStack {
                Spacer()
                Image("sotspw")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                Spacer()
            }
            .padding(.top, 50)
            .padding(.bottom, 10)
            
            // Content
            ScrollView {
                if isLoading {
                    ProgressView("Загрузка...")
                        .padding(.top, 50)
                } else if notifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.6))
                        Text("Нет уведомлений")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, 50)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(notifications) { notification in
                            NotificationRow(notification: notification)
                        }
                    }
                    .padding()
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(20, corners: [.topLeft, .topRight])
        }
        .onAppear {
            loadNotifications()
        }
    }
    
    private func loadNotifications() {
        APIManager.shared.fetchNotifications { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedNotifications):
                    notifications = fetchedNotifications
                case .failure(let error):
                    print("Error loading notifications: \(error)")
                }
            }
        }
    }
}

struct NotificationRow: View {
    let notification: NotificationItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar with emoji
            Text(notification.fromEmoji)
                .font(.system(size: 32))
                .frame(width: 44, height: 44)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(notification.fromUsername)
                        .font(.headline)
                    Image(systemName: iconForType(notification.type))
                        .font(.caption)
                        .foregroundColor(colorForType(notification.type))
                    Text(contentForType(notification.type))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text(timeAgo(notification.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if !notification.read {
                Circle()
                    .fill(Color(hex: "ff4d6a"))
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
        .background(notification.read ? Color.clear : Color(hex: "ff4d6a").opacity(0.05))
        .cornerRadius(12)
    }
    
    private func iconForType(_ type: String) -> String {
        switch type.lowercased() {
        case "like": return "heart.fill"
        case "comment": return "bubble.left.fill"
        case "follow": return "person.badge.plus"
        case "mention": return "at"
        default: return "bell.fill"
        }
    }
    
    private func colorForType(_ type: String) -> Color {
        switch type.lowercased() {
        case "like": return .red
        case "comment": return .blue
        case "follow": return .green
        case "mention": return .purple
        default: return .gray
        }
    }
    
    private func contentForType(_ type: String) -> String {
        switch type.lowercased() {
        case "like": return "понравился ваш пост"
        case "comment": return "прокомментировал"
        case "follow": return "подписался на вас"
        case "mention": return "упомянул вас"
        default: return ""
        }
    }
    
    private func timeAgo(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return "" }
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "только что" }
        if interval < 3600 { return "\(Int(interval/60)) мин назад" }
        if interval < 86400 { return "\(Int(interval/3600)) ч назад" }
        return "\(Int(interval/86400)) д назад"
    }
}

#Preview {
    NotificationsView()
}
