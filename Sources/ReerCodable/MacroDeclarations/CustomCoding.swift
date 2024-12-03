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

@attached(peer)
public macro CustomCoding<Value>(
    decode: ((_ decoder: Decoder) throws -> Value)? = nil,
    encode: ((_ encoder: Encoder, _ value: Value) throws -> Void)? = nil
) = #externalMacro(module: "ReerCodableMacros", type: "CustomCoding")

public protocol CodingCustomizable {
    associatedtype Value: Codable
    
    static func decode(by decoder: Decoder) throws -> Value
    static func encode(by encoder: Encoder, _ value: Value) throws
}

@attached(peer)
public macro CustomCoding(
    _ customCodingType: any CodingCustomizable.Type
) = #externalMacro(module: "ReerCodableMacros", type: "CustomCoding")
