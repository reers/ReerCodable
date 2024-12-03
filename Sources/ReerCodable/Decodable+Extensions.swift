//
//  Copyright © 2024 reers.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

public extension Decodable {
    static func decoded(
        from data: Data,
        using decoder: JSONDecoder = .init(),
        as type: Self.Type = Self.self
    ) throws -> Self {
        return try decoder.decode(type, from: data)
    }
    
    static func decoded(
        from string: String,
        using decoder: JSONDecoder = .init(),
        as type: Self.Type = Self.self
    ) throws -> Self {
        let data = Data(string.utf8)
        return try decoder.decode(type, from: data)
    }
    
    static func decoded(
        from dict: [String: Any],
        using decoder: JSONDecoder = .init(),
        as type: Self.Type = Self.self
    ) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed)
        return try decoder.decode(type, from: data)
    }
    
    static func decoded(
        from array: [Any],
        using decoder: JSONDecoder = .init(),
        as type: Self.Type = Self.self
    ) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
        return try decoder.decode(type, from: data)
    }
}


public extension Data {
    func decoded<T: Decodable>(using decoder: JSONDecoder = .init(), as type: T.Type = T.self) throws -> T {
        return try decoder.decode(type, from: self)
    }
}

public extension String {
    func decoded<T: Decodable>(using decoder: JSONDecoder = .init(), as type: T.Type = T.self) throws -> T {
        return try Data(self.utf8).decoded(using: decoder, as: type)
    }
}

public extension Dictionary {
    func decoded<T: Decodable>(using decoder: JSONDecoder = .init(), as type: T.Type = T.self) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
        return try data.decoded(using: decoder, as: type)
    }
}

public extension Array {
    func decoded<T: Decodable>(using decoder: JSONDecoder = .init(), as type: T.Type = T.self) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
        return try data.decoded(using: decoder, as: type)
    }
}

