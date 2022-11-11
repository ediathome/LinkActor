//
//  BookmarkListDropDelegate.swift
//  LinkActor
//
//  Created by Martin Kolb on 23.10.22.
//

import Foundation
import SwiftUI

struct BookmarkListDropDelegate: DropDelegate {
    // @Binding var imageUrls: [Int: URL]
    // @Binding var active: Int
    @State var bookmarksListView: BareBookmarksListView

    
    func validateDrop(info: DropInfo) -> Bool {
        if (info.hasItemsConforming(to: ["public.file-url"])) {
            return false
        }
        return info.hasItemsConforming(to: ["public.url"])
    }
    
    func dropEntered(info: DropInfo) {
        NSSound(named: "Morse")?.play()
    }
    
    func performDrop(info: DropInfo) -> Bool {

        // print("location: \(info.location)")
        
        if let item = info.itemProviders(for: ["public.url"]).first {
            item.loadItem(forTypeIdentifier: "public.url", options: nil) { (urlData, error) in
                
                let newBookmarkUrl = URL(dataRepresentation: urlData as! Data, relativeTo: nil)

                DispatchQueue.main.async {
                    apiCall().newBookmark(bookmarkUrl: newBookmarkUrl!, bookmarkList: self.bookmarksListView.bookmarkList, completion: { result in
                        switch result {
                        case .success(_):
                            bookmarksListView.reloadData()
                        case .failure(let error):
                            print("\tERROR!")
                            print("\treceived the following error in BookmarkListsViewModel \(error)")
                        }
                    })
                    bookmarksListView.reloadData()
                }
            }
            
            return true
            
        }
        return false
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        if (info.hasItemsConforming(to: ["public.file-url"])) {
            return nil
        }
        if (info.hasItemsConforming(to: ["public.url"])) {
            return nil
        }
        return nil
    }
    
    func dropExited(info: DropInfo) {
    }
    
    func getGridPosition(location: CGPoint) -> Int {
        if location.x > 150 && location.y > 150 {
            return 4
        } else if location.x > 150 && location.y < 150 {
            return 3
        } else if location.x < 150 && location.y > 150 {
            return 2
        } else if location.x < 150 && location.y < 150 {
            return 1
        } else {
            return 0
        }
    }
}
