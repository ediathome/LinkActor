//
//  BookmarkListViewModel.swift
//  LinkActor
//
//  Created by Martin Kolb on 21.10.22.
//

import Foundation
import Combine
import SwiftUI

class BookmarkListsViewModel: ObservableObject {
    // MARK: Output
    @Published var lists: [BookmarkList] = [BookmarkList]()
    @Published var loaded: Bool = false
    @Published var didError: Bool = false

    private lazy var listsPublisher: AnyPublisher<[BookmarkList], Error> = {
        $lists
            .debounce(for: 0.8, scheduler: DispatchQueue.main)
            .flatMap { lists -> AnyPublisher<[BookmarkList], Error> in
                apiCall().getListsPublisher()
                // return lists
                    //.asResult() //return apiCall().getLists()
            }
            .receive(on: DispatchQueue.main)
            .share()
            .eraseToAnyPublisher()
    }()
    func reload() {
        apiCall().getUserBookmarkLists(completion: { result in
            switch result {
            case .success(let lists):
                self.lists = lists
                self.loaded = true
            case .failure(let error):
                self.loaded = false
                self.didError = true
                print("received the following error in BookmarkListsViewModel \(error)")
            }
        })
    }
    init() {
        self.reload()
    }
}
