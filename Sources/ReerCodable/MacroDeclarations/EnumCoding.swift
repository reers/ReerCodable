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

public enum CaseMatcher {
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case nested(String)
}

public struct CaseValue {
    let label: String?
    let keys: [String]
    let index: Int?
    
    public init(label: String, keys: String...) {
        self.label = label
        self.keys = keys
        self.index = nil
    }
    
    public init(index: Int, keys: String...) {
        self.keys = keys
        self.index = index
        self.label = nil
    }
}

@attached(peer)
public macro CodingCase(
    match cases: CaseMatcher...,
    values: [CaseValue] = []
) = #externalMacro(module: "ReerCodableMacros", type: "CodingCase")
