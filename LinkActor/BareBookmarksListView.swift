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
    @State var selection : String? = nil
    
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
        let dropDelegate = BookmarkListDropDelegate(bookmarksListView: self, bookmarkList: bookmarkList)
        
        List(filteredBookmarks ?? self.bookmarks, selection: $selection) { bm in
            NavigationLink(bm.title ?? "untitled", destination: BookmarkDetailView(bookmark: bm))
                .frame(height: 32)
                .help(bm.title ?? "untitled")
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        withAnimation {
                            removeBookmark(deleteBookmark: bm)
                        }
                    }
                }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                if (showTrash ?? false) {
                    Button(action: {
                        apiCall().emptyTrash()
                    }, label: {
                        Image(systemName: "trash.circle")
                    })
                        
                }
            }
        }
        .onDeleteCommand(perform: {
            print("now delete the item \(self.selection ?? "null item")")
            // removeBookmark(deleteBookmark: )
        })
        .searchable(text: $filterText, placement: toolbarPlacement)
        .onAppear(perform: {
            reloadData()
        })
        .onChange(of: filterText, perform: { nFilter in
            filter(by: nFilter)
        })
        .onDrop(of: ["public.url"], delegate: dropDelegate)
    }
    func reloadData() {
        if (showTrash ?? false) {
            apiCall().getTrashBookmarks(completion: didLoadBookmarks(bookmarks:))
        } else if (self.bookmarkList == nil) {
            apiCall().getAllBookmarks(completion: didLoadBookmarks(bookmarks:))
        } else {
            apiCall().getBoomarksInList(bookmarkList: self.bookmarkList!, completion: didLoadBookmarks(bookmarks:))
        }
        self.filteredBookmarks = bookmarks
        filter(by: "t")
    }
    func removeBookmark(deleteBookmark: Bookmark) {
        print("now remove bookmark \(String(describing: deleteBookmark.title))")
        apiCall().deleteBookmark(bookmark: deleteBookmark, completion: { result in
            switch result {
            case .success(_):
                if let index = bookmarks.firstIndex(of: deleteBookmark) {
                    self.bookmarks.remove(at: index)
                }
                reloadData()
            case .failure(let error):
                print("\tERROR!")
                print("\treceived the following error in BookmarkListsViewModel \(error)")
            }
        }
        )
        
    }
}
