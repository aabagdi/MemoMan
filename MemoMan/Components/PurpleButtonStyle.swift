//
//  PurpleButtonStyle.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/6/24.
//

import SwiftUI

struct PurpleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32))
            .foregroundStyle(.white)
            .background(Color(red: 166/255, green: 104/255, blue: 247/255))
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.90 : 1)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}
