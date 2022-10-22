//
//  StringExtension.swift
//  LinkActor
//
//  Created by Martin Kolb on 22.10.22.
//

import Foundation

extension String {
    func matches (pattern: String) -> Bool {
        let range = NSRange(location: 0, length: self.utf16.count)
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}
