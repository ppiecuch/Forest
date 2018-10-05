//
//  ServiceTask+Response.swift
//  Condulet
//
//  Created by Natan Zalkin on 29/09/2018.
//  Copyright © 2018 Natan Zalkin. All rights reserved.
//

import Foundation


// MARK: - Response handlers

public extension ServiceTask {
    
    /// Set response handler
    @discardableResult
    public func response(_ handler: ServiceTaskResponseHandling) -> Self {
        responseHandler = handler
        return self
    }
    
    /// Handle response with block
    @discardableResult
    public func response(content handler: @escaping (ServiceTask.Content, URLResponse) -> Void) -> Self {
        return content(handler)
    }
    
    /// Handle data response. If received response other type task will fail with ConduletError.invalidResponse
    @discardableResult
    public func response(data handler: @escaping (Data, URLResponse) -> Void) -> Self {
        return data(handler)
    }
    
    /// Handle file response. If received response other type task will fail with ConduletError.invalidResponse
    @discardableResult
    public func response(file handler: @escaping (URL, URLResponse) -> Void) -> Self {
        return file(handler)
    }
    
    /// Handle text response. If received response other type task will fail with ConduletError.invalidResponse
    @discardableResult
    public func response(text handler: @escaping (String, URLResponse) -> Void) -> Self {
        return text(handler)
    }
    
    /// Handle json response. If received response other type task will fail with ConduletError.invalidResponse
    @discardableResult
    public func response(json handler: @escaping (Any, URLResponse) -> Void) -> Self {
        return json(handler)
    }
    
    /// Handle url-encoded response. If received response other type task will fail with ConduletError.invalidResponse
    @discardableResult
    public func response(urlencoded handler: @escaping ([String: String], URLResponse) -> Void) -> Self {
        return urlencoded(handler)
    }
    
    /// Handle json response with serialized Decodable object of type. If received response other type task will fail with ConduletError.invalidResponse
    @discardableResult
    public func response<T: Decodable>(codable handler: @escaping (T, URLResponse) -> Void) -> Self {
        return codable(handler)
    }
    
}

// MARK: - Named response handlers

public extension ServiceTask {
    
    /// Handle response with block
    @discardableResult
    public func content(_ handler: @escaping (ServiceTask.Content, URLResponse) -> Void) -> Self {
        responseHandler = ResponseHandler { [unowned queue = responseQueue] (content, response) in
            queue.addOperation {
                handler(content, response)
            }
        }
        return self
    }

    /// Handle data response. If received response other type task will fail with ConduletError.invalidResponse
    @discardableResult
    public func data(_ handler: @escaping (Data, URLResponse) -> Void) -> Self {
        responseHandler = ResponseHandler { [unowned queue = responseQueue] (content, response) in
            switch content {
            case let .data(data):
                queue.addOperation {
                    handler(data, response)
                }
            default:
                throw ConduletError.invalidResponse
            }
        }
        return self
    }
    
    /// Handle file response. If received response other type task will fail with ConduletError.invalidResponse
    @discardableResult
    public func file(_ handler: @escaping (URL, URLResponse) -> Void) -> Self {
        responseHandler = ResponseHandler { [unowned queue = responseQueue] (content, response) in
            switch content {
            case let .file(url):
                queue.addOperation {
                    handler(url, response)
                }
            default:
                throw ConduletError.invalidResponse
            }
        }
        return self
    }

    /// Handle text response. If received response other type task will fail with ConduletError.invalidResponse
    @discardableResult
    public func text(_ handler: @escaping (String, URLResponse) -> Void) -> Self {
        responseHandler = TextContentHandler { [unowned queue = responseQueue] (string, response) in
            queue.addOperation {
                handler(string, response)
            }
        }
        return self
    }

    /// Handle json response. If received response other type task will fail with ConduletError.invalidResponse
    @discardableResult
    public func json(_ handler: @escaping (Any, URLResponse) -> Void) -> Self {
        responseHandler = JSONContentHandler { [unowned queue = responseQueue] (object, response) in
            queue.addOperation {
                handler(object, response)
            }
        }
        return self
    }
    
    /// Handle url-encoded response. If received response other type task will fail with ConduletError.invalidResponse
    @discardableResult
    public func urlencoded(_ handler: @escaping ([String: String], URLResponse) -> Void) -> Self {
        responseHandler = URLEncodedContentHandler { [unowned queue = responseQueue] (dictionary, response) in
            queue.addOperation {
                handler(dictionary, response)
            }
        }
        return self
    }
    
    /// Handle json response with serialized Decodable object of type. If received response other type task will fail with ConduletError.invalidResponse
    @discardableResult
    public func codable<T: Decodable>(_ handler: @escaping (T, URLResponse) -> Void) -> Self {
        responseHandler = DecodableContentHandler { [unowned queue = responseQueue] (object: T, response) in
            queue.addOperation {
                handler(object, response)
            }
        }
        return self
    }
    
}
