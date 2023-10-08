//
//  ListViewModel.swift
//  LstMkr
//
//  Created by Tenzin Norden on 10/2/23.
//

import Foundation
import SwiftUI
import SwiftData
//
//extension ListView {
//
//
//
//}

@Observable
class ListViewModel {
    var modelContext: ModelContext
    var lists: [ListModel] = [ListModel]()
    var editMode: EditMode = EditMode.inactive

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchData()
    }

    func fetchData() {
        do {
//            @Query var res: [ListModel]
            let descriptor = FetchDescriptor<ListModel>(sortBy: [SortDescriptor(\.pos, order: .forward)])
            lists = try modelContext.fetch(descriptor)

//            lists = res.sorted(by: { lhs, rhs in
//                lhs.pos < rhs.pos
//            })
        } catch {
            print("Fetch failed")
        }
    }

    func addList(appState: AppState, type: String) -> ListModel {
        func getLastPos() -> Int {
            var descriptor = FetchDescriptor<ListModel>(sortBy: [SortDescriptor(\.pos, order: .reverse)])
            descriptor.fetchLimit = 1
            do {
                let result = try modelContext.fetch(descriptor)
                return result.first?.pos ?? 0
            } catch {
                return 0
            }
        }
        let newList = ListModel(pos: getLastPos() + 1, type: type)
        withAnimation {
            modelContext.insert(newList)
            fetchData()
        }
        return newList
    }

    func deleteLists() {
        do {
            withAnimation {
                for lst in lists {
                    for item in lst.items {
                        modelContext.delete(item)
                    }
                    modelContext.delete(lst)
                }
            }
            try modelContext.save()
        } catch {
            print(error)
        }
    }

    func deleteItem(_ item: ListModel) {
        lists = lists.filter({ lst in
            return lst != item
        })
        modelContext.delete(item)
        for index in stride(from: lists.count, through: 1, by: -1) {
            lists[index - 1].pos = index
        }
        do {
            try modelContext.save()
        } catch {
            print(error)
        }
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        lists.move(fromOffsets: source, toOffset: destination)
        for index in stride(from: lists.count, through: 1, by: -1) {
            lists[index - 1].pos = index
        }
        do {
            try modelContext.save()
        } catch {
            print(error)
        }
    }
}
