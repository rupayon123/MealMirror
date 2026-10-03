// swift-tools-version: 6.0

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "MealMirror",
    defaultLocalization: "en",
    platforms: [.iOS("17.0")],
    products: [
        .iOSApplication(
            name: "MealMirror",
            targets: ["AppModule"],
            bundleIdentifier: "com.mealmirror.swiftchallenge",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .asset("AccentColor"),
            supportedDeviceFamilies: [.phone, .pad],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            additionalInfoPlistContentFilePath: "Info.plist"
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: ["OnboardingCore", "MealCore", "NavigationCore"],
            path: ".",
            exclude: [
                "AI-AND-ASSET-DISCLOSURE.md",
                "MealCore",
                "NavigationCore",
                "OnboardingCore",
                "README.md",
                "Fonts/PixelifySans-OFL.txt",
                "Fonts/Nunito-OFL.txt",
            ],
            resources: [
                .copy("Assets/biryani-demo.png"),
                .copy("Assets/grain-bowl-demo.png"),
                .copy("Assets/breakfast-demo.png"),
                .process("Assets/Brand.xcassets"),
                .process("Fonts/PixelifySans.ttf"),
                .process("Fonts/Nunito.ttf"),
                .process("Resources")
            ]
        ),
        .target(name: "OnboardingCore", path: "OnboardingCore"),
        .target(name: "MealCore", path: "MealCore"),
        .target(name: "NavigationCore", path: "NavigationCore")
    ],
    swiftLanguageModes: [.v6]
)
