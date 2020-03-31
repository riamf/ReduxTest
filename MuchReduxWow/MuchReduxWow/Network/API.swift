import Foundation

enum ServerError: Error {
    case message(String)
    case unknown
}

enum APIURL {
    static func users(filters: FiltersState) -> URL {
        let phrase = filters.phrase + filters.languages.map({ "+language:\($0.name)" }).reduce("", +)
        let string = "https://api.github.com/search/repositories?q=\(phrase)&order=\(filters.order)&sort=stars".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return URL(string: string)!
    }
    
    static func languages() -> URL {
        return URL(string: "https://api.github.com/languages")!
    }
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
        session.dataTask(with: url) { [weak decoder] (data, response, error) in
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
    func getRepositories(filters: FiltersState,
                  _ completion: @escaping (Result<Items, Error>) -> Void) {
        API.shared.get(url: APIURL.users(filters: filters), completion)
    }
    
    func getLanguages(_ completion: @escaping (Result<[Language], Error>) -> Void) {
        API.shared.get(url: APIURL.languages(), completion)
    }
}

struct Items: Codable {
    let items: [Repository]
}

struct Repository: Codable, Equatable {
    let name: String
    let language: String?
}

struct Language: Codable, Equatable {
    let name: String
}
