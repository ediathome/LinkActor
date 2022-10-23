// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - WelcomeElement
struct Trash: Codable {
    let id, userID: Int
    let url: String
    let title, welcomeDescription, icon: String
    let isPrivate: Bool
    let status: Int
    let checkDisabled: Bool
    let lists, tags: [TrashedBookmarkList]
    let createdAt, updatedAt, deletedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case url, title
        case welcomeDescription = "description"
        case icon
        case isPrivate = "is_private"
        case status
        case checkDisabled = "check_disabled"
        case lists, tags
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - List
struct TrashedBookmarkList: Codable {
    let id, userID: Int
    let name: String
    let listDescription: String?
    let isPrivate: Bool
    let createdAt, updatedAt, deletedAt: String
    let links: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case name
        case listDescription = "description"
        case isPrivate = "is_private"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case links
    }
}
