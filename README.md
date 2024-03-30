# Setup

**Add this to your dependencies:**
```swift
dependencies: [
    .package(
        url: "https://github.com/colbyn/SwiftPrettyTree.git",
        from: "0.4.0" // THIS MAY BE OUT OF DATE; USE LATEST VERSION
    )
],
```

**Then for your given target:**
```swift
targets: [
    .target(
        name: "SomeName",
        dependencies: [
            "SwiftPrettyTree"
        ]
    ),
]
```