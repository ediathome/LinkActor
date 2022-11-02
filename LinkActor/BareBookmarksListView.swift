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
    @State var sortParameter = 1

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
    
    func sort() {
        filteredBookmarks?.sort(by: { bookmarkA, bookmarkB in
            switch sortParameter {
            case 1: // Title
                return bookmarkA.title! < bookmarkB.title!
            case 2: // Created at
                return bookmarkA.createdAt! < bookmarkB.createdAt!
            case 3: // Updated at
                return bookmarkA.updatedAt! < bookmarkB.createdAt!
            case 4: // Created at
                return bookmarkA.deletedAt! < bookmarkB.createdAt!
            default:
                return bookmarkA.title! < bookmarkB.title!
            }
            
            
        })
    }
    
    func didLoadBookmarks(bookmarks: [Bookmark]) {
        self.bookmarks = bookmarks
        filter(by: filterText)
    }
    var body: some View {
        let dropDelegate = BookmarkListDropDelegate(bookmarksListView: self, bookmarkList: bookmarkList)
        
        VStack(alignment: .leading, spacing: 0) {
            Picker(selection: $sortParameter,
                   label: Image(systemName: "line.horizontal.3.decrease.circle"),
                   content: {
                        Text("Title").tag(1)
                        Text("Created at").tag(2)
                        Text("Updated at").tag(3)
                if (showTrash  ?? false) {
                            Text("Deleted at").tag(4)
                        }
            })
                .onChange(of: sortParameter, perform: { tag in
                    sort()
                })
                .padding(8)

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
        } // end VStack
        .pickerStyle(.menu)
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
