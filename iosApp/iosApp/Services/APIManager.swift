import Foundation

class APIManager {
    static let shared = APIManager()
    
    private let baseURL = "https://sots.pw/api"
    
    // Данные подключения к базе (для справки - на сервере)
    /*
     DB_HOST=localhost
     DB_NAME=cb868718_glavnaya
     DB_USER=cb868718_glavnaya
     DB_PASS=Oleg5225!
     DB_CHARSET=utf8mb4
     */
    
    private init() {}
    
    // MARK: - Posts
    
    func fetchPosts(limit: Int = 20, before: Int? = nil, userId: Int? = nil, completion: @escaping (Result<[Post], Error>) -> Void) {
        var endpoint = "\(baseURL)/posts/posts.php?limit=\(limit)"
        if let before = before {
            endpoint += "&before=\(before)"
        }
        if let userId = userId {
            endpoint += "&user_id=\(userId)"
        }
        
        print("Fetching posts: \(endpoint)")
        guard let url = URL(string: endpoint) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Posts fetch error: \(error)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Posts HTTP status: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("Posts: No data")
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Posts response: \(jsonString)")
            }
            
            do {
                let posts = try JSONDecoder().decode([Post].self, from: data)
                print("Posts decoded: \(posts.count) posts")
                completion(.success(posts))
            } catch {
                print("Posts decode error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func createPost(caption: String, images: [String] = [], videos: [String] = [], audio: [String] = [], artist: String? = nil, title: String? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let endpoint = "\(baseURL)/posts/posts.php"
        guard let url = URL(string: endpoint) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "caption": caption,
            "images": images,
            "videos": videos,
            "audio": audio,
            "artist": artist ?? "",
            "title": title ?? ""
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                completion(.success(json ?? [:]))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func likePost(postId: Int, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let endpoint = "\(baseURL)/posts/like.php"
        guard let url = URL(string: endpoint) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["post_id": postId]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                completion(.success(json ?? [:]))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Search
    
    func search(query: String, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        let endpoint = "\(baseURL)/users/search.php?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        print("Search endpoint: \(endpoint)")
        guard let url = URL(string: endpoint) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Search error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("Search: No data")
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Search response: \(jsonString)")
            }
            
            do {
                let response = try JSONDecoder().decode(SearchResponse.self, from: data)
                print("Search decoded: users=\(response.users.count), posts=\(response.posts.count), hashtags=\(response.hashtags.count)")
                completion(.success(response))
            } catch {
                print("Search decode error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Notifications
    
    func fetchNotifications(completion: @escaping (Result<[NotificationItem], Error>) -> Void) {
        let endpoint = "\(baseURL)/notifications/get_notifications.php"
        guard let url = URL(string: endpoint) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let notifications = try JSONDecoder().decode([NotificationItem].self, from: data)
                completion(.success(notifications))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - User Profile
    
    func fetchCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {
        let endpoint = "\(baseURL)/users/users.php"
        print("Fetching current user: \(endpoint)")
        guard let url = URL(string: endpoint) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Current user fetch error: \(error)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Current user HTTP status: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("Current user: No data")
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Current user response: \(jsonString)")
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                print("Current user decoded: \(user.username)")
                completion(.success(user))
            } catch {
                print("Current user decode error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchUserProfile(userId: Int, completion: @escaping (Result<User, Error>) -> Void) {
        let endpoint = "\(baseURL)/users/users.php?id=\(userId)"
        print("Fetching user profile: \(endpoint)")
        guard let url = URL(string: endpoint) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("User profile fetch error: \(error)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("User profile HTTP status: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("User profile: No data")
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("User profile response: \(jsonString)")
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                print("User profile decoded: \(user.username)")
                completion(.success(user))
            } catch {
                print("User profile decode error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Auth
    
    func login(username: String, password: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let endpoint = "\(baseURL)/auth/login.php"
        guard let url = URL(string: endpoint) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                completion(.success(json ?? [:]))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func register(username: String, password: String, emoji: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let endpoint = "\(baseURL)/auth/register.php"
        guard let url = URL(string: endpoint) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": username,
            "password": password,
            "emoji": emoji
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                completion(.success(json ?? [:]))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
