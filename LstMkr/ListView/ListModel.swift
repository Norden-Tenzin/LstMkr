//
//  ListModel.swift
//  LstMkr
//
//  Created by Tenzin Norden on 10/2/23.
//

import Foundation
import SwiftData

@Model
class ListModel {
    @Attribute(.unique)
    let id: UUID
    var pos: Int
//    @Relationship(deleteRule: .cascade, inverse: \ItemModel.list)
    @Relationship(deleteRule: .cascade)
    var items: [ItemModel] = [ItemModel]()
    var type: String
    var title: String
    var body: String
    let lastEdited: Date
    var lastEditedTimeAgo: String {
        let now = Date()
        let componets = Calendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year], from: lastEdited, to: now)
        let timeUnits: [(value: Int?, unit: String)] = [
            (value: componets.year, unit: "year"),
            (value: componets.month, unit: "month"),
            (value: componets.day, unit: "day"),
            (value: componets.hour, unit: "hour"),
            (value: componets.minute, unit: "minute"),
            (value: componets.second, unit: "second"),
        ]

        for timeUnit in timeUnits {
            if let value = timeUnit.value, value > 0 {
                return "\(value) \(timeUnit.unit)\(value == 1 ? "" : "s") ago"
            }
        }
        return "just now"
    }

    init(title: String = "", body: String = "", items: [ItemModel] = [], pos: Int, type: String = "check") {
        self.id = UUID()
        self.pos = pos
        self.type = type
        self.title = title
        self.body = body
        self.items = items
        self.lastEdited = Date()
    }
}

extension ListModel: Hashable {
    static func == (lhs: ListModel, rhs: ListModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Model
class ItemModel {
    @Attribute(.unique)
    let id: UUID = UUID()
    var pos: Int
    @Relationship(inverse: \ListModel.items)
    var list: ListModel?
    var text: String = ""
    var isChecked: Bool = false
    let createdAt: Date = Date()
    var lastEdited: Date = Date()

    init(pos: Int) {
        self.pos = pos
    }

    func toString() -> String {
        return "id: \(id), text: \(text), pos: \(pos)"
    }
}

extension ItemModel: Hashable {
    static func == (lhs: ItemModel, rhs: ItemModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//class ItemModel: Codable, Hashable {
//    @Attribute(.unique)
//    let id: UUID = UUID()
//    var pos: Int
//    var text: String = ""
//    var isChecked: Bool = false
//    let createdAt: Date = Date()
//    var lastEdited: Date = Date()
//
//    init(pos: Int) {
//        self.pos = pos
//    }
//
//    func toString() -> String {
//        return "id: \(id), text: \(text), pos: \(pos)"
//    }
//}
