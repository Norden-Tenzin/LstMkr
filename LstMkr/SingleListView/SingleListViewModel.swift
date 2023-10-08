//
//  SingleListViewModel.swift
//  LstMkr
//
//  Created by Tenzin Norden on 10/4/23.
//

import SwiftUI
import SwiftData
import AVFoundation

@Observable
class SingleListViewModel {
    var modelContext: ModelContext
    var list: ListModel
    var items: [ItemModel] = [ItemModel]()
    var editMode: EditMode = EditMode.inactive

    init(modelContext: ModelContext, list: ListModel) {
        self.list = list
        self.modelContext = modelContext
        fetchData(list: list)
    }

    func fetchData(list: ListModel) {
        do {
            let descriptor = FetchDescriptor<ItemModel>(sortBy: [SortDescriptor(\.pos, order: .forward)])
            items = try modelContext.fetch(descriptor).filter({ item in
                item.list == list
            })
        } catch {
            print("Fetch failed")
        }
    }

    func addItem(pos: Int = -1) {
        print(pos)
        if pos == -1 {
            func getLastPos() -> Int {
                let descriptor = FetchDescriptor<ItemModel>(sortBy: [SortDescriptor(\.pos, order: .reverse)])
                do {
                    let result = try modelContext.fetch(descriptor).filter({ item in
                        item.list == list
                    })
                    return result.first?.pos ?? 0
                } catch {
                    return 0
                }
            }
            let lastPos = getLastPos()

//            guard lastPos == 0 else { print("check if last pos 0"); return }
            guard list.items.count == 0 else {
                guard list.items[lastPos - 1].text != "" else {
                    return
                }
                return
            }

            print("HERE")
            let newItem = ItemModel(pos: lastPos + 1)
            withAnimation {
                modelContext.insert(newItem)
                newItem.list = list
                fetchData(list: list)
            }
        } else {
            let index: Int = pos - 1
            let newItem = ItemModel(pos: pos + 1)
            if items[index].text != "" {
                withAnimation {
                    items.insert(newItem, at: pos)
                    newItem.list = list
                    for index in stride(from: items.count, through: 1, by: -1) {
                        items[index - 1].pos = index
                    }
                    fetchData(list: list)
                }
            }
        }
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        for index in stride(from: items.count, through: 1, by: -1) {
            items[index - 1].pos = index
        }
        do {
            try modelContext.save()
        } catch {
            print(error)
        }
    }

    func deleteItem(_ item: ItemModel) {
        items = items.filter({ lst in
            return lst != item
        })
        modelContext.delete(item)
        for index in stride(from: items.count, through: 1, by: -1) {
            items[index - 1].pos = index
        }
        do {
            try modelContext.save()
        } catch {
            print(error)
        }
    }
}


class Sounds {
    static var audioPlayer: AVAudioPlayer?
    static func playSounds(soundfile: String) {
        if let path = Bundle.main.path(forResource: soundfile, ofType: nil) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error")
            }
        }
    }
}
