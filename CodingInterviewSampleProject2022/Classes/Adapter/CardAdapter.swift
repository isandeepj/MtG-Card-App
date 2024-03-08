//
//  CardAdapter.swift
//  CodingInterviewSampleProject2022
//
//  Created by Sandeep on 07/03/24.
//

import Foundation


// Custom error type for CardAdapter
enum CardAdapterError: Error {
    case apiError(APIError)
    case dataParsingError
}

struct CardAdapter {
    // Asynchronously fetches card data from the API and parses it
    static func getCards() async throws -> [Card] {
        do {
            // Fetch raw JSON data from the API
            let jsonString = try await APIImpl.shared.getCards()
            // Parse the raw JSON data into an array of Card objects
            let cards = try parseCardData(jsonString: jsonString)
            return cards
        } catch let apiError as APIError {
            // Handle API-related errors
            throw CardAdapterError.apiError(apiError)
        } catch {
            // Handle other errors, such as data parsing errors
            throw CardAdapterError.dataParsingError
        }
    }

    // MARK: - Private Methods

    // Parses the provided JSON string into an array of Card objects
   private static func parseCardData(jsonString: String) throws -> [Card] {
       // Convert the JSON string to Data
        guard let jsonData = jsonString.data(using: .utf8) else {
            // If conversion fails, throw a dataParsingError
            throw CardAdapterError.dataParsingError
        }

        let decoder = JSONDecoder()
        do {
            // Attempt to decode the JSON data into an array of Card objects
            let cards = try decoder.decode([Card].self, from: jsonData)
            return cards
        } catch {
            // If decoding fails, throw a dataParsingError
            throw CardAdapterError.dataParsingError
        }
    }
}
