//
//  ContentView.swift
//  LinkActor
//
//  Created by Martin Kolb on 15.10.22.
//

import SwiftUI
import AppKit

struct ContentView: View {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var bookmarkLists = [BookmarkList]()
    
    var body: some View {
        NavigationView {
            Sidebar()
            Text("Select a list")
            Text("Select a bookmark")
        }
        .navigationTitle("Bookmarks")
        .toolbar(content: {
            ToolbarItemGroup {
                Text("…@")
                    .frame(alignment: .leading)
            }
        })
        
        
        
    }
}

struct Sidebar: View {
    
    @AppStorage("linkAceURL") var linkAceURL: String = ""
    @AppStorage("linkAceApiKey") var linkAceApiKey: String = ""
    
    // @State var bookmarkLists = [BookmarkList]()
    @StateObject private var bookmarkListsModel = BookmarkListsViewModel()
    
    @State var loadDetails: LoadDetails?
    @State private var loadingListsCompleted = false
    
    // @EnvironmentObject var bookmarksDataStore = BookmarksDataStore()
    
    var body: some View {
        if bookmarkListsModel.loaded {
            List {
                NavigationLink("All", destination: AllBookmarksListView())
                ForEach(bookmarkListsModel.lists) { bmList in
                    NavigationLink(bmList.name ?? "", destination: BookmarksListView(bookmarkList: bmList))
                }
            }
            .frame(width: 240, alignment: .topLeading)
            .navigationTitle("Bookmarks")
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


struct AllBookmarksListView: View {
    @State var bookmarks = [Bookmark]()
    @State var filteredBookmarks = [Bookmark]()
    @State var filterText = ""
    
    var body: some View {
        VStack {
            List(filteredBookmarks) { bm in
                NavigationLink(bm.title, destination: BookmarkDetailView(bookmark: bm))
                    .frame(maxHeight: 32)
                    .help(bm.title)
            }
            .searchable(text: $filterText, placement: .toolbar)
            .onChange(of: filterText, perform: { nFilter in
                if (nFilter == "") {
                    filteredBookmarks = bookmarks
                    return
                }
                filteredBookmarks = bookmarks.filter { bm in
                    bm.title.matches(pattern: nFilter)
                }
            })
        }
        .onAppear() {
            apiCall().getAllBookmarks(completion: { (bookmarks) in
                self.bookmarks = bookmarks
                self.filteredBookmarks = bookmarks
            })
        }
        .frame(width: 240, alignment: .topLeading)
    }
}

struct BookmarksListView: View {
    @State var bookmarkList: BookmarkList
    @State var bookmarks = [Bookmark]()
    var body: some View {
        List(bookmarks) { bm in
            NavigationLink(bm.title, destination: BookmarkDetailView(bookmark: bm))
                .frame(maxHeight: 32)
                .help(bm.title)
        }
        .onAppear() {
            apiCall().getBoomarksInList(bookmarkList: self.bookmarkList, completion: { (bookmarks) in
                self.bookmarks = bookmarks
            })
        }
        .frame(width: 240, height: .infinity, alignment: .topLeading)
    }
}


struct BookmarkDetailView: View {
    
    @State var bookmark: Bookmark
    
    var body: some View {
        
        let bmdesc = try? AttributedString.init(markdown: bookmark.datumDescription)
        let bmlink = try? AttributedString.init(markdown: "[" + bookmark.url + "](" + bookmark.url + ")")
        
        VStack(alignment: .leading, spacing: 24) {
            Text(bookmark.title)
                .font(.title)
                .fontWeight(.bold)
                .textSelection(.enabled)
            Text(bmdesc ?? "No description available")
                .font(.body)
                .textSelection(.enabled)
            Text(bmlink ?? "Invalid URL")
                .textSelection(.enabled)
            
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(NSColor.textBackgroundColor))
    }
}


