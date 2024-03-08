//
//  Card.swift
//  CodingInterviewSampleProject2022
//
//  Created by Sandeep on 07/03/24.
//

import Foundation

enum CardType: Codable, Hashable, Comparable {
    case all
    case custom(String)

    var name: String {
        switch self {
        case .all:
            return "All"
        case .custom(let string):
            return string.capitalized
        }
    }

    static func == (lhs: CardType, rhs: CardType) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all):
            return true
        case let (.custom(value1), .custom(value2)):
            return value1 == value2
        default:
            return false
        }
    }
    static func < (lhs: CardType, rhs: CardType) -> Bool {
        // Your implementation here
        switch (lhs, rhs) {
        case (.all, .all):
            return false
        case let (.custom(value1), .custom(value2)):
            return value1 < value2
        default:
            return false
        }
    }
    static func > (lhs: CardType, rhs: CardType) -> Bool {
        // Your implementation here
        switch (lhs, rhs) {
        case (.all, .all):
            return false
        case let (.custom(value1), .custom(value2)):
            return value1 > value2
        default:
            return false
        }
    }
    func hash(into hasher: inout Hasher) {
        switch self {
        case .all:
            hasher.combine(0)
        case .custom(let value):
            hasher.combine(value)
        }
    }

    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            let decodedString = try container.decode(String.self)
            self = .custom(decodedString)
        } catch {
            throw error
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .all:
            try container.encode("all")
        case .custom(let value):
            try container.encode(value)
        }
    }
}

struct Card: Codable, Hashable {
    let id: String
    let nameEnglish: String
    let nameJapanese: String
    let abilityEnglish: String
    let abilityJapanese: String
    let types: [CardType]
    let imageUrls: [String]

    var imageURL: URL? {
        guard let firstUrl = imageUrls.first else {
            return nil
        }
       return URL(string: firstUrl)
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(nameEnglish)
        hasher.combine(nameJapanese)
    }
}
