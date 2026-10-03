import SwiftUI
import UIKit

enum CarbInTheme {
    // Pixel Kitchen keeps playful display lettering on Latin scripts and lets
    // iOS shape the other supported scripts with their native system fonts.
    static let canvas = adaptive(light: rgb(0xFFF6D8), dark: rgb(0x211B27))
    static let loadingCanvas = adaptive(light: rgb(0xEC5C55), dark: rgb(0x663C51))
    static let surface = adaptive(light: rgb(0xFFFCF1), dark: rgb(0x332B39))
    static let ticket = adaptive(light: rgb(0xFFF2BB), dark: rgb(0x352D3B))
    static let inset = adaptive(light: rgb(0xFFE9A5), dark: rgb(0x443545))
    static let ink = adaptive(light: rgb(0x32202C), dark: rgb(0xFFF1DB))
    static let mutedInk = adaptive(light: rgb(0x6A4C50), dark: rgb(0xDBC9D1))
    static let basil = adaptive(light: rgb(0x17663C), dark: rgb(0xB9E8B0))
    static let basilAction = adaptive(light: rgb(0x237B49), dark: rgb(0x2A7A4E))
    static let basilSoft = adaptive(light: rgb(0xD9F4D6), dark: rgb(0x2A4A3B))
    static let tomato = adaptive(light: rgb(0xBA303D), dark: rgb(0xFFADB0))
    static let tomatoAction = adaptive(light: rgb(0xCD3D48), dark: rgb(0xC04B58))
    static let tomatoSoft = adaptive(light: rgb(0xFFEBDF), dark: rgb(0x493037))
    static let butter = adaptive(light: rgb(0xFFCA4C), dark: rgb(0xF4C35C))
    static let navy = adaptive(light: rgb(0x1C617D), dark: rgb(0x9BD3EC))
    static let line = adaptive(light: rgb(0x4B2A35), dark: rgb(0xB69BAD))
    static let actionInk = Color(red: 1, green: 0.973, blue: 0.914)

    @MainActor static var selectedLanguage: AppLanguage = .english

