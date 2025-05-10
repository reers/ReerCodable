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

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ReerCodablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        // For type use only
        RECodable.self,
        REDecodable.self,
        REEncodable.self,
        InheritedCodable.self,
        InheritedDecodable.self,
        DefaultInstance.self,
        Copyable.self,
        CodingContainer.self,
        
        // For type and property use only
        FlatCase.self,
        UpperCase.self,
        CamelCase.self,
        SnakeCase.self,
        PascalCase.self,
        KebabCase.self,
        CamelSnakeCase.self,
        PascalSnakeCase.self,
        ScreamingSnakeCase.self,
        CamelKebabCase.self,
        PascalKebabCase.self,
        ScreamingKebabCase.self,
        
        // For property use only
        CodingKey.self,
        EncodingKey.self,
        CodingIgnored.self,
        Base64Coding.self,
        DateCoding.self,
        CompactDecoding.self,
        CustomCoding.self,
        CodingCase.self,
    ]
}
