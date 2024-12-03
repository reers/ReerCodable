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

extension SingleValueDecodingContainer {
    public func decode<Value: Decodable>(type: Value.Type, enumName: String) throws -> Value {
        if let value = try? decode(Value.self) {
            return value
        }
        if let anyCodable = try? decode(AnyCodable.self) {
            let anyValue = anyCodable.value
            if let targetTypeValue = anyValue as? Value {
                return targetTypeValue
            }
            if let converted = (Value.self as? TypeConvertible.Type)?.convert(from: anyValue),
               let convertedValue = converted as? Value {
                return convertedValue
            }
        }
        throw ReerCodableError(text: "Enum case \(enumName) not match or type not match.")
    }
}