    @MainActor static func display(_ style: UIFont.TextStyle, size: CGFloat) -> Font {
        let usesPixelFace: Bool
        switch selectedLanguage {
        case .english, .french, .filipino, .spanish, .portuguese, .hungarian:
            usesPixelFace = true
        default:
            usesPixelFace = false
        }
        let retroFace = usesPixelFace
            ? (UIFont(name: "PixelifySans-Regular_Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .black))
            : UIFont.systemFont(ofSize: size, weight: .bold)
        return Font(UIFontMetrics(forTextStyle: style).scaledFont(for: retroFace))
    }

    private static func rgb(_ value: UInt32) -> (CGFloat, CGFloat, CGFloat) {
        (CGFloat((value >> 16) & 0xFF) / 255, CGFloat((value >> 8) & 0xFF) / 255, CGFloat(value & 0xFF) / 255)
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
            .foregroundStyle(isEnabled ? CarbInTheme.actionInk : CarbInTheme.mutedInk)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 54)
            .padding(.horizontal, 18)
            .background {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(isEnabled ? CarbInTheme.tomatoAction : CarbInTheme.inset)
                    .shadow(color: CarbInTheme.ink.opacity(isEnabled ? 0.35 : 0.16), radius: 0, x: 0, y: configuration.isPressed ? 1 : 4)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(CarbInTheme.line, lineWidth: 3)
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
        MealMirrorBadge()
            .accessibilityHidden(true)
    }
}

struct MealMirrorBadge: View {
    var showsStars = true

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            ZStack {
                Canvas { context, size in
                    let pixel = max(7, side / 14)
                    for row in 0...Int(ceil(size.height / pixel)) {
                        for column in 0...Int(ceil(size.width / pixel)) {
                            let color = (row + column).isMultiple(of: 2)
                                ? Color(red: 1, green: 0.88, blue: 0.48)
                                : Color(red: 1, green: 0.77, blue: 0.28)
                            context.fill(
                                Path(CGRect(x: CGFloat(column) * pixel, y: CGFloat(row) * pixel, width: pixel, height: pixel)),
                                with: .color(color)
                            )
                        }
                    }
                }
                .clipShape(Circle())
                .overlay { Circle().stroke(CarbInTheme.line, lineWidth: max(2, side * 0.025)) }
                .shadow(color: CarbInTheme.ink.opacity(0.26), radius: 0, x: 0, y: max(2, side * 0.025))
                .frame(width: side * 0.94, height: side * 0.94)

                Image("CurryMarkCutout")
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: side, height: side)

                if showsStars && side >= 100 {
                    PixelStar()
                        .frame(width: side * 0.075, height: side * 0.075)
                        .offset(x: -side * 0.42, y: -side * 0.35)
                    PixelStar()
                        .frame(width: side * 0.055, height: side * 0.055)
                        .offset(x: side * 0.42, y: -side * 0.25)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .accessibilityHidden(true)
    }
}

private struct PixelStar: View {
    var body: some View {
        GeometryReader { geometry in
            let unit = geometry.size.width / 5
            ZStack {
                Rectangle().fill(CarbInTheme.line)
                    .frame(width: unit * 1.8, height: geometry.size.height)
                Rectangle().fill(CarbInTheme.line)
                    .frame(width: geometry.size.width, height: unit * 1.8)
                Rectangle().fill(CarbInTheme.surface)
                    .frame(width: unit, height: geometry.size.height)
                Rectangle().fill(CarbInTheme.surface)
                    .frame(width: geometry.size.width, height: unit)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .accessibilityHidden(true)
    }
}

private enum PixelFoodKind: Int, CaseIterable {
    case tomato, carrot, broccoli, rice, egg, fish

    var rows: [String] {
        switch self {
        case .tomato:
            ["...ggg...", "..gGGGg..", ".xrrrrrx.", "xrrRrrrRx", "rrrrrrrrr", "rrrrrrrrr", ".rrrrrrr.", "..rrrrr..", "...xxx..."]
        case .carrot:
            ["ggg......", ".gGg.....", "..xxx....", "...oox...", "...ooox..", "....ooox.", ".....ooox", "......oox", ".......xx"]
        case .broccoli:
            ["..ggggg..", ".gGgGgGg.", "ggggggggg", ".ggggggg.", "..ggggg..", "...xxx...", "...bbb...", "...bbb...", "....x...."]
        case .rice:
            [".........", "..wwwww..", ".wwwwwww.", "wwwwwwwww", "xwwwwwwwx", ".xxxxxxx.", "..bbbbb..", "...bbb...", "....x...."]
        case .egg:
            [".........", "..wwwww..", ".wwwwwww.", "wwwyyywww", "wwyyyyyww", "wwwyyywww", ".wwwwwww.", "..wwwww..", "........."]
        case .fish:
            ["....uuu..", "..uuuuuu.", "xuuuUuuux", "xuuwwuuux", "xuuuUuuux", "..uuuuuu.", "....uuu..", "......x..", "........."]
        }
    }
}

private struct PixelFoodGlyph: View {
    let kind: PixelFoodKind

    var body: some View {
        Canvas { context, size in
            let rows = kind.rows
            let pixel = min(size.width, size.height) / 9
            for (y, row) in rows.enumerated() {
                for (x, symbol) in row.enumerated() where symbol != "." {
                    context.fill(
                        Path(CGRect(x: CGFloat(x) * pixel, y: CGFloat(y) * pixel, width: pixel, height: pixel)),
                        with: .color(color(for: symbol))
                    )
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func color(for symbol: Character) -> Color {
        switch symbol {
        case "x": Color(red: 0.18, green: 0.10, blue: 0.15)
        case "g": Color(red: 0.07, green: 0.55, blue: 0.24)
        case "G": Color(red: 0.28, green: 0.77, blue: 0.38)
        case "r": Color(red: 0.88, green: 0.22, blue: 0.27)
        case "R": Color(red: 1, green: 0.48, blue: 0.43)
        case "o": Color(red: 1, green: 0.49, blue: 0.12)
        case "w": Color(red: 1, green: 0.97, blue: 0.82)
        case "y": Color(red: 1, green: 0.70, blue: 0.17)
        case "b": Color(red: 0.58, green: 0.32, blue: 0.18)
        case "u": Color(red: 0.19, green: 0.50, blue: 0.69)
        default: Color(red: 0.42, green: 0.75, blue: 0.89)
        }
    }
}

struct FoodOrbitRing: View {
    var diameter: CGFloat = 286
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isRotating = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(CarbInTheme.actionInk.opacity(0.85), style: StrokeStyle(lineWidth: 3, dash: [8, 9]))
                .frame(width: diameter - 26, height: diameter - 26)

            ForEach(PixelFoodKind.allCases, id: \.rawValue) { food in
                let angle = Double(food.rawValue) * 2 * Double.pi / Double(PixelFoodKind.allCases.count)
                PixelFoodGlyph(kind: food)
                    .frame(width: 34, height: 34)
                    .padding(3)
                    .background(CarbInTheme.surface, in: Circle())
                    .overlay { Circle().stroke(CarbInTheme.line, lineWidth: 2) }
                    .offset(x: CGFloat(cos(angle)) * (diameter / 2 - 13), y: CGFloat(sin(angle)) * (diameter / 2 - 13))
            }
        }
        .frame(width: diameter, height: diameter)
        .rotationEffect(.degrees(isRotating && !reduceMotion ? 360 : 0))
        .animation(reduceMotion ? nil : .linear(duration: 14).repeatForever(autoreverses: false), value: isRotating)
        .onAppear { isRotating = !reduceMotion }
        .onChange(of: reduceMotion) { _, newValue in isRotating = !newValue }
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
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(CarbInTheme.surface)
                    .shadow(color: CarbInTheme.ink.opacity(0.16), radius: 0, x: 0, y: 4)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(CarbInTheme.line, lineWidth: 3)
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
