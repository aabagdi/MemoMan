//
//  Recording+Transferable.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 6/29/24.
//

import Foundation
import CoreTransferable

extension Recording : Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.name!)
        }
}
