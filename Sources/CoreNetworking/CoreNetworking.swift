//
//  CoreNetworking.swift
//
//
//  Created by Vlad Kozlov on 20.04.2023.
//

import Foundation

public enum RequestMethod: String {
  case delete = "DELETE"
  case get = "GET"
  case patch = "PATCH"
  case post = "POST"
  case put = "PUT"
  
  var method: String { rawValue.uppercased() }
}

public struct Endpoint {
  
  var base: String
  var path: String
  var method: RequestMethod
  var header: [String: String]?
  var body: [String: String]?
  
  public init(
    base: String,
    path: String,
    method: RequestMethod,
    header: [String : String]? = nil,
    body: [String : String]? = nil
  ) {
    self.base = base
    self.path = path
    self.method = method
    self.header = header
    self.body = body
  }
  
  var url: URL? {
    return URL(string: self.base + self.path)
  }
}

@available(iOS 15.0, *)
public final class NetworkManager {
  
  public enum NetworkError: Error {
    
    case unknown
    case invalidUrl
    case noResponse
    case decode
    case unexpected(statusCode: Int)
    
    public var description: String {
      switch self {
      case .unknown:
        return "🛑 Error -- Unknown"
      case .invalidUrl:
        return "🛑 Error -- Invalid URL"
      case .noResponse:
        return "🛑 Error -- No Response"
      case .decode:
        return "🛑 Error -- Decoding Error"
      case let .unexpected(statusCode):
        return "🛑 Error -- Status Code \(statusCode)"
      }
    }
  }
  
  public init() { }
  
  public func request<T: Decodable>(
    endpoint: Endpoint,
    responseModel: T.Type
  ) async -> Result<T, NetworkError> {
    guard let url = endpoint.url else {
      return .failure(NetworkError.invalidUrl)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = endpoint.method.rawValue
    request.allHTTPHeaderFields = endpoint.header
    
    if let body = endpoint.body {
      request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    do {
      let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
      
      guard let response = response as? HTTPURLResponse else {
        return .failure(NetworkError.noResponse)
      }
      
      switch response.statusCode {
      case 200...299:
        guard let decodedResponse = try? JSONDecoder().decode(
          responseModel,
          from: data
        ) else {
          return .failure(NetworkError.decode)
        }
        
        return .success(decodedResponse)
      default:
        return .failure(NetworkError.unexpected(statusCode: response.statusCode))
      }
    } catch {
      return .failure(NetworkError.unknown)
    }
  }
}
