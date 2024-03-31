# PrettyTree - Swift Library for Rendering Trees

PrettyTree is a Swift library designed to render trees in a neatly formatted text representation. It supports rendering complex tree structures with labels, values, nested arrays, and custom data types, making it ideal for debugging or visualizing hierarchical data.

## Features

- Support for various built-in data types including `String`, `Character`, `Int`, `UInt`, `UUID`, `Date`, and more through the `ToPrettyTree` protocol.
- Customizable tree branches with labels and children for detailed structural visualization.
- Extension support for custom data types to fit specific visualization needs.
- Neatly formatted output with support for branches and leaf nodes, enhancing readability.

## Installation

To include PrettyTree in your Swift project, add it as a dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(
        url: "https://github.com/colbyn/SwiftPrettyTree.git",
        .upToNextMajor(from: "0.4.0")
    )
]
```

## Usage

### Basic Example

```swift
import PrettyTree

// Create a tree structure
let tree = PrettyTree(label: "Root", children: [
    PrettyTree(value: "Child 1"),
    PrettyTree(label: "Subtree", children: [
        PrettyTree(value: "Subchild 1"),
        PrettyTree(value: "Subchild 2"),
    ]),
    PrettyTree(label: "Subtree with Array", children: [
        [1, 2, 3].asPrettyTree,
        ["a", "b", "c"].asPrettyTree
    ])
])

// Render the tree to a string
let renderedTree = tree.format()

// Print the rendered tree
print(renderedTree)
```

**Output:**
```
Root
├╼ Child 1
├╼ Subtree
│  ├╼ Subchild 1
│  ╰╼ Subchild 2
╰╼ Subtree with Array
   ├╼ Array
   │  ├╼ 1
   │  ├╼ 2
   │  ╰╼ 3
   ╰╼ Array
      ├╼ "a"
      ├╼ "b"
      ╰╼ "c"
```

### Custom Data Type Example

```swift
struct Person {
    var name: String
    var age: Int
    var children: [Person]
}

extension Person: ToPrettyTree {
    var asPrettyTree: PrettyTree {
        let childrenTrees = children.map { $0.asPrettyTree }
        return PrettyTree(label: "\(name) (Age: \(age))", children: childrenTrees)
    }
}

// Create a family tree
let familyTree = Person(
    name: "Eleanor Rigby",
    age: 76,
    children: [
        Person(
            name: "James Rigby",
            age: 50,
            children: [
                Person(
                    name: "Olivia Rigby",
                    age: 30,
                    children: [
                        Person(name: "Mason Rigby", age: 5, children: []),
                        Person(name: "Eva Rigby", age: 3, children: [])
                    ]
                ),
                Person(
                    name: "Ethan Rigby",
                    age: 28,
                    children: [
                        Person(name: "Sophia Rigby", age: 2, children: [])
                    ]
                )
            ]
        ),
        Person(
            name: "Charlotte Rigby",
            age: 48,
            children: [
                Person(
                    name: "Liam Rigby",
                    age: 25,
                    children: [
                        Person(name: "Isabella Rigby", age: 1, children: [])
                    ]
                ),
                Person(name: "Emma Rigby", age: 22, children: [])
            ]
        ),
        Person(
            name: "William Rigby",
            age: 46,
            children: [
                Person(
                    name: "Amelia Rigby",
                    age: 20,
                    children: []
                ),
                Person(
                    name: "Benjamin Rigby",
                    age: 18,
                    children: []
                )
            ]
        )
    ]
)

// Render the family tree
let renderedTree = familyTree.asPrettyTree.format()

// Print the rendered tree
print(renderedTree)
```

**Output:**
```
Eleanor Rigby (Age: 76)
├╼ James Rigby (Age: 50)
│  ├╼ Olivia Rigby (Age: 30)
│  │  ├╼ Mason Rigby (Age: 5)
│  │  ╰╼ Eva Rigby (Age: 3)
│  ╰╼ Ethan Rigby (Age: 28)
│     ╰╼ Sophia Rigby (Age: 2)
├╼ Charlotte Rigby (Age: 48)
│  ├╼ Liam Rigby (Age: 25)
│  │  ╰╼ Isabella Rigby (Age: 1)
│  ╰╼ Emma Rigby (Age: 22)
╰╼ William Rigby (Age: 46)
   ├╼ Amelia Rigby (Age: 20)
   ╰╼ Benjamin Rigby (Age: 18)
```

## Contributing

Contributions to the PrettyTree library are welcome! Here are a few ways you can help:

- Reporting bugs or issues.
- Suggesting new features or improvements.
- Adding support for additional data types implementing the `ToPrettyTree` protocol.
- Improving documentation or examples.

Please submit your contributions via pull requests on GitHub. Make sure to follow the project's code style and include unit tests for any new features or bug fixes.
