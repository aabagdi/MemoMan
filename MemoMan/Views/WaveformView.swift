//
//  WaveformView.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/14/24.
//

import SwiftUI

struct WaveformView: View {
    let recording : Recording
    @Binding var progress: Double
    let duration : TimeInterval
    let onEditingChanged : (Bool) -> Void
    let scaleFactor : CGFloat
    let maxHeight : CGFloat
    let minHeight : CGFloat = 2.5
    
    var body: some View {
        GeometryReader { g in
            let width = g.size.width
            let height = min(g.size.height, maxHeight)
            let barWidth = width / CGFloat(recording.samples?.count ?? 0)
            
            ZStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(recording.samples?.indices ?? 0..<1, id: \.self) { index in
                        let sample = recording.samples?[index]
                        RoundedRectangle(cornerRadius: 3)
                            .fill(index < Int(CGFloat(recording.samples?.count ?? 0) * CGFloat(progress)) ? Color("MemoManPurple") : Color.gray)
                            .frame(width: barWidth, height: max(min(CGFloat(sample ?? 0.0) * height * scaleFactor, height), minHeight))
                    }
                }
            }
            .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let newProgress = max(0, min(Double(value.location.x / width), 1))
                            progress = newProgress
                            onEditingChanged(true)
                        }
                        .onEnded { _ in
                            onEditingChanged(false)
                        }
            )
        }
        .frame(maxHeight: maxHeight)
    }
}
