// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "FlexibleSteppedProgressBar",
    platforms: [
        .iOS(.v8),
    ],
    products: [
        .library(
            name: "FlexibleSteppedProgressBar",
            targets: ["FlexibleSteppedProgressBar"]),
    ],    
    targets: [
        .target(
            name: "FlexibleSteppedProgressBar",                 
            path: "FlexibleSteppedProgressBar"          
            ),
    ],
    swiftLanguageVersions: [.v5]
)