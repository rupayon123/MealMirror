import SwiftUI

// Original floating pixel objects; compact roles have separate drawings rather
// than downscaled detailed art. Native appearance selects the bundled variant.
enum PixelKitchenIconKind: String, CaseIterable {
    case camera, photos, history, info, settings, check, adjust, review
    case replay, privacy, medical, details, delete, save
    case foodView, nutritionLabel, addPhoto, removePhoto
    case reviewPendingRecord, reviewSavedRecord

    var assetName: String { "MMObject_" + rawValue }

    var compactAssetName: String? {
        switch self {
        case .camera, .photos, .foodView, .nutritionLabel,
             .reviewPendingRecord, .reviewSavedRecord:
            assetName + "_compact"
        default:
            nil
        }
    }
}

struct PixelKitchenIcon: View {
    let kind: PixelKitchenIconKind

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let asset = side < 32 ? (kind.compactAssetName ?? kind.assetName) : kind.assetName
            Image(asset)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .accessibilityHidden(true)
    }
}

// Kept as a call-site wrapper; the artwork floats without another badge border.
struct PixelKitchenIconBadge: View {
    let kind: PixelKitchenIconKind
    var size: CGFloat = 44

    var body: some View {
        PixelKitchenIcon(kind: kind)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

struct PixelKitchenActionLabel: View {
    let title: LocalizedStringKey
    let kind: PixelKitchenIconKind

    var body: some View {
        Label {
            Text(title)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            PixelKitchenIconBadge(kind: kind, size: 40)
        }
    }
}
