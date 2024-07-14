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
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let barWidth = width / CGFloat(samples.count)
            
            ZStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(samples.indices, id: \.self) { index in
                        let sample = samples[index]
                        RoundedRectangle(cornerRadius: 10)
                            .fill(index < Int(CGFloat(samples.count) * CGFloat(progress)) ? Color("MemoManPurple") : Color.gray)
                            .frame(width: barWidth, height: min(CGFloat(sample) * height * scaleFactor, height)) // Apply the scaling factor
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
    }
}


