//
//  CodableDelegate.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/12.
//

public protocol CodableDelegate {
    func didDecode() throws
    func willEncode() throws
}

extension CodableDelegate {
    public func didDecode() throws {}
    public func willEncode() throws {}
}
