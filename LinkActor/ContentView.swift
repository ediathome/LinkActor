//
//  ContentView.swift
//  LinkActor
//
//  Created by Martin Kolb on 15.10.22.
//

import SwiftUI
import AppKit

struct ContentView: View {

    @AppStorage("linkAceURL") var linkAceURL: String = ""

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
                Text("@\(linkAceURL)")
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

struct BareBookmarksListView: View {

    @State var bookmarkList: BookmarkList?
    @State var bookmarks = [Bookmark]()
    @State var filteredBookmarks: [Bookmark]?
    @State var filterText = ""
    
    let toolbarPlacement: SearchFieldPlacement = .toolbar

    func filter(by: String) {
        if (by == "") {
            filteredBookmarks = $bookmarks.wrappedValue
            return
        }
        filteredBookmarks = $bookmarks.wrappedValue.filter { bm in
            bm.title.matches(pattern: by)
        }
    }
    func didLoadBookmarks(bookmarks: [Bookmark]) {
        self.bookmarks = bookmarks
        filter(by: filterText)
    }
    var body: some View {
        
        List(filteredBookmarks ?? self.bookmarks) { bm in
            NavigationLink(bm.title, destination: BookmarkDetailView(bookmark: bm))
                .frame(maxHeight: 32)
                .help(bm.title)
        }
        .searchable(text: $filterText, placement: toolbarPlacement)
        .onChange(of: filterText, perform: { nFilter in
            filter(by: nFilter)
        })
        .onAppear(perform: {
            if (self.bookmarkList == nil) {
                apiCall().getAllBookmarks(completion: didLoadBookmarks(bookmarks:))
            } else {
                apiCall().getBoomarksInList(bookmarkList: self.bookmarkList!, completion: didLoadBookmarks(bookmarks:))
            }
            self.filteredBookmarks = bookmarks
            filter(by: "t")
        })
    }
}

struct AllBookmarksListView: View {

    @State var bookmarks = [Bookmark]()

    var body: some View {
        VStack {
            BareBookmarksListView()
        }
        .frame(width: 240, alignment: .topLeading)
    }
}

struct BookmarksListView: View {
    @State var bookmarkList: BookmarkList
    @State var bookmarks = [Bookmark]()
    var body: some View {
        VStack {
            BareBookmarksListView(bookmarkList: bookmarkList)
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


