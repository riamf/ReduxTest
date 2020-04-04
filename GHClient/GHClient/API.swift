import Foundation

enum ServerError: Error {
    case message(String)
    case unknown
}

public enum APIURL {

    public static func languages() -> URL {
        return URL(string: "https://api.github.com/languages")!
    }

    static func getRepositories(_ since: Int) -> URL {
        return URL(string: "https://api.github.com/repositories?since=\(since)")!
    }
}

class API {

    static let shared = API()

    private var session: URLSession
    private var decoder: JSONDecoder

    private var token: String? {
        guard let path = Bundle.main.url(forResource: "token", withExtension: nil),
            let value = try? String(contentsOf: path, encoding: .utf8) else { return nil }
        return value
    }

    init(_ config: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.session = URLSession(configuration: config)
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func get<T: Codable>(url: URL, _ completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        if let token = token {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        session.dataTask(with: request) { [weak decoder] (data, response, error) in
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

public protocol GHCLientProtocol {
}

public final class GHClient: GHCLientProtocol {
    private let api: API

    public init() {
        self.api = API.shared
    }

    public func getRepositories(_ since: Int = 0, _ completion: @escaping (Result<[Repository], Error>) -> Void) {
        api.get(url: APIURL.getRepositories(since), completion)
    }
}

public struct Repository: Codable {
    public let id: Int
    public let name: String
    public let owner: Owner
    public let description: String?
}

public struct Owner: Codable {
    public let login: String
}
