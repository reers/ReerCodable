//
//  ReerCodableDelegate.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/12.
//

public protocol ReerCodableDelegate {
    func didDecode() throws
    func willEncode() throws
}

extension ReerCodableDelegate {
    public func didDecode() throws {}
    public func willEncode() throws {}
}
