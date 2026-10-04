import SwiftUI

// Small, hand-plotted utility sprites share the loading ring's 12 × 12 grid.
// They carry no text, so every language keeps its own readable button label.
enum PixelKitchenIconKind {
    case camera, photos, history, info, settings, check

    var rows: [String] {
        switch self {
        case .camera:
            ["............", "...kkkk.....", "..krrrrk....", ".krrrrrrkkkk",
             "krrwwrrrrrrk", "krrwkkkkrrrk", "krrwkYYkrrrk", "krrwkYYkrrrk",
             "krrwkkkkrrrk", "krrrrrrrrrrk", ".kkkkkkkkkk.", "............"]
        case .photos:
            ["...kkkkkkkk.", "...kwwwwwwk.", "...kwywwBBk.", "...kwwggBBk.",
             ".kkkkkkkkkk.", ".kwwwwwwwwk.", ".kwwYwwwwwk.", ".kwwwgggwwk.",
             ".kwggGGggwk.", ".kggGGGGggk.", ".kkkkkkkkkk.", "............"]
        case .history:
            ["...kkkkkk...", "...kwwwwk...", "...kwggwk...", "...kwwwwk...",
             "...kwwwwk...", "..kkkkkkkk..", ".kggggggggk.", "kggggggggggk",
             "kgggkkkkgggk", "kggggggggggk", ".kkkkkkkkkk.", "............"]
        case .info:
            ["...kkkkkk...", "..kggggggk..", ".kggggggggk.", "kgggkkkkgggk",
             "kgggkYYkgggk", "kggggYYggggk", "kggggkkggggk", "kggggYYggggk",
             "kggggYYggggk", ".kggggggggk.", "..kggggggk..", "...kkkkkk..."]
        case .settings:
            ["....kkkk....", "..kkggggkk..", ".kgggkkgggk.", "kgggkkkkgggk",
             "kggkkwwkkggk", "kggkwYYwkggk", "kggkwYYwkggk", "kggkkwwkkggk",
             "kgggkkkkgggk", ".kgggkkgggk.", "..kkggggkk..", "....kkkk...."]
        case .check:
            ["............", ".........kk.", "........kGk.", ".......kGGk.",
             "..kk..kGGk..", ".kGGkkGGk...", "kGGGGGGk....", ".kGGGGk.....",
             "..kGGk......", "...kk.......", "............", "............"]
        }
    }
}

struct PixelKitchenIcon: View {
    let kind: PixelKitchenIconKind

    var body: some View {
        Canvas { context, size in
            let cell = min(size.width, size.height) / 12
            for (rowIndex, row) in kind.rows.enumerated() {
                for (columnIndex, symbol) in row.enumerated() where symbol != "." {
                    let rect = CGRect(
                        x: CGFloat(columnIndex) * cell,
                        y: CGFloat(rowIndex) * cell,
                        width: cell,
                        height: cell
                    )
                    context.fill(Path(rect), with: .color(color(for: symbol)))
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func color(for symbol: Character) -> Color {
        switch symbol {
        case "k": Color(red: 0.196, green: 0.118, blue: 0.165)
        case "r": Color(red: 0.804, green: 0.239, blue: 0.282)
        case "w": Color(red: 1.000, green: 0.980, blue: 0.898)
        case "Y": Color(red: 1.000, green: 0.796, blue: 0.243)
        case "y": Color(red: 0.929, green: 0.620, blue: 0.125)
        case "g": Color(red: 0.137, green: 0.482, blue: 0.286)
        case "G": Color(red: 0.333, green: 0.733, blue: 0.369)
        case "B": Color(red: 0.380, green: 0.725, blue: 0.780)
        default: .clear
        }
    }
}

struct PixelKitchenIconBadge: View {
    let kind: PixelKitchenIconKind
    var size: CGFloat = 44

    var body: some View {
        PixelKitchenIcon(kind: kind)
            .frame(width: size - 8, height: size - 8)
            .frame(width: size, height: size)
            .background(Color(red: 1.000, green: 0.980, blue: 0.898), in: RoundedRectangle(cornerRadius: 6))
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(CarbInTheme.line, lineWidth: 2)
            }
            .accessibilityHidden(true)
    }
}
