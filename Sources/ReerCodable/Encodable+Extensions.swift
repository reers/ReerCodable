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

public extension Encodable {
    func encodedData(using encoder: JSONEncoder = .init()) throws -> Data {
        return try encoder.encode(self)
    }
    
    func encodedString(using encoder: JSONEncoder = .init()) throws -> String {
        let data = try encodedData(using: encoder)
        return String(data: data, encoding: .utf8)!
    }
    
    func encodedDict(using encoder: JSONEncoder = .init()) throws -> [String: Any] {
        let data = try encodedData(using: encoder)
        return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String: Any]
    }
    
    func encodedArray(using encoder: JSONEncoder = .init()) throws -> [Any] {
        let data = try encodedData(using: encoder)
        return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [Any]
    }
}
