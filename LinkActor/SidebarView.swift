//
//  SidebarView.swift
//  LinkActor
//
//  Created by Martin Kolb on 24.10.22.
//

import Foundation
import SwiftUI

struct Sidebar: View {
    
    @AppStorage("linkAceURL") var linkAceURL: String = ""
    @AppStorage("linkAceApiKey") var linkAceApiKey: String = ""
    
    // @State var bookmarkLists = [BookmarkList]()
    @StateObject private var bookmarkListsModel = BookmarkListsViewModel()
    
    @State private var loadingListsCompleted = false
    @State var active = 0

    // @EnvironmentObject var bookmarksDataStore = BookmarksDataStore()
    
    var body: some View {
        if bookmarkListsModel.loaded {
            List {
                NavigationLink("All", destination: AllBookmarksListView())
                ForEach(bookmarkListsModel.lists) { bmList in
                    let listDropDelegate = SidebarBookmarkListDropDelegate(bookmarkList: bmList)
                    NavigationLink(bmList.name ?? "", destination: BookmarksListView(bookmarkList: bmList))
                        .onDrop(of: ["public.url"], delegate: listDropDelegate)
                }
                NavigationLink("Trash", destination: TrashBookmarksListView())
            }
            .frame(width: 240, alignment: .topLeading)
            .navigationTitle("Bookmarks")
            .onAppear(perform: {
                // insert some code to select the "All" item
            })
            .onChange(of: linkAceURL, perform: { newUrl in
                bookmarkListsModel.reload()
            })
            
        }
        else {
            ProgressView()
                .onChange(of: linkAceURL, perform: { newUrl in
                    bookmarkListsModel.reload()
                })
                .alert(
                    Text("Loading Bookmarks failed"),
                    isPresented: $bookmarkListsModel.didError
                ) {
                    Button("Open Preferences") {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    }
                    Button("Dismiss") {}
                }
        message: {
            Text("Please check the server address and API token in the preferences")
        }
        }
    }
}
