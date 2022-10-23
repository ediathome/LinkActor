//
//  BareBookmarksListView.swift
//  LinkActor
//
//  Created by Martin Kolb on 23.10.22.
//

import Foundation
import SwiftUI

struct BareBookmarksListView: View {

    @State var bookmarkList: BookmarkList?
    @State var showTrash: Bool?
    @State var bookmarks = [Bookmark]()
    @State var filteredBookmarks: [Bookmark]?
    @State var filterText = ""
    @State var active = 0
    
    let toolbarPlacement: SearchFieldPlacement = .toolbar
    
    func filter(by: String) {
        if (by == "") {
            filteredBookmarks = $bookmarks.wrappedValue
            return
        }
        filteredBookmarks = $bookmarks.wrappedValue.filter { bm in
            let testTitle = bm.title ?? ""
            return testTitle.matches(pattern: by)
        }
    }
    func didLoadBookmarks(bookmarks: [Bookmark]) {
        self.bookmarks = bookmarks
        filter(by: filterText)
    }
    var body: some View {
        let dropDelegate = BookmarkListDropDelegate(active: $active)

        List(filteredBookmarks ?? self.bookmarks) { bm in
            NavigationLink(bm.title ?? "untitled", destination: BookmarkDetailView(bookmark: bm))
                .frame(maxHeight: 32)
                .help(bm.title ?? "untitled")
        }
        .searchable(text: $filterText, placement: toolbarPlacement)
        .onAppear(perform: {
            if (showTrash ?? false) {
                apiCall().getTrashBookmarks(completion: didLoadBookmarks(bookmarks:))
            } else if (self.bookmarkList == nil) {
                apiCall().getAllBookmarks(completion: didLoadBookmarks(bookmarks:))
            } else {
                apiCall().getBoomarksInList(bookmarkList: self.bookmarkList!, completion: didLoadBookmarks(bookmarks:))
            }
            self.filteredBookmarks = bookmarks
            filter(by: "t")
        })
        .onChange(of: filterText, perform: { nFilter in
            filter(by: nFilter)
        })
        .onDrop(of: ["public.url"], delegate: dropDelegate)
    }
}
