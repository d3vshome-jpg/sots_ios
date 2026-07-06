import Foundation

struct Post: Identifiable, Codable {
    let id: Int
    let userId: Int
    let username: String
    let emoji: String?
    let images: [String]
    let videos: [String]
    let audio: [String]
    let artist: String?
    let title: String?
    let caption: String
    let likes: [Int]
    let createdAt: String
    let repostOf: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case username
        case emoji
        case images
        case videos
        case audio
        case artist
        case title
        case caption
        case likes
        case createdAt = "created_at"
        case repostOf = "repost_of"
    }
    
    var isLiked: Bool {
        // TODO: Проверить, содержит ли likes ID текущего пользователя
        return false
    }
    
    var likeCount: Int {
        likes.count
    }
}

struct User: Identifiable, Codable {
    let id: Int
    let username: String
    let emoji: String?
    let bio: String?
    let friends: [Int]
    let verified: Int
    let isAdmin: Bool?
    let pin: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case emoji
        case bio
        case friends
        case verified
        case isAdmin = "is_admin"
        case pin
    }
    
    var isVerified: Bool {
        verified == 1
    }
    
    var followersCount: Int {
        friends.count
    }
}

struct NotificationItem: Identifiable, Codable {
    let id: Int
    let type: String
    let fromUserId: Int
    let fromUsername: String
    let fromEmoji: String
    let objectId: Int?
    let read: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case fromUserId = "from_user_id"
        case fromUsername = "from_username"
        case fromEmoji = "from_emoji"
        case objectId = "object_id"
        case read
        case createdAt = "created_at"
    }
}

struct SearchResponse: Codable {
    let users: [User]
    let posts: [Post]
    let hashtags: [Hashtag]
}

struct Hashtag: Identifiable, Codable {
    let name: String
    let postCount: Int
    
    var id: String {
        name
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case postCount = "post_count"
    }
}
