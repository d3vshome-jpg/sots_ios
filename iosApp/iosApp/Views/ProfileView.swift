import SwiftUI

struct ProfileView: View {
    let userId: Int?
    @State private var user: User?
    @State private var userPosts: [Post] = []
    @State private var isLoading = true
    @State private var showEditProfile = false
    @State private var showCreatePost = false
    @Environment(\.colorScheme) var colorScheme
    
    var isCurrentUser: Bool {
        userId == nil
    }
    
    init(userId: Int? = nil) {
        self.userId = userId
    }
    
    var body: some View {
        ZStack {
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
                    VStack(spacing: 20) {
                        // Avatar with emoji
                        if let user = user {
                            if let emoji = user.emoji {
                                Text(emoji)
                                    .font(.system(size: 60))
                                    .frame(width: 100, height: 100)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 4)
                                    )
                            } else {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color(hex: "ff4d6a"), Color(hex: "6c5ce7")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Text(String(user.username.prefix(1)).uppercased())
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 4)
                                    )
                            }
                        }
                        
                        // Username
                        if let user = user {
                            HStack(spacing: 4) {
                                Text(user.username)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                if user.isVerified {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                            }
                            
                            // Bio
                            if let bio = user.bio {
                                Text(bio)
                                    .font(.body)
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Stats
                            HStack(spacing: 30) {
                                StatItem(value: "\(userPosts.count)", label: "постов", colorScheme: colorScheme)
                                StatItem(value: "\(user.followersCount)", label: "подписчиков", colorScheme: colorScheme)
                                StatItem(value: "\(user.friends.count)", label: "подписок", colorScheme: colorScheme)
                            }
                            
                            // Action buttons
                            HStack(spacing: 12) {
                                if isCurrentUser {
                                    Button(action: { showEditProfile = true }) {
                                        HStack {
                                            Text("Редактировать")
                                                .fontWeight(.semibold)
                                            Image(systemName: "gearshape")
                                                .font(.caption)
                                        }
                                        .foregroundColor(Color(hex: "FF4D6A"))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                    }
                                } else {
                                    Button(action: {}) {
                                        Text("Добавить в друзья")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color(hex: "FF4D6A"))
                                            .cornerRadius(12)
                                    }
                                }
                                
                                if isCurrentUser {
                                    Button(action: { showCreatePost = true }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(Color(hex: "FF4D6A"))
                                            .frame(width: 44, height: 44)
                                            .background(Color.white)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        
                        // User posts
                        VStack(spacing: 12) {
                            if userPosts.isEmpty {
                                Text("Нет постов")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.top, 20)
                            } else {
                                ForEach(userPosts) { post in
                                    PostCard(post: post)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(UIColor.systemGroupedBackground))
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
        }
        .onAppear {
            loadUserProfile()
        }
        .sheet(isPresented: $showEditProfile) {
            if let user = user {
                EditProfileView(user: Binding(
                    get: { user },
                    set: { newValue in
                        self.user = newValue
                    }
                ))
            }
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostTypeSelection()
        }
    }
    
    private func loadUserProfile() {
        isLoading = true
        print("Loading user profile... userId: \(String(describing: userId))")
        
        if let userId = userId {
            APIManager.shared.fetchUserProfile(userId: userId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedUser):
                        print("User loaded: \(fetchedUser)")
                        user = fetchedUser
                        loadUserPosts(userId: fetchedUser.id)
                    case .failure(let error):
                        print("Error loading user profile: \(error)")
                        isLoading = false
                    }
                }
            }
        } else {
            APIManager.shared.fetchCurrentUser { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedUser):
                        print("User loaded: \(fetchedUser)")
                        user = fetchedUser
                        loadUserPosts(userId: fetchedUser.id)
                    case .failure(let error):
                        print("Error loading user profile: \(error)")
                        isLoading = false
                    }
                }
            }
        }
    }
    
    private func loadUserPosts(userId: Int) {
        print("Loading posts for user \(userId)...")
        APIManager.shared.fetchPosts(userId: userId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let posts):
                    print("Posts loaded: \(posts.count)")
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
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            Text(label)
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))
        }
    }
}

#Preview {
    ProfileView()
}
