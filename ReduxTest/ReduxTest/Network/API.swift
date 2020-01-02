//
//  API.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 26/12/2019.
//  Copyright © 2019 alpha. All rights reserved.
//

import Foundation

enum ServerError: Error {
    case message(String)
    case unknown
}

enum APIURL {
    static let users = URL(string: "https://api.github.com/users")!
}

class API {
    
    static let shared = API()
    
    private var session: URLSession
    private var decoder: JSONDecoder
    
    init(_ config: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.session = URLSession(configuration: config)
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func get<T: Codable>(url: URL, _ completion: @escaping (Result<T,Error>) -> Void) {
        session.dataTask(with: APIURL.users) { [weak decoder] (data, response, error) in
            DispatchQueue.main.async {
                if let urlresponse = response as? HTTPURLResponse,
                    (200...299).contains(urlresponse.statusCode),
                    let data = data {
                    do {
                        if let values = try decoder?.decode(T.self, from: data) {
                            completion(Result.success(values))
                        } else {
                            completion(Result.failure(ServerError.unknown))
                        }
                    } catch {
                        completion(Result.failure(ServerError.message("\(error)")))
                    }
                } else if let data = data {
                    print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
                } else if let error = error {
                    completion(Result.failure(ServerError.message("\(error)")))
                } else {
                    completion(Result.failure(ServerError.unknown))
                }
            }
        }.resume()
    }
}

class GHClient {
    func getUsers(_ completion: @escaping (Result<[User], Error>) -> Void) {
        API.shared.get(url: APIURL.users, completion)
    }
}

struct User: Codable {
    let login: String
}
