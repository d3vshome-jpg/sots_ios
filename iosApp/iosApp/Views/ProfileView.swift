import SwiftUI

struct ProfileView: View {
    let userId: Int?
    @State private var user: User?
    @State private var userPosts: [Post] = []
    @State private var isLoading = true
    
    init(userId: Int? = nil) {
        self.userId = userId
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FF4D6A"), Color(hex: "FF8FA3")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
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
                        // Avatar with logo
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                            )
                        
                        // Username
                        if let user = user {
                            HStack(spacing: 4) {
                                Text(user.username)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                if user.verified {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            
                            // Bio
                            if let bio = user.bio {
                                Text(bio)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
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
                                        .foregroundColor(Color(hex: "FF4D6A"))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                }
                                
                                Button(action: {}) {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(Color(hex: "FF4D6A"))
                                        .frame(width: 44, height: 44)
                                        .background(Color.white)
                                        .cornerRadius(12)
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
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

#Preview {
    ProfileView()
}
