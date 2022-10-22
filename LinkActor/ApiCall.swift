//
//  LinkViewModel.swift
//  LinkActor
//
//  Created by Martin Kolb on 15.10.22.
//
// Useful links and articles
// https://dev.to/tprezioso/how-to-fetch-json-data-from-apis-in-swiftui-29pk
//

import Foundation
import SwiftUI
import Combine

struct LoadDetails: Identifiable {
    var id: ObjectIdentifier
    
    let name: String
    let error: String
}

enum NetworkError: Error {
    case invalidURL
}

class apiCall {

    @AppStorage("linkAceURL") var linkAceURL: String = ""
    @AppStorage("linkAceApiKey") var linkAceApiKey: String = ""

    func getStandardUrlComponents() -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = linkAceURL
        urlComponents.path = "/api/v1"
        return urlComponents
    }
    func getStandardRequest(url: URL, method: String = "GET") throws -> URLRequest {
        if (!isValidUrl(url: url.absoluteString)) {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(linkAceApiKey)", forHTTPHeaderField: "authorization")

        return request
    }
    func isValidUrl(url: String) -> Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: url)
        return result
    }
    
    func getListsPublisher() -> AnyPublisher<[BookmarkList], Error> {
        
        print("getLists() reached")

        var urlComponents = getStandardUrlComponents()
        urlComponents.path = urlComponents.path + "/links"
        urlComponents.queryItems = [
           URLQueryItem(name: "order_by", value: "title"),
           URLQueryItem(name: "order_dir", value: "asc")
        ]
        
        guard let url = urlComponents.url?.absoluteURL  else {
            print("returning empty list and eraseToAnyPublisher()")
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
      
      return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: ListPage.self, decoder: JSONDecoder())
        .map(\.data)
        // .replaceError(with: [BookmarkList]())
        .eraseToAnyPublisher()
    }
    
    func getAllBookmarks(completion:@escaping ([Bookmark]) -> ()) {
        var urlComponents = getStandardUrlComponents()
        urlComponents.path = urlComponents.path + "/links"
        urlComponents.queryItems = [
           URLQueryItem(name: "order_by", value: "title"),
           URLQueryItem(name: "order_dir", value: "asc")
        ]
        
        guard let url = urlComponents.url?.absoluteURL  else { return }
        guard let request = try? getStandardRequest(url: url) else { return }
        
        URLSession.shared.dataTask(with: request) { (jsonData, response, error) in
            let bmPage = try? JSONDecoder().decode(BookmarkPage.self, from: jsonData!)
            let bookmarks = bmPage?.data
            DispatchQueue.main.async {
                completion(bookmarks ?? [Bookmark]())
            }
        }
        .resume()
    }
    func getBoomarksInList(bookmarkList: BookmarkList, completion:@escaping ([Bookmark]) -> ()) {
        var urlComponents = getStandardUrlComponents()
        urlComponents.path = urlComponents.path + "/lists/" + String(bookmarkList.id) + "/links"
        urlComponents.queryItems = [
           URLQueryItem(name: "order_by", value: "title"),
           URLQueryItem(name: "order_dir", value: "asc")
        ]

        guard let url = urlComponents.url?.absoluteURL  else { return }
        guard let request = try? getStandardRequest(url: url) else { return }
        
        URLSession.shared.dataTask(with: request) { (jsonData, response, error) in
            let bmPage = try? JSONDecoder().decode(BookmarkPage.self, from: jsonData!)
            let bookmarks = bmPage?.data
            DispatchQueue.main.async {
                completion(bookmarks ?? [Bookmark]())
            }
        }
        .resume()
    }
    func getUserBookmarkLists(completion:@escaping (Result<[BookmarkList], NetworkError>) -> ()) -> Bool {
        var urlComponents = getStandardUrlComponents()
        urlComponents.path = urlComponents.path + "/lists"
        
        guard let url = urlComponents.url?.absoluteURL  else { return false }
        guard let request = try? getStandardRequest(url: url) else {
            print("invalid url \(url)")
            completion(.failure(.invalidURL))
            return false
        }
        
        URLSession.shared.dataTask(with: request) { (jsonData, response, error) in
            let bmPage = try? JSONDecoder().decode(ListPage.self, from: jsonData!)

            let bookmarkLists = bmPage?.data

            /*if(bmPage?.data == nil) {
                print("bookmarkListsPage data: is nil")
            } else {
                print("bookmarkListsPage data: " + (bmPage?.data.description ?? " ERROR seems to be nil"))
                
            }*/
            DispatchQueue.main.async {
                completion(.success(bookmarkLists ?? [BookmarkList]()))
            }
        }
        .resume()
        return true
    }
}
