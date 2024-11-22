//
//  ReerCodableDelegate.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/12.
//

public protocol ReerCodableDelegate {
    func didDecode(from decoder: any Decoder) throws
    func willEncode(to encoder: any Encoder) throws
}

extension ReerCodableDelegate {
    public func didDecode(from decoder: any Decoder) throws {}
    public func willEncode(to encoder: any Encoder) throws {}
}
