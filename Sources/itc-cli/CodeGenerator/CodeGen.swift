//
//  File.swift
//
//
//  Created by 王俊仁 on 2020/3/5.
//

import Foundation

enum Modifier: String {
    case `public`
    case `internal`
    case `private`
    case `static`
    case `fileprivate`
    case `extension`
    case `class`
    case `struct`
    case `let`
    case `var`
    case `lazy`
    case `func`
}

private let singleIndent = "  "

private func indentString(_ count: Int) -> String {
    return Array(repeating: singleIndent, count: count).joined(separator: "")
}

class CodeGen {}

struct Namespace: CustomStringConvertible {
    var indent = 0
    var modifiers = [Modifier]()
    var declare: String
    var properties = [Properties]()
    var funcs = [Function]()
    
    var description: String {
        var string = indentString(indent)
        let modifier = modifiers.map { $0.rawValue }.joined(separator: " ")
        string += "\(modifier) \(declare)"
        string += " {\n"
        properties.forEach { (p) in
            var pis = p
            pis.indent = self.indent + 1
            string += (pis.description + "\n")
        }
        funcs.forEach { (p) in
            var pis = p
            pis.indent = self.indent + 1
            string += (pis.description + "\n")
        }
        string += "\(indentString(indent))}\n"
        return string
    }
}

struct Properties: CustomStringConvertible {
    var indent = 0
    var modifiers = [Modifier]()
    var name: String
    var type: String
    var value: String?
    // var aaa: Type = xxx

    var description: String {
        let modifier = modifiers.map { $0.rawValue }.joined(separator: " ")
        let prefix = "\(indentString(indent))\(modifier) \(name): \(type)"
        if let value = value {
            return "\(prefix) = \(value)"
        }
        return prefix
    }
}

struct Function: CustomStringConvertible {
    var indent = 0
    var modifiers = [Modifier]()
    var statements: [String]
    var signature: String
    
    var description: String {
        var string = indentString(indent)
        let modifier = modifiers.map { $0.rawValue }.joined(separator: " ")
        string += "\(modifier) \(signature)"
        string += " {\n"
        statements.forEach {
            string += (indentString(self.indent + 1) + $0 + "\n")
        }
        string += "\(indentString(self.indent))}\n"
        return string
    }
}
