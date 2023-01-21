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

enum NetworkError: Error {
    case invalidURL
    case unauthorized
    case unprocessableEntity
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
    
    func getAllBookmarks(completion:@escaping ([Bookmark]) -> (), apiUrlPath: String? = nil) {
        var urlComponents = getStandardUrlComponents()

        urlComponents.path = urlComponents.path + (apiUrlPath ?? "/links")

        urlComponents.queryItems = [
           URLQueryItem(name: "order_by", value: "title"),
           URLQueryItem(name: "order_dir", value: "asc")
        ]
        
        guard let url = urlComponents.url?.absoluteURL  else { return }
        guard let request = try? getStandardRequest(url: url) else { return }
        
        URLSession.shared.dataTask(with: request) { (jsonData, response, error) in
            let bmPage = try? JSONDecoder().decode(BookmarkPage.self, from: jsonData!)
            if(bmPage == nil) {
                print("bmPage: is nil")
                print(jsonData as Any)
            }
            let bookmarks = bmPage?.data
            if(bookmarks == nil) {
                print("\n\nERROR loading bookmarks got nil")
                print(response as Any)
                print("\n\n")
            }

            DispatchQueue.main.async {
                completion(bookmarks ?? [Bookmark]())
            }
        }
        .resume()
    }
    func getTrashBookmarks(completion:@escaping ([Bookmark]) -> ()) {
        var urlComponents = getStandardUrlComponents()

        urlComponents.path = urlComponents.path + "/trash/links"

        urlComponents.queryItems = [
           URLQueryItem(name: "order_by", value: "title"),
           URLQueryItem(name: "order_dir", value: "asc")
        ]
        
        guard let url = urlComponents.url?.absoluteURL  else { return }
        guard let request = try? getStandardRequest(url: url) else { return }
        
        URLSession.shared.dataTask(with: request) { (jsonData, response, error) in
            let bookmarks = try? JSONDecoder().decode([Bookmark].self, from: jsonData!)
            if(bookmarks == nil) {
                print("bookmarks in trash is nil")
            }

            DispatchQueue.main.async {
                completion(bookmarks ?? [Bookmark]())
            }
        }
        .resume()
    }
    func emptyTrash() -> Result<Bool, NetworkError> {
        var urlComponents = getStandardUrlComponents()
        urlComponents.path = urlComponents.path + "/trash/clear"

        urlComponents.queryItems = [
           URLQueryItem(name: "model", value: "links")
        ]

        guard let url = urlComponents.url?.absoluteURL  else {
            print("invalid urlComponent received")
            return .failure(.invalidURL)
        }
        guard var request = try? getStandardRequest(url: url, method: "POST") else {
            print("error getting standard request for method post")
            return .failure(.invalidURL)
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (jsonData, response, error) in
            print("Empty trash response: \(response as Any)")
            if (error != nil) {
                print("dataTask failed with \(error as Any)")
            }
        }
        .resume()
        return .success(true)
    }

    func getBoomarksInList(bookmarkList: BookmarkList, completion:@escaping ([Bookmark]) -> ()) {
        var urlComponents = getStandardUrlComponents()
        urlComponents.path = urlComponents.path + "/lists/" + String(bookmarkList.id) + "/links"
        urlComponents.queryItems = [
           URLQueryItem(name: "order_by", value: "title"),
           URLQueryItem(name: "order_dir", value: "asc"),
           URLQueryItem(name: "per_page", value: "-1"),
        ]

        guard let url = urlComponents.url?.absoluteURL  else { return }
        guard let request = try? getStandardRequest(url: url) else { return }
        
        URLSession.shared.dataTask(with: request) { (jsonData, response, error) in
            print ("error: " + error.debugDescription)
            
            do {
                let bmPage = try JSONDecoder().decode(BookmarkPage.self, from: jsonData!)
                
                let bookmarks = bmPage.data
                DispatchQueue.main.async {
                    completion(bookmarks ?? [Bookmark]())
                }
            } catch {
                print (error)
            }
        }
        .resume()
    }
    func getUserBookmarkLists(completion:@escaping (Result<[BookmarkList], NetworkError>) -> ()) {
        var urlComponents = getStandardUrlComponents()
        urlComponents.path = urlComponents.path + "/lists"
        
        guard let url = urlComponents.url?.absoluteURL  else {
            completion(.failure(.invalidURL))
            return
        }
        guard let request = try? getStandardRequest(url: url) else {
            print("invalid url \(url)")
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (jsonData, response, error) in
            do {
                let bmPage = try JSONDecoder().decode(ListPage.self, from: jsonData!)
                let bookmarkLists = bmPage.data
                DispatchQueue.main.async {
                    completion(.success(bookmarkLists))
                }
            } catch {
                print ("Error when loading User's bookmark lists: " + error.localizedDescription)
                print (error)
            }
        }
        .resume()
    }
    
    func newBookmark(bookmarkUrl: URL, bookmarkList: BookmarkList?, completion:@escaping (Result<Bool, NetworkError>) -> ()) {
        print("APICall bookmarkList: " + (bookmarkList?.name ?? "no list given!" ))
        var urlComponents = getStandardUrlComponents()
        urlComponents.path = urlComponents.path + "/links"

        guard let url = urlComponents.url?.absoluteURL  else {
            print("invalid urlComponent received")
            completion(.failure(.invalidURL))
            return
        }
        guard var request = try? getStandardRequest(url: url, method: "POST") else {
            print("error getting standard request for method post")
            completion(.failure(.invalidURL))
            return
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters = [
          "url": bookmarkUrl.absoluteString,
          "lists": [bookmarkList!.id as Int],
          "is_private": true // this must be there for lists to work!
        ] as [String : Any]
        
        print("parameters: \(parameters)")

        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("error encoding json data for POST request")
            completion(.failure(.invalidURL))
            return
        }
        request.httpBody = httpBody as Data

        
        URLSession.shared.dataTask(with: request) { (jsonData, response, error) in
            let httpResponse = response as? HTTPURLResponse

            if (error != nil) {
                print("dataTask failed with \(error as Any)")
            }
            if ((httpResponse!.statusCode) == 422) {
                do {
                    let errorMessage = try JSONDecoder().decode(ErrorMessage.self, from: jsonData!)
                    print("\tUnprocessable Entity 422: response: \n\(response as Any)")
                    print("\t\tmessage: \(errorMessage.message ?? "nil message")")
                    print("\t\terrors: \(errorMessage.errors?.url![0] ?? "no error provided" )")
                    completion(.failure(.unprocessableEntity))
                } catch { print(error) }
            }
        }
        .resume()
        completion(.success(true))
    }
    
    func deleteBookmark(bookmark: Bookmark, completion:@escaping (Result<Bool, NetworkError>) -> ()){
        var urlComponents = getStandardUrlComponents()
        urlComponents.path = urlComponents.path + "/links/\(bookmark.id)"

        guard let url = urlComponents.url?.absoluteURL  else {
            completion(.failure(.invalidURL))
            return
        }
        guard var request = try? getStandardRequest(url: url, method: "POST") else {
            completion(.failure(.invalidURL))
            return
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (jsonData, response, error) in
            print("Bookmarkd delete response: \(response as Any)")
            if (error != nil) {
                print("dataTask failed with \(error as Any)")
            }
            DispatchQueue.main.async {
                completion(.success(true))
            }
        }
        .resume()
    }
}
