//
//  WaveformView.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/14/24.
//

import SwiftUI

struct WaveformView: View {
    @Binding var progress: Double
    
    let recording : Recording
    let duration : TimeInterval
    let onEditingChanged : (Bool) -> Void
    let scaleFactor : CGFloat
    let waveformHeight : CGFloat
    let minHeight : CGFloat = 1.0
    
    var body: some View {
        GeometryReader { g in
            let width = g.size.width
            let height = waveformHeight
            let barWidth = width / CGFloat(recording.samples?.count ?? 0)
            
            ZStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(recording.samples?.indices ?? 0..<1, id: \.self) { index in
                        let sampleValue = recording.samples?[index] ?? 0.0
                        let normalizedValue = CGFloat(sampleValue).isFinite ? CGFloat(sampleValue) : 0
                        let scaledValue = scaleSample(normalizedValue)
                        let sampleHeight = max(scaledValue * height, minHeight)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index < Int(CGFloat(recording.samples?.count ?? 0) * CGFloat(progress)) ? Color("MemoManPurple") : Color.gray)
                            .frame(width: barWidth, height: sampleHeight)
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
        .frame(height: waveformHeight)
    }
    
    private func scaleSample(_ sample: CGFloat) -> CGFloat {
        let logBase: CGFloat = 10
        let minLog = log(0.01) / log(logBase)
        let maxLog = log(1) / log(logBase)
        
        let logScale = (log(max(sample, 0.01)) / log(logBase) - minLog) / (maxLog - minLog)
        
        let blendFactor: CGFloat = 0.7
        let linearScale = sample
        
        let blendedScale = blendFactor * logScale + (1 - blendFactor) * linearScale
        
        return blendedScale * scaleFactor
    }
}
