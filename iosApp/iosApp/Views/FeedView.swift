import SwiftUI

struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Загрузка...")
                } else if posts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Нет постов")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(posts) { post in
                                PostCard(post: post)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Лента")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadPosts()
        }
    }
    
    private func loadPosts() {
        APIManager.shared.fetchPosts { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedPosts):
                    posts = fetchedPosts
                case .failure(let error):
                    print("Error loading posts: \(error)")
                }
            }
        }
    }
}

struct PostCard: View {
    let post: Post
    @State private var isLiked: Bool
    
    init(post: Post) {
        self.post = post
        self._isLiked = State(initialValue: post.isLiked)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Avatar with emoji or gradient
                if let emoji = post.emoji {
                    Text(emoji)
                        .font(.system(size: 32))
                        .frame(width: 40, height: 40)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "ff4d6a"), Color(hex: "6c5ce7")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(post.username.prefix(1)).uppercased())
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username)
                        .font(.headline)
                    Text(timeAgo(post.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            // Content
            if !post.caption.isEmpty {
                Text(post.caption)
                    .font(.body)
            }
            
            // Music card if audio exists
            if !post.audio.isEmpty, let artist = post.artist, let title = post.title {
                MusicCard(artist: artist, title: title)
            }
            
            // Images
            if !post.images.isEmpty {
                TabView {
                    ForEach(post.images, id: \.self) { imageURL in
                        AsyncImage(url: URL(string: "https://sots.pw/\(imageURL)")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        }
                    }
                }
                .frame(height: 200)
                .tabViewStyle(PageTabViewStyle())
                .cornerRadius(12)
            }
            
            // Videos
            if !post.videos.isEmpty {
                ForEach(post.videos, id: \.self) { videoURL in
                    VideoPlayerView(url: "https://sots.pw/\(videoURL)")
                        .frame(height: 200)
                        .cornerRadius(12)
                }
            }
            
            // Actions
            HStack(spacing: 24) {
                Button(action: {
                    isLiked.toggle()
                    APIManager.shared.likePost(postId: post.id) { result in
                        if case .failure(let error) = result {
                            print("Error liking post: \(error)")
                        }
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                        Text("\(post.likeCount)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: {}) {
                    Image(systemName: "arrow.turn.up.right")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
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

struct MusicCard: View {
    let artist: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(LinearGradient(
                    colors: [Color(hex: "6c5ce7"), Color(hex: "a29bfe")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "music.note")
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(artist)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color(hex: "ff4d6a"))
            }
        }
        .padding()
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct VideoPlayerView: View {
    let url: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black)
                .overlay(
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                )
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    FeedView()
}
