//
//  Theme.swift
//  ScatterBrainVVD
//
//  "Daybook" design tokens (DESIGN.md section 2): colours, type, and the button/card styles
//  built directly on them.
//

import SwiftUI
import UIKit

enum Theme {

    // UIColor provider so every token re-resolves on a light/dark switch
    private static func pair(_ light: UInt, _ dark: UInt) -> Color {
        func ui(_ hex: UInt) -> UIColor {
            UIColor(red:   CGFloat((hex >> 16) & 0xFF) / 255,
                    green: CGFloat((hex >> 8)  & 0xFF) / 255,
                    blue:  CGFloat( hex        & 0xFF) / 255,
                    alpha: 1)
        }
        return Color(UIColor { $0.userInterfaceStyle == .dark ? ui(dark) : ui(light) })
    }

    // ---------------------------------------------------------------------------------------------------------------------
    // COLOUR
    // ---------------------------------------------------------------------------------------------------------------------

    static let bg          = pair(0xF6F2EA, 0x121110)
    static let surface     = pair(0xFFFDF8, 0x1C1B19)
    static let sunken      = pair(0xECE6DA, 0x282623)
    static let text1       = pair(0x1B1A17, 0xF2EEE6)
    static let text2       = pair(0x5C574E, 0xB4ADA1)
    static let text3       = pair(0x6F685D, 0x969085)
    static let separator   = pair(0xDDD5C6, 0x34312D)
    static let control     = pair(0x8A8377, 0x857F75)
    static let accent      = pair(0xB93A0E, 0xFF7A45)
    static let onAccent    = pair(0xFFFFFF, 0x1B1A17)
    static let success     = pair(0x2F6B3F, 0x6FCF8A)
    static let warning     = pair(0x8A5A00, 0xF0B45A)
    static let destructive = pair(0xB3261E, 0xFF6B60)

    // ---------------------------------------------------------------------------------------------------------------------
    // TYPE (all system text styles, so they scale with Dynamic Type)
    // ---------------------------------------------------------------------------------------------------------------------

    static let screenTitle  = Font.system(.title, design: .serif, weight: .semibold)
    static let detailTitle  = Font.system(.title2, design: .serif, weight: .semibold)
    static let body         = Font.system(.body)
    static let button       = Font.system(.headline)
    static let meta         = Font.system(.footnote)
    static let sectionLabel = Font.system(.caption, weight: .semibold)
    static let value        = Font.system(.subheadline, design: .monospaced, weight: .medium)
    static let bigValue     = Font.system(.title, design: .monospaced, weight: .medium)
    static let tabLabel     = Font.system(.caption2, weight: .medium)
    static let icon         = Font.system(.body, weight: .semibold)
}

// ---------------------------------------------------------------------------------------------------------------------
// CARD
// ---------------------------------------------------------------------------------------------------------------------

struct CardMod: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Theme.separator, lineWidth: 1)
            )
    }
}

extension View {
    func card() -> some View {
        modifier(CardMod())
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// BUTTON STYLES
// ---------------------------------------------------------------------------------------------------------------------

// Shared press (opacity 0.7, 100ms) and disabled (40%) treatment
private struct PressFade: ViewModifier {
    let pressed: Bool
    @Environment(\.isEnabled) private var isEnabled

    func body(content: Content) -> some View {
        content
            .opacity(isEnabled ? (pressed ? 0.7 : 1) : 0.4)
            .animation(.linear(duration: 0.1), value: pressed)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var fill: Color = Theme.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.button)
            .foregroundStyle(Theme.onAccent)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(fill, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .modifier(PressFade(pressed: configuration.isPressed))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var destructive: Bool = false
    // false = intrinsic width at the 44pt minimum (empty-state buttons)
    var fullWidth: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.button)
            .foregroundStyle(destructive ? Theme.destructive : Theme.text1)
            .padding(.horizontal, 16)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: fullWidth ? 50 : 44)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Theme.separator, lineWidth: 1)
            )
            .contentShape(Rectangle())
            .modifier(PressFade(pressed: configuration.isPressed))
    }
}

struct ChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.value)
            .foregroundStyle(Theme.text1)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Theme.sunken, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .modifier(PressFade(pressed: configuration.isPressed))
    }
}

// Press feedback only, for custom-drawn buttons (rows, icons, check controls)
struct FadeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(PressFade(pressed: configuration.isPressed))
    }
}
