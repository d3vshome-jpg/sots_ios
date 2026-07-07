import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: SearchResponse?
    @State private var isLoading = false
    @State private var searchDebounceTask: Task<Void, Never>?
    
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
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBar(text: $searchText, onSearch: performSearch)
                        .padding()
                    
                    // Results
                    ScrollView {
                        if isLoading {
                            ProgressView("Поиск...")
                                .padding(.top, 50)
                        } else if let results = searchResults {
                            VStack(spacing: 12) {
                                // Users
                                if !results.users.isEmpty {
                                    Text("Пользователи")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                    
                                    ForEach(results.users) { user in
                                        UserRow(user: user)
                                    }
                                }
                                
                                // Posts
                                if !results.posts.isEmpty {
                                    Text("Посты")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                    
                                    ForEach(results.posts) { post in
                                        PostCard(post: post)
                                    }
                                }
                                
                                // Hashtags
                                if !results.hashtags.isEmpty {
                                    Text("Хештеги")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                    
                                    ForEach(results.hashtags) { hashtag in
                                        HashtagRow(hashtag: hashtag)
                                    }
                                }
                                
                                if results.users.isEmpty && results.posts.isEmpty && results.hashtags.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray)
                                        Text("Ничего не найдено")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.top, 50)
                                }
                            }
                            .padding()
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.5))
                                Text("Поиск по хештегам, пользователям и постам")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(.top, 50)
                        }
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
        }
        .onChange(of: searchText) { _, newValue in
            if newValue.isEmpty {
                searchResults = nil
                searchDebounceTask?.cancel()
            } else {
                searchDebounceTask?.cancel()
                searchDebounceTask = Task {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec debounce
                    if !Task.isCancelled {
                        await performSearch()
                    }
                }
            }
        }
    }
    
    @MainActor
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        isLoading = true
        
        APIManager.shared.search(query: searchText) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    searchResults = response
                    print("Search results: \(response)")
                case .failure(let error):
                    print("Error searching: \(error)")
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearch: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Поиск...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    onSearch()
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

struct UserRow: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            if let emoji = user.emoji {
                Text(emoji)
                    .font(.system(size: 40))
                    .frame(width: 50, height: 50)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(hex: "ff4d6a"), Color(hex: "6c5ce7")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(user.username.prefix(1)).uppercased())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(user.username)
                        .font(.headline)
                    if user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                if let bio = user.bio {
                    Text(bio)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Text("\(user.followersCount) подписчиков")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("Подписаться")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "ff4d6a"))
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct HashtagRow: View {
    let hashtag: Hashtag
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "number")
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("#\(hashtag.name)")
                    .font(.headline)
                    .foregroundColor(.blue)
                Text("\(hashtag.postCount) постов")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

#Preview {
    SearchView()
}
