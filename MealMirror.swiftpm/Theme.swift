import SwiftUI
import UIKit

enum CarbInTheme {
    // Pixel Pantry: the warmth and clear block shapes of a cooking game,
    // grounded by roomy native controls and high-contrast reading surfaces.
    static let canvas = adaptive(light: (1.0, 0.953, 0.843), dark: (0.075, 0.071, 0.082))
    static let surface = adaptive(light: (1.0, 0.988, 0.949), dark: (0.145, 0.133, 0.145))
    static let ticket = adaptive(light: (1.0, 0.969, 0.890), dark: (0.180, 0.157, 0.157))
    static let inset = adaptive(light: (0.949, 0.875, 0.737), dark: (0.102, 0.106, 0.122))
    static let ink = adaptive(light: (0.176, 0.122, 0.141), dark: (0.988, 0.965, 0.914))
    static let mutedInk = adaptive(light: (0.345, 0.251, 0.239), dark: (0.804, 0.741, 0.706))
    static let basil = adaptive(light: (0.125, 0.333, 0.420), dark: (0.498, 0.812, 0.831))
    static let basilSoft = adaptive(light: (0.773, 0.914, 0.910), dark: (0.125, 0.251, 0.267))
    static let tomato = adaptive(light: (0.753, 0.149, 0.231), dark: (1.0, 0.482, 0.569))
    static let tomatoSoft = adaptive(light: (0.980, 0.757, 0.631), dark: (0.345, 0.133, 0.106))
    static let butter = adaptive(light: (0.596, 0.333, 0.039), dark: (1.0, 0.788, 0.369))
    static let navy = adaptive(light: (0.090, 0.290, 0.345), dark: (0.537, 0.812, 0.843))
    static let line = adaptive(light: (0.478, 0.333, 0.271), dark: (0.365, 0.325, 0.341))
    static func display(_ style: UIFont.TextStyle, size: CGFloat) -> Font {
        let retroFace = UIFont(name: "MarkerFelt-Wide", size: size) ?? UIFont.systemFont(ofSize: size, weight: .black)
        return Font(UIFontMetrics(forTextStyle: style).scaledFont(for: retroFace))
    }

    // Compatibility names used by the existing feature code.
    static let elevatedSurface = inset
    static let moss = basil
    static let mossSoft = basilSoft
    static let terracotta = tomato
    static let amber = butter
    static let pine = basil
    static let oat = inset

    static func adaptive(light: (CGFloat, CGFloat, CGFloat), dark: (CGFloat, CGFloat, CGFloat)) -> Color {
        Color(
            uiColor: UIColor { traits in
                let value = traits.userInterfaceStyle == .dark ? dark : light
                return UIColor(red: value.0, green: value.1, blue: value.2, alpha: 1)
            }
        )
    }
}

struct CountertopBackdrop: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 32
            let tile: CGFloat = 3
            var x: CGFloat = 16
            while x < size.width {
                var y: CGFloat = 12
                while y < size.height {
                    let alternate = Int(x / spacing + y / spacing).isMultiple(of: 2)
                    let rect = CGRect(x: x, y: y, width: alternate ? tile : 1.5, height: alternate ? tile : 1.5)
                    context.fill(Path(rect), with: .color(CarbInTheme.line.opacity(alternate ? 0.11 : 0.05)))
                    y += spacing
                }
                x += spacing
            }
        }
        .background(CarbInTheme.canvas)
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct PrimaryActionStyle: ButtonStyle {
    var isEnabled = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CarbInTheme.display(.headline, size: 17))
            .foregroundStyle(isEnabled ? CarbInTheme.surface : CarbInTheme.mutedInk)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 54)
            .padding(.horizontal, 18)
            .background {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(isEnabled ? CarbInTheme.tomato : CarbInTheme.inset)
                    .shadow(color: CarbInTheme.ink.opacity(isEnabled ? 0.35 : 0.16), radius: 0, x: 0, y: configuration.isPressed ? 1 : 4)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(CarbInTheme.ink.opacity(0.85), lineWidth: 2)
            }
            .offset(y: configuration.isPressed ? 3 : 0)
            .opacity(configuration.isPressed ? 0.92 : 1)
    }
}

struct SecondaryActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(CarbInTheme.basil)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .padding(.horizontal, 18)
            .background {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(CarbInTheme.surface)
                    .shadow(color: CarbInTheme.ink.opacity(0.22), radius: 0, x: 0, y: configuration.isPressed ? 1 : 3)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(CarbInTheme.basil, lineWidth: 2)
            }
            .offset(y: configuration.isPressed ? 2 : 0)
            .opacity(configuration.isPressed ? 0.74 : 1)
    }
}

struct CompactActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(CarbInTheme.ink)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 46)
            .padding(.horizontal, 12)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(CarbInTheme.ticket)
                    .shadow(color: CarbInTheme.ink.opacity(0.16), radius: 0, x: 0, y: configuration.isPressed ? 0 : 2)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(CarbInTheme.line.opacity(0.90), lineWidth: 1.5)
            }
            .opacity(configuration.isPressed ? 0.70 : 1)
    }
}

struct MealPlateGraphic: View {
    var showsPen = false

    var body: some View {
        Image("LaunchMark")
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .overlay { Rectangle().stroke(CarbInTheme.ink.opacity(0.65), lineWidth: 1.5) }
            .shadow(color: CarbInTheme.ink.opacity(0.20), radius: 0, x: 0, y: 3)
            .accessibilityHidden(true)
    }
}

struct PixelCornerFrame: View {
    var color: Color = CarbInTheme.tomato
    var inset: CGFloat = 10
    var arm: CGFloat = 16
    var thickness: CGFloat = 3

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                pixelCorner
                Spacer(minLength: 0)
                pixelCorner.rotationEffect(.degrees(90))
            }
            Spacer(minLength: 0)
            HStack(spacing: 0) {
                pixelCorner.rotationEffect(.degrees(270))
                Spacer(minLength: 0)
                pixelCorner.rotationEffect(.degrees(180))
            }
        }
        .padding(inset)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var pixelCorner: some View {
        ZStack(alignment: .topLeading) {
            Rectangle().fill(color).frame(width: arm, height: thickness)
            Rectangle().fill(color).frame(width: thickness, height: arm)
        }
    }
}

struct PixelDivider: View {
    var color: Color = CarbInTheme.tomato

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<15, id: \.self) { index in
                Rectangle()
                    .fill(index.isMultiple(of: 4) ? color : CarbInTheme.line.opacity(0.55))
                    .frame(width: index.isMultiple(of: 4) ? 11 : 5, height: 3)
            }
        }
        .frame(maxWidth: 210, alignment: .leading)
        .accessibilityHidden(true)
    }
}

struct StepRail: View {
    let current: Int
    @EnvironmentObject private var localization: LocalizationStore

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 6) {
                stage(1, title: "Description", showsTitle: true)
                connector(active: current > 1)
                stage(2, title: "Your estimate", showsTitle: true)
                connector(active: current > 2)
                stage(3, title: "Review", showsTitle: true)
            }
            HStack(spacing: 8) {
                stage(1, title: "Description", showsTitle: false)
                connector(active: current > 1)
                stage(2, title: "Your estimate", showsTitle: false)
                connector(active: current > 2)
                stage(3, title: "Review", showsTitle: false)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(localization.text(["STEP 1 OF 3", "STEP 2 OF 3", "STEP 3 OF 3"][max(0, min(current - 1, 2))]))
    }

    private func stage(_ number: Int, title: String, showsTitle: Bool) -> some View {
        HStack(spacing: 7) {
            Text(verbatim: "\(number)")
                .font(.system(.caption2, design: .monospaced).weight(.black))
                .foregroundStyle(number <= current ? CarbInTheme.surface : CarbInTheme.mutedInk)
                .frame(width: 25, height: 25)
                .background(number <= current ? CarbInTheme.tomato : CarbInTheme.inset)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            if showsTitle {
                Text(localization.text(title))
                    .font(.caption.weight(number == current ? .bold : .medium))
                    .foregroundStyle(number == current ? CarbInTheme.ink : CarbInTheme.mutedInk)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
    }

    private func connector(active: Bool) -> some View {
        Rectangle()
            .fill(active ? CarbInTheme.tomato : CarbInTheme.line.opacity(0.45))
            .frame(maxWidth: 34, minHeight: 2, maxHeight: 2)
            .accessibilityHidden(true)
    }
}

struct SafetyRail: View {
    let title: LocalizedStringKey
    let detail: LocalizedStringKey
    var symbol = "exclamationmark.shield.fill"

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(CarbInTheme.tomato)
                .frame(width: 5)
            Image(systemName: symbol)
                .foregroundStyle(CarbInTheme.tomato)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(CarbInTheme.display(.subheadline, size: 15))
                    .foregroundStyle(CarbInTheme.ink)
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(CarbInTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 12)
        .padding(.trailing, 12)
        .background(CarbInTheme.ticket)
            .overlay { Rectangle().stroke(CarbInTheme.ink.opacity(0.78), lineWidth: 2) }
    }
}

private struct TicketEdge: View {
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<42, id: \.self) { index in
                Rectangle()
                    .fill(index.isMultiple(of: 2) ? CarbInTheme.tomato : CarbInTheme.butter)
                    .frame(maxWidth: .infinity, minHeight: 4, maxHeight: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .clipped()
        .accessibilityHidden(true)
    }
}

extension View {
    func workbenchSurface(inset: CGFloat = 18) -> some View {
        self.padding(inset)
            .background {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(CarbInTheme.surface)
                    .shadow(color: CarbInTheme.ink.opacity(0.16), radius: 0, x: 0, y: 4)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(CarbInTheme.basil.opacity(0.78), lineWidth: 2.5)
            }
    }

    func mealTicket(inset: CGFloat = 18) -> some View {
        self.padding(inset)
            .background(CarbInTheme.ticket, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            .overlay(alignment: .top) { TicketEdge() }
            .overlay(alignment: .bottom) { TicketEdge() }
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(CarbInTheme.ink.opacity(0.86), lineWidth: 2)
            }
    }

    func insetControlGroup(inset: CGFloat = 14) -> some View {
        self.padding(inset)
            .background(CarbInTheme.butter.opacity(0.20), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(CarbInTheme.line.opacity(0.72), lineWidth: 1.5)
            }
    }

    // Legacy call sites now receive the distinctive ticket surface rather than
    // the former universal 24-point floating card.
    func mirrorCard(inset: CGFloat = 18) -> some View {
        mealTicket(inset: inset)
    }

    func pixelCorners(color: Color = CarbInTheme.tomato, inset: CGFloat = 10) -> some View {
        overlay { PixelCornerFrame(color: color, inset: inset) }
    }
}
