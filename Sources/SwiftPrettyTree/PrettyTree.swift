//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/26/24.
//

import Foundation

public enum PrettyTree {
    case empty
    case string(String)
    case value(String)
    case branch(Branch)
    case fragment([PrettyTree])
    public struct Branch: ToPrettyTree {
        public let label: String
        public let children: [PrettyTree]
        public var asPrettyTree: PrettyTree {
            PrettyTree.branch(self)
        }
    }
    public init(label: String, children: [PrettyTree]) {
        self = .branch(Branch(label: label, children: children))
    }
    public init(value: String) {
        self = .value(value)
    }
    public init(string: String) {
        self = .string(string)
    }
    public init(key: String, value: some ToPrettyTree) {
        switch value.asPrettyTree {
        case .value(let x):
            self = Self.value("\(key): \(x)")
        case .string(let x):
            self = Self.value("\(key): \(x.truncated(limit: 80, position: .middle).debugDescription)")
        case let x:
            self = Self(label: key, children: [x])
        }
    }
    public init(fragment: [PrettyTree]) {
        self = .fragment(fragment)
    }
}

extension PrettyTree {
    public struct Formatter {
        fileprivate let columns: [ Column ]
        fileprivate init(columns: [Column] = []) {
            self.columns = columns
        }
        fileprivate static var root: Self = Self(columns: [])
        fileprivate func downThenRight() -> Self {
            let columns = self.columns
                .map {
                    switch $0 {
                    case .downAndRight: return Formatter.Column.verticalBar
                    case .downThenRight: return Formatter.Column.empty
                    default: return $0
                    }
                }
                .with(append: Formatter.Column.downThenRight)
            return Formatter(columns: columns)
        }
        fileprivate func downAndRight() -> Self {
            let columns = self.columns
                .map {
                    switch $0 {
                    case .downAndRight: return Formatter.Column.verticalBar
                    case .downThenRight: return Formatter.Column.empty
                    default: return $0
                    }
                }
                .with(append: Formatter.Column.downAndRight)
            return Formatter(columns: columns)
        }
        fileprivate func withColumn(column: Formatter.Column) -> Self {
            let columns = self.columns.with(append: column)
            return Formatter(columns: columns)
        }
        fileprivate func leading() -> String {
            let thinSpace = "\u{2009}"
            let leading = self.columns
                .map { $0.string }
                .joined(separator: "  ")
            let sep = self.columns.isEmpty ? "" : "╼\(thinSpace)"
            return "\(leading)\(sep)"
        }
        fileprivate func leaf(value: String, options: FormatterOptions) -> String {
            let leading = self.leading()
            return "\(leading)\(value)"
        }
        fileprivate func branch(label: String, children: [PrettyTree], options: FormatterOptions) -> String {
            let label = self.leaf(value: label, options: options)
            if children.isEmpty {
                return label
            }
            let children = children
                .enumerated()
                .map { (ix, child) in
                    let is_last = ix == children.count - 1;
                    if is_last {
                        return child.format(formater: self.downThenRight(), options: options)
                    }
                    return child.format(formater: self.downAndRight(), options: options)
                }
                .joined(separator: "\n")
            return "\(label)\n\(children)"
        }
        fileprivate func fragment(list: [PrettyTree]) -> String {
            fatalError("TODO")
        }
        fileprivate enum Column {
            case empty
            case upThenRight
            case verticalBar
            case downAndRight
            case downThenRight
            public var string: String {
                switch self {
                case .empty: return " "
                case .upThenRight: return "╭"
                case .verticalBar: return "│"
                case .downAndRight: return "├"
                case .downThenRight: return "╰"
                }
            }
        }
    }
    public struct FormatterOptions {
        fileprivate let compactMode: Bool
        public static let `default`: FormatterOptions = .init(compactMode: false)
        public func with(compactMode: Bool) -> FormatterOptions {
            return .init(compactMode: compactMode)
        }
    }
}

public protocol ToPrettyTree {
    var asPrettyTree: PrettyTree { get }
}

extension PrettyTree: ToPrettyTree {
    public var asPrettyTree: PrettyTree { self }
}

extension Array: ToPrettyTree where Array.Element: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        let children = map({$0.asPrettyTree})
        return PrettyTree(label: "Array", children: children)
    }
}
extension String: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(string: self)
    }
}
extension Character: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(string: "\(self)")
    }
}
extension Int: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(value: "\(self)")
    }
}
extension UInt: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(value: "\(self)")
    }
}
extension Optional: ToPrettyTree where Wrapped: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        switch self {
        case .none: return PrettyTree(value: "nil")
        case .some(let wrapped): return wrapped.asPrettyTree
        }
    }
}
extension UUID: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree.value(uuidString.debugDescription)
    }
}
extension Date: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree.value(self.debugDescription)
    }
}
extension PrettyTree {
    fileprivate func format(formater: Formatter, options: FormatterOptions) -> String {
        switch self {
        case .empty: return ""
        case .value(let x): return formater.leaf(value: x, options: options)
        case .string(let x): return formater.leaf(value: x.truncated(limit: 50, position: .middle).debugDescription, options: options)
        case .branch(let branch) where options.compactMode && branch.children.count == 1:
            let child = branch.children.first!
            if let child = child.asBranch {
                let label = "\(branch.label) ▷ \(child.label)"
                return formater.branch(label: label, children: child.children, options: options)
            }
            if let child = child.asString {
                let child = child.truncated(limit: 50, position: .middle).debugDescription
                let label = "\(branch.label): \(child)"
                return formater.leaf(value: label, options: options)
            }
            return formater.branch(label: branch.label, children: branch.children, options: options)
        case .branch(let branch):
            return formater.branch(label: branch.label, children: branch.children, options: options)
        case .fragment(_): fatalError("TODO")
        }
    }
    public func format(options: FormatterOptions = .default) -> String {
        self.format(formater: .root, options: options)
    }
    public var asBranch: Branch? {
        switch self {
        case .branch(let x): return x
        case .empty: return nil
        case .string(_): return nil
        case .value(_): return nil
        case .fragment(_): return nil
        }
    }
    public var asString: String? {
        switch self {
        case .branch(_): return nil
        case .empty: return nil
        case .string(let x): return x
        case .value(_): return nil
        case .fragment(_): return nil
        }
    }
    public var asValue: String? {
        switch self {
        case .branch(_): return nil
        case .empty: return nil
        case .string(_): return nil
        case .value(let x): return x
        case .fragment(_): return nil
        }
    }
}
