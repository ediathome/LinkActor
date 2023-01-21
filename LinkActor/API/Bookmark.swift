// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct BookmarkPage: Codable {
    let currentPage: Int
    let data: [Bookmark]
    let firstPageURL: String
    let from, lastPage: Int
    let lastPageURL: String
    let links: [Link]
    let nextPageURL: String?
    let path: String
    let perPage: String
    let prevPageURL: String?
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
struct Bookmark: Codable, Identifiable, Equatable {
    let id, userID: Int
    let url: String
    let title, description, icon: String?
    let thumbnail: String?
    let isPrivate: Bool
    let status: Int
    let checkDisabled: Bool
    let createdAt, updatedAt: String?
    let deletedAt: String?
    // let pivot: 
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case url, title
        case description = "description"
        case icon, thumbnail
        case isPrivate = "is_private"
        case status
        case checkDisabled = "check_disabled"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    func dateFrom(isoDate: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"

        let date = dateFormatter.date(from:isoDate) ?? nil

        if (date != nil) {
            let returnString = date!.formatted()
            return returnString
        }
        return nil
    }
}

// MARK: - Link
struct Link: Codable {
    let url: String?
    let label: String
    let active: Bool
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 10
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
