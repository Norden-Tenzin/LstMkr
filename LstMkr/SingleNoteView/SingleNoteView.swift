//
//  SingleListView.swift
//  LstMkr
//
//  Created by Tenzin Norden on 10/2/23.
//

import SwiftUI
import SwiftData

struct SingleNoteView: View {
    @Environment(\.modelContext) var modelContext
    @State var listViewModel: ListViewModel
    @State var viewModel: SingleNoteViewModel
    @State var list: ListModel
    @State private var height: CGFloat = .zero
    @FocusState private var titleIsFocused: Bool
    @FocusState private var bodyIsFocused: Bool

    init(modelContext: ModelContext, listViewModel: ListViewModel, list: ListModel) {
        self.list = list
        self.listViewModel = listViewModel
        let viewModel = SingleNoteViewModel(modelContext: modelContext, list: list)
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            TextField("Title",
                text: Binding(
                    get: { list.title },
                    set:
                    { (newValue, _) in
                        if let _ = newValue.lastIndex(of: "\n") {
                            bodyIsFocused = true
                        } else {
                            list.title = newValue
                        }
                    }
                ), axis: .vertical)
                .font(.system(size: 30, weight: .bold))
                .listRowSeparator(.hidden)
                .submitLabel(.done)
                .focused($titleIsFocused)
            ZStack(alignment: .leading) {
                Text(list.body).foregroundColor(.clear).padding(6)
                    .background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self, value: $0.frame(in: .local).size.height)
                })
                TextEditor(text: $list.body)
                    .frame(minHeight: height)
                    .focused($bodyIsFocused)
            }
                .listRowSeparator(.hidden)
        }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear() {
            if list.title == "" && list.body == "" {
                titleIsFocused = true
            } else if list.title != "" && list.body == "" {
                bodyIsFocused = true
            }
        }
            .onDisappear() {
            for (_, list) in listViewModel.lists.enumerated() {
                if list.title.isEmpty && list.body.isEmpty {
                    modelContext.delete(list)
                }
            }
            listViewModel.lists.removeAll { list in
                list.title.isEmpty && list.body.isEmpty
            }
            do {
                try modelContext.save()
            } catch {
                print(error)
            }
        }
            .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        titleIsFocused = false
                        bodyIsFocused = false
                    }
                }
            }
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
