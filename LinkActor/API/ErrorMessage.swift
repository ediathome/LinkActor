//
//  ErrorMessage.swift
//  LinkActor
//
//  Created by Martin Kolb on 02.11.22.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct ErrorMessage: Codable {
    let message: String?
    let errors: Errors?
}


// MARK: - Errors
struct Errors: Codable {
    let url: [String]?
}

