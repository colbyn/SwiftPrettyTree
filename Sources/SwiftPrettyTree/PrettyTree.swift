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
        let label: String
        let children: [PrettyTree]
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
            self = Self.value("\(key): \(x.truncate(limit: 50).debugDescription)")
        case let x:
            self = Self(label: key, children: [x])
        }
    }
    public init(fragment: [PrettyTree]) {
        self = .fragment(fragment)
    }
}

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
    fileprivate func leaf(value: String) -> String {
        let leading = self.leading()
        return "\(leading)\(value)"
    }
    fileprivate func branch(label: String, children: [PrettyTree]) -> String {
        let label = self.leaf(value: label)
        if children.isEmpty {
            return label
        }
        let children = children
            .enumerated()
            .map { (ix, child) in
                let is_last = ix == children.count - 1;
                if is_last {
                    return child.format(formater: self.downThenRight())
                }
                return child.format(formater: self.downAndRight())
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
    fileprivate func format(formater: Formatter) -> String {
        switch self {
        case .empty: return ""
        case .value(let x): return formater.leaf(value: x)
        case .string(let x): return formater.leaf(value: x.truncated(limit: 50, position: .middle).debugDescription)
        case .branch(let branch): return formater.branch(label: branch.label, children: branch.children)
        case .fragment(_):
            fatalError("TODO")
        }
    }
    public func format() -> String {
        self.format(formater: .root)
    }
}
