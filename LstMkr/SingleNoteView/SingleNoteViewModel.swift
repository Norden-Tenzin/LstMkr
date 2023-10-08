//
//  SingleListViewModel.swift
//  LstMkr
//
//  Created by Tenzin Norden on 10/3/23.
//

import Foundation
import SwiftUI
import SwiftData

extension SingleNoteView {
    @Observable
    class SingleNoteViewModel {
        var modelContext: ModelContext
        var items: [ItemModel] = [ItemModel]()
        var editMode: EditMode = EditMode.inactive

        init(modelContext: ModelContext, list: ListModel) {
            self.modelContext = modelContext
        }
    }
}
