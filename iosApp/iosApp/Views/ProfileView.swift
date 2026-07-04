import SwiftUI

struct ProfileView: View {
    @State private var user: User?
    @State private var userPosts: [Post] = []
    @State private var selectedTab = 0 // 0: posts, 1: media, 2: likes
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with gradient
                    ZStack {
                        LinearGradient(
                            colors: [Color(hex: "ff4d6a"), Color(hex: "6c5ce7")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 200)
                        
                        // Logo
                        Text("sotspw")
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .position(x: UIScreen.main.bounds.width / 2, y: 40)
                    }
                    
                    // Profile info
                    VStack(spacing: 20) {
                        // Avatar with emoji
                        if let emoji = user?.emoji {
                            Text(emoji)
                                .font(.system(size: 80))
                                .frame(width: 100, height: 100)
                                .background(Color.white)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                )
                                .offset(y: -50)
                        } else {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(hex: "ff4d6a"), Color(hex: "6c5ce7")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                )
                                .overlay(
                                    Text("S")
                                        .font(.system(size: 40, weight: .black))
                                        .foregroundColor(.white)
                                )
                                offset(y: -50)
                        }
                        
                        // Username
                        if let user = user {
                            HStack(spacing: 4) {
                                Text(user.username)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                if user.verified {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            // Bio
                            if let bio = user.bio {
                                Text(bio)
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Stats
                            HStack(spacing: 30) {
                                StatItem(value: "\(userPosts.count)", label: "постов")
                                StatItem(value: "\(user.followersCount)", label: "подписчиков")
                                StatItem(value: "\(user.friends.count)", label: "подписок")
                            }
                            
                            // Action buttons
                            HStack(spacing: 12) {
                                Button(action: {}) {
                                    Text("Редактировать")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                        .cornerRadius(12)
                                }
                                
                                Button(action: {}) {
                                    Image(systemName: "square.and.arrow.up")
                                        .frame(width: 44, height: 44)
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        
                        // Tabs
                        Picker("", selection: $selectedTab) {
                            Text("Посты").tag(0)
                            Text("Медиа").tag(1)
                            Text("Лайки").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Content
                        Group {
                            if selectedTab == 0 {
                                PostsTab(posts: userPosts)
                            } else if selectedTab == 1 {
                                MediaTab(posts: userPosts)
                            } else {
                                LikesTab(posts: userPosts)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .offset(y: -30)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .onAppear {
            loadUserProfile()
        }
    }
    
    private func loadUserProfile() {
        isLoading = true
        
        APIManager.shared.fetchCurrentUser { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedUser):
                    user = fetchedUser
                    loadUserPosts(userId: fetchedUser.id)
                case .failure(let error):
                    print("Error loading user profile: \(error)")
                    isLoading = false
                }
            }
        }
    }
    
    private func loadUserPosts(userId: Int) {
        APIManager.shared.fetchPosts(userId: userId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let posts):
                    userPosts = posts
                case .failure(let error):
                    print("Error loading user posts: \(error)")
                }
            }
        }
    }
}

struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct PostsTab: View {
    let posts: [Post]
    
    var body: some View {
        VStack(spacing: 12) {
            if posts.isEmpty {
                Text("Нет постов")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            } else {
                ForEach(posts) { post in
                    PostCard(post: post)
                }
            }
        }
    }
}

struct MediaTab: View {
    let posts: [Post]
    
    var body: some View {
        let mediaPosts = posts.filter { !$0.images.isEmpty || !$0.videos.isEmpty }
        
        if mediaPosts.isEmpty {
            Text("Нет медиа")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 20)
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 2) {
                ForEach(mediaPosts) { post in
                    if let firstImage = post.images.first {
                        AsyncImage(url: URL(string: "https://sots.pw/\(firstImage)")) { image in
                            image
                                .resizable()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .aspectRatio(1, contentMode: .fill)
                    }
                }
            }
        }
    }
}

struct LikesTab: View {
    let posts: [Post]
    
    var body: some View {
        VStack(spacing: 12) {
            if posts.isEmpty {
                Text("Нет лайков")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            } else {
                ForEach(posts.filter { $0.isLiked }) { post in
                    PostCard(post: post)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
