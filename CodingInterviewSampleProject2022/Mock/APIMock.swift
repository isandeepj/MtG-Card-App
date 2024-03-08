//
//  APIMock.swift
//  CodingInterviewSampleProject2022
//
// The data is exported from MTGJSON (https://mtgjson.com/license/)

import Foundation

protocol API {
    /**
     This will return JSON object encoded by utf8
     
        Returns a json string which includes array of cards object. Each card object has...
        - id: String : unique id for each card
        - nameEnglish: String : card name in English
        - nameJapanese: String : card name in Japanese
        - abilityEnglish: String : card ability in English
        - abilityJapanese: String : card ability in Japanese
        - types: List[String]: the types of the card. One card will have more than one type but at lease it has one type.
        - imageUrls: List[String] : card image urls. One card will have at lease one image url. You can just use the first url to preview the card
     */
    func getCards() async throws -> String
}

enum APIError: Error {
    case cardDoesNotExist
    case networkError
}

class APIImpl {
    static let shared = APIImpl()

    private var cards: String = "[]"
    
    init() {
        self.cards = getAllCardsRawData()
    }
    
    private func getAllCardsRawData() -> String {
        guard let fileURL = Bundle.main.url(forResource: "mtg_card_subset", withExtension: "json"),
              let cardString = try? String(contentsOf: fileURL, encoding: .utf8) else {
            fatalError("Failed to read initial data")
        }
        return cardString
    }
}


extension APIImpl: API {
    func sleep(seconds: Int) async throws {
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
    }
    
    // use below function to get all card data.
    func getCards() async throws -> String {
        try await sleep(seconds: 1)
        return cards
    }
}
