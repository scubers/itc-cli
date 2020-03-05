//
//  ArgParser.swift
//  itc-cli
//
//  Created by 王俊仁 on 2020/3/5.
//

import Foundation

/// exec --name=value
class ArgParser {
    var options = [String]()
    var subCommand: String
    var file: String
    init(options: [String]) {
//        self.options = options
        file = options[0]
        assert(options.count > 1)
        subCommand = options[1]
        self.options = options
    }

    func get(_ key: String) -> String? {
        let prefix = "--\(key)="
        return options
            .filter { $0.hasPrefix(prefix) }
            .map { $0.replacingOccurrences(of: prefix, with: "") }
            .first
    }
}

protocol CommandHandler {
//    func canHandle(command: String) -> Bool
    static func handleCommand(_ args: ArgParser)
}
