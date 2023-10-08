//
//  SingleListView.swift
//  LstMkr
//
//  Created by Tenzin Norden on 10/4/23.
//

import SwiftUI
import SwiftData

struct SingleListView: View {
    @Environment(\.modelContext) var modelContext
    @State var listViewModel: ListViewModel
    @State var viewModel: SingleListViewModel
    @State var list: ListModel
    @FocusState private var fieldIsFocused: Bool

    init(modelContext: ModelContext, listViewModel: ListViewModel, list: ListModel) {
        self.list = list
        self.listViewModel = listViewModel
        let viewModel = SingleListViewModel(modelContext: modelContext, list: list)
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            List {
                TextField("Title", text: $list.title, axis: .vertical)
                    .font(.system(size: 30, weight: .bold))
                    .listRowSeparator(.hidden)
                ForEach(viewModel.items) { item in
                    SingleItemView(item: item, viewModel: viewModel, fieldIsFocused: $fieldIsFocused)
                        .swipeActions {
                        Button(role: .destructive) {
                            viewModel.deleteItem(item)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                        .onDrag {
                        return NSItemProvider()
                    }
                }
                    .onMove(perform: viewModel.moveItem)
                    .listRowSeparator(.hidden)
                Button {
                    let _ = viewModel.addItem()
                } label: {
                    Text("add")
                        .padding(.horizontal, 30)
                }
                    .buttonStyle(.borderless)
                    .listRowSeparator(.hidden)
            }
                .listStyle(.plain)
            Spacer()
        }
            .navigationBarTitleDisplayMode(.inline)
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
                        fieldIsFocused = false
                    }
                }
            }
        }
    }
}

struct SingleItemView: View {
    @Environment(\.modelContext) private var viewContext
    @State var item: ItemModel
    var viewModel: SingleListViewModel
    var fieldIsFocused: FocusState<Bool>.Binding

    init(item: ItemModel, viewModel: SingleListViewModel, fieldIsFocused: FocusState<Bool>.Binding) {
        self.item = item
        self.viewModel = viewModel
        self.fieldIsFocused = fieldIsFocused
    }

    var body: some View {
        HStack {
            Toggle(isOn: $item.isChecked) {
                EmptyView()
            }
                .toggleStyle(CheckboxToggleStyle())
                .frame(width: 15)
                .onChange(of: item.isChecked) { oldValue, newValue in
//                Sounds.playSounds(soundfile: "click.wav")
            }

            TextField("", text: $item.text)
                .padding(.horizontal, 10)
                .focused(fieldIsFocused)
                .onSubmit {
                viewModel.addItem(pos: item.pos)
            }
            Spacer()
        }
            .onAppear() {
            if item.text == "" {
                fieldIsFocused.wrappedValue = true
            } else {
                fieldIsFocused.wrappedValue = true
            }
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                .foregroundColor(configuration.isOn ? .accentColor : .gray)
        }
            .font(.system(size: 23, weight: .regular, design: .default))
            .onTapGesture { configuration.isOn.toggle() }
    }
}
