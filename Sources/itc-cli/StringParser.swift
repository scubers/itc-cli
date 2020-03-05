//
//  File.swift
//
//
//  Created by 王俊仁 on 2020/3/5.
//

import Foundation

struct StringsParser {
    struct Result {
        var key: String
        var value: String?
        var declareKey: String {
            key
                .replacingOccurrences(of: ".", with: "_")
                .replacingOccurrences(of: " ", with: "_")
                .replacingOccurrences(of: "-", with: "_")
        }
    }

    var namespace: String
    var modifier: Modifier = .internal

    func parse(_ content: String) -> [Result] {
        let lines = content.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.hasPrefix("\"") && $0.hasSuffix(";") }
        return lines.map { line in

            let c = line.replacingOccurrences(of: "\" = \"", with: "ø").split(separator: "ø").map { $0.description }

            let key = c.first!.replacingOccurrences(of: "\"", with: "")
            let value = c.last!.replacingOccurrences(of: "\";", with: "")
//            kv[key] = value
            return .init(key: key, value: "\"\(value)\"")
        }
    }

    func parserToSwift(_ content: String, module: String) -> String {
        let result = parse(content)
        let ps = result.map { (r) -> Function in
            let placeholders = self.getPlaceholder(r.value ?? "")
//            return Properties(indent: 0, modifiers: [.static, .let], name: r.key, type: "String?", value: r.value)
            return Function(indent: 0, modifiers: [.static, .func], statements: self.getStatements(key: r.key, ps: placeholders), signature: self.generateSignature(key: r.declareKey, ps: placeholders))
        }
        let p = Properties(indent: 0, modifiers: [.private, .static, .let], name: "bundle", type: "Bundle", value: "Bundle(path: Bundle.main.path(forResource: \"i18n_\(module)\", ofType: \"bundle\")! + \"/\\(I18nConfig.shared.config).lproj\")!")
        return Namespace(indent: 0, modifiers: [self.modifier, .extension], declare: namespace, properties: [p], funcs: ps).description
    }

    func getPlaceholder(_ content: String) -> [String] {
        let reg = try! NSRegularExpression(pattern: "\\{\\{\\w+\\}\\}", options: NSRegularExpression.Options.caseInsensitive)
        var keys = [String]()
        reg.enumerateMatches(in: content, options: .reportCompletion, range: NSRange(location: 0, length: content.count)) { result, _, _ in
            if let r = result?.range {
                keys.append((content as NSString).substring(with: r))
            }
        }
        return keys
    }

    func generateSignature(key: String, ps: [String]) -> String {
        let keys = ps.map { p in
            p.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")
        }.map {
            "_ \($0): Any"
        }.joined(separator: ", ")
        return "\(key)(\(keys)) -> String?"
    }
    
    func getStatements(key: String, ps: [String]) -> [String] {
        var strs = [String]()
        let prefix = ps.isEmpty ? "let" : "var"
        strs.append("\(prefix) template = NSLocalizedString(\"\(key)\", tableName: nil, bundle: bundle, value: \"\", comment: \"\(key)\")")
        ps.forEach { p in
            let pp = p.replacingOccurrences(of: "{", with: "")
                .replacingOccurrences(of: "}", with: "")
            strs.append("template = template.replacingOccurrences(of: \"\(p)\", with: \"\\(\(pp))\")")
        }
        strs.append("return template")
        return strs
    }
}

extension StringsParser: CommandHandler {
    static func getHelpString() -> String {
        """
        itc-cli i18n
        --namespace=xxx
        --dir=检测目录
        --module=业务标识
        --target=zh-hans // 最终寻找dir下 xxx/yyy/zh-hans.lproj/Localizable.strings 文件进行转化
        --output=生成文件目录
        """
    }
    static func handleCommand(_ args: ArgParser) {
        guard args.subCommand == "i18n" else { return }
        
        if args.isHelp() {
            print(getHelpString())
            return
        }
        
        guard let namespace = args.get("namespace") else {
            print("参数 --namespace 为空")
            return
        }
        guard let dir = args.get("dir") else {
            print("参数 --dir 为空")
            return
        }
        guard let module = args.get("module") else {
            print("参数 --module 为空")
            return
        }
        let output = args.get("output") ?? "."
        let target = args.get("target") ?? "en"
        
        let files = (FileManager.default.subpaths(atPath: dir) ?? [])
            .filter { $0.hasSuffix("\(target).lproj/Localizable.strings") }
        

        files.forEach { file in
            let name = (file as NSString).lastPathComponent.replacingOccurrences(of: ".strings", with: "")
                .replacingOccurrences(of: "-", with: "_")
                .replacingOccurrences(of: " ", with: "_")
            let content = try! String(contentsOfFile: "\(dir)/\(file)")
            let code = StringsParser(namespace: namespace, modifier: .public).parserToSwift(content, module: module)
            let outputFile = "\(output)/\(name).swift"
//            print(outputFile)
            try? code.write(toFile: outputFile, atomically: true, encoding: .utf8)
        }
    }
}
