//
//  WaveformView.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/14/24.
//

import SwiftUI

struct WaveformView: View {
    let samples: [Float]
    @Binding var progress: Double
    let duration: TimeInterval
    let onEditingChanged: (Bool) -> Void
    let scaleFactor: CGFloat
    let maxHeight: CGFloat
    let minHeight: CGFloat = 2.5
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = min(geometry.size.height, maxHeight)
            let barWidth = width / CGFloat(samples.count)
            
            ZStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(samples.indices, id: \.self) { index in
                        let sample = samples[index]
                        RoundedRectangle(cornerRadius: 10)
                            .fill(index < Int(CGFloat(samples.count) * CGFloat(progress)) ? Color("MemoManPurple") : Color.gray)
                            .frame(width: barWidth, height: max(min(CGFloat(sample) * height * scaleFactor, height), minHeight)) // Apply the scaling factor and ensure minimum height
                    }
                }
            }
            .background(GeometryReader {
                Color.clear.preference(key: SizePreferenceKey.self, value: $0.size)
            })
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
