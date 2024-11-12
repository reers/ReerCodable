//
//  CodableDelegate.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/12.
//

public protocol CodableDelegate {
    func didDecodeModel() throws
    func willEncodeModel() throws
}

extension CodableDelegate {
    func didDecodeModel() throws {}
    func willEncodeModel() throws {}
}
