//
//  ListView.swift
//  LstMkr
//
//  Created by Tenzin Norden on 10/2/23.
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(AppState.self) var appState
    @State private var viewModel: ListViewModel

    init(modelContext: ModelContext) {
        let viewModel = ListViewModel(modelContext: modelContext)
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            ForEach(viewModel.lists) { list in
                NavigationLink(value: list) {
                    HStack(alignment: .top) {
                        Image(systemName: list.type == "note" ? "note.text" : "checklist")
                            .padding(.vertical, 5)
                            .foregroundStyle(Color.accentColor)
                        VStack(alignment: .leading) {
                            Text(list.title != "" ? list.title : list.body)
                                .font(.system(size: 20, weight: .bold))
                                .lineLimit(1)
                            Text(list.lastEditedTimeAgo)
                                .font(.caption)
                                .foregroundStyle(Color.secondaryLabel)
                        }
                    }
                        .onDrag { // mean drag a row container
                        return NSItemProvider()
                    }
                }
                    .swipeActions {
                    Button(role: .destructive) {
                        viewModel.deleteItem(list)
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                }
//                Group {
//                    if viewModel.editMode == .inactive {
//                        NavigationLink(value: list) {
//                            HStack(alignment: .top) {
//                                Image(systemName: list.type == "note" ? "note.text" : "list.bullet")
//                                    .padding(.vertical, 5)
//                                    .foregroundStyle(Color.accentColor)
//                                VStack(alignment: .leading) {
//                                    Text(list.title != "" ? list.title : list.body)
//                                        .font(.system(size: 20, weight: .bold))
//                                        .lineLimit(1)
//                                    Text(list.lastEditedTimeAgo)
//                                        .font(.caption)
//                                        .foregroundStyle(Color.secondaryLabel)
//                                }
//                            }
//                                .onDrag { // mean drag a row container
//                                return NSItemProvider()
//                            }
//                        }
//                            .swipeActions {
//                            Button(role: .destructive) {
//                                viewModel.deleteItem(list)
//                            } label: {
//                                Label("Delete", systemImage: "trash.fill")
//                            }
//                        }
//                    } else {
//                        HStack(alignment: .top) {
//                            Image(systemName: list.type == "note" ? "note.text" : "list.bullet")
//                                .padding(.vertical, 5)
//                                .foregroundStyle(Color.accentColor)
//                            VStack(alignment: .leading) {
//                                Text(list.title != "" ? list.title : list.body)
//                                    .font(.system(size: 20, weight: .bold))
//                                    .lineLimit(1)
//                                Text(list.lastEditedTimeAgo)
//                                    .font(.caption)
//                                    .foregroundStyle(Color.secondaryLabel)
//                            }
//                        }
//                    }
//                }
            }
                .onMove(perform: viewModel.moveItem)
                .listRowSeparator(.hidden)
        }
            .listStyle(.plain)
            .navigationTitle("LstMkr")
            .environment(\.editMode, $viewModel.editMode)
            .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                Button(action: { viewModel.deleteLists() }, label: {
//                        HStack {
//                            Image(systemName: "trash")
//                            Text("DEBUG")
//                        }
//                            .background(Color.green)
//                    })
//            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    if viewModel.editMode == .active {
                        viewModel.editMode = .inactive
                    } else if viewModel.editMode != .active {
                        viewModel.editMode = .active
                    }
                }, label: {
                        if viewModel.editMode == .active {
                            Text("Done")
                        } else if viewModel.editMode != .active {
                            Text("Edit")
                        }
                    })
            }
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button(action: {
                        let newList = viewModel.addList(appState: appState, type: "note")
                        appState.currentRoute = "note"
                        appState.navigationPath.append(newList)
                    }, label: {
                            Image(systemName: "note.text")
                        })
                    Button(action: {
                        let newList = viewModel.addList(appState: appState, type: "check")
                        appState.currentRoute = "check"
                        appState.navigationPath.append(newList)
                    }, label: {
                            Image(systemName: "checklist")
                        })
                    Spacer()
                }
            }
        }
            .navigationDestination(for: ListModel.self, destination: { list in
            if list.type == "check" {
                SingleListView(modelContext: modelContext, listViewModel: viewModel, list: list)
            } else if list.type == "note" {
                SingleNoteView(modelContext: modelContext, listViewModel: viewModel, list: list)
            } else {
                SingleListView(modelContext: modelContext, listViewModel: viewModel, list: list)
            }
        })
    }
}
