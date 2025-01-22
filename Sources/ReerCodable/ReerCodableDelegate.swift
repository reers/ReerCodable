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

/// Protocol that provides hooks to perform custom actions during decode/encode lifecycle
/// - Note: Implementers can use this protocol to perform additional setup after decoding
///         or preparation before encoding
public protocol ReerCodableDelegate {
    
    /// Called after decoding is complete but before the object is fully initialized
    /// - Parameter decoder: The decoder that was used to decode the object
    /// - Throws: Any error that occurs during post-decode processing
    /// - Important: ⚠️ This method can be marked as `mutating` to modify self if needed
    func didDecode(from decoder: any Decoder) throws
    
    /// Called just before encoding begins
    /// - Parameter encoder: The encoder that will be used to encode the object
    /// - Throws: Any error that occurs during pre-encode processing
    /// - Important: ⚠️ This method must NOT modify self if self is a Value type - `mutating` are not allowed
    func willEncode(to encoder: any Encoder) throws
}

extension ReerCodableDelegate {
    public func didDecode(from decoder: any Decoder) throws {}
    public func willEncode(to encoder: any Encoder) throws {}
}
