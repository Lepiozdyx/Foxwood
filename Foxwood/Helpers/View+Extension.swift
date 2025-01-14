//
//  View+Extension.swift
//  Foxwood
//
//  Created by Alex on 13.01.2025.
//

import SwiftUI

struct ButtonSoundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture().onEnded {
                    SoundManager.shared.playSound()
                }
            )
    }
}
extension View {
    func playSound() -> some View {
        modifier(ButtonSoundModifier())
    }
}
