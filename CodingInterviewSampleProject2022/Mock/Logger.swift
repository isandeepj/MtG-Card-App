//
//  Logger.swift
//  CodingInterviewSampleProject2022
//
//

import Foundation

class Logger {
    static let shared = Logger()
    
    func error(_ error: Error) {
        print(error)
    }
    func error(_ message: String) {
        print(message)
    }
}
