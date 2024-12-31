//
//  Style.swift
//  msgame
//
//  Created by chunlei on 30/12/2024.
//


import SwiftUI

struct GameTextStyle: ViewModifier {
    var size: CGFloat
    var weight: Font.Weight
    var color: Color = .purple
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight))
            .foregroundColor(color)
    }
}
