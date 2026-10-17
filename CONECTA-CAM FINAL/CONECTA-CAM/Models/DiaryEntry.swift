//
//  DiaryEntry.swift
//  Conecta CAM
//

import Foundation

struct DiaryEntry: Identifiable, Codable, Hashable {
    var id = UUID()
    var dayNumber: Int
    var date: Date
    var text: String
}
