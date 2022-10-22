// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let listPage = try? newJSONDecoder().decode(ListPage.self, from: jsonData)

import Foundation

// MARK: - ListPage
struct ListPage: Codable {
    let currentPage: Int
    let data: [BookmarkList]
    let firstPageURL: String
    let from, lastPage: Int
    let lastPageURL: String
    let links: [Link]
    let nextPageURL: JSONNull?
    let path: String
    let perPage: String
    let prevPageURL: JSONNull?
    let to, total: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
        case firstPageURL = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageURL = "last_page_url"
        case links
        case nextPageURL = "next_page_url"
        case path
        case perPage = "per_page"
        case prevPageURL = "prev_page_url"
        case to, total
    }
}

// MARK: - Datum
struct BookmarkList: Codable, Identifiable {
    let id, userID: Int
    let name, datumDescription: String?
    let isPrivate: Bool
    let createdAt, updatedAt: String
    let deletedAt: JSONNull?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case name
        case datumDescription = "description"
        case isPrivate = "is_private"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}
