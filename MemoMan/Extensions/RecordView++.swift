//
//  RecordView++.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/6/24.
//

import Foundation

extension RecordView {
    func circleSize(for power: Float, maxWidth: CGFloat) -> CGFloat {
        let minSize: CGFloat = maxWidth / 4
        let maxSize: CGFloat = maxWidth * 0.90
        return minSize + (maxSize - minSize) * CGFloat(power)
    }
}
