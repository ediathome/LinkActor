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
        .toolbar(content: {
            ToolbarItemGroup {
                Label("@\(linkAceURL)", systemImage: "bolt.horizontal.circle")
                    .help("connected to \(linkAceURL)")
                    .frame(alignment: .trailing)
            }
        })
        
        
        
    }
}



struct AllBookmarksListView: View {

    @State var bookmarks = [Bookmark]()

    var body: some View {
        VStack {
            BareBookmarksListView()
        }
        .frame(width: .infinity, alignment: .topLeading)
    }
}

struct BookmarksListView: View {
    @State var bookmarkList: BookmarkList
    @State var bookmarks = [Bookmark]()
    var body: some View {
        VStack {
            BareBookmarksListView(bookmarkList: bookmarkList)
        }
        .frame(width: .infinity, height: .infinity, alignment: .topLeading)
    }
}

struct TrashBookmarksListView: View {
    @State var bookmarks = [Bookmark]()
    var body: some View {
        VStack {
            BareBookmarksListView(showTrash: true)
        }
        .frame(width: .infinity, height: .infinity, alignment: .topLeading)
    }
}

struct BookmarkDetailView: View {
    
    @State var bookmark: Bookmark
    
    var body: some View {
        
        let bmdesc = try? AttributedString.init(markdown: bookmark.description ?? "")
        let bmlink = try? AttributedString.init(markdown: "[" + bookmark.url + "](" + bookmark.url + ")")
        
        VStack(alignment: .leading, spacing: 24) {
            Text(bookmark.title ?? "untitled")
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


