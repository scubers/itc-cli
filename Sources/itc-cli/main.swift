
import Foundation

let command = [
    "path",
    "strs",
    "--module=Biz",
    "--namespace=i18n",
    "--dir=/Users/j/Desktop/desk/workspace/youzan/youzan_beauty/BeautyBiz/BeautyUI",
    "--output=/Users/j/Desktop",
    "--target=zh-hans",
]
let parser = ArgParser(options: command)
// let parser = ArgParser(options: CommandLine.arguments)
StringsParser.handleCommand(parser)

class I18nConfig {
    static let shared = I18nConfig()
    var config: String = "zh-hans"
}

public class i18n {
    private static let bundle: Bundle = Bundle(path: Bundle.main.path(forResource: "i18n_Biz", ofType: "bundle")! + "/\(I18nConfig.shared.config).lproj")!
  static func demo_key() -> String? {
    let template = NSLocalizedString("demo_key", tableName: nil, bundle: bundle, value: "", comment: "demo_key")
    return template
  }

  static func demo_placeholder(_ name: Any) -> String? {
    var template = NSLocalizedString("demo_placeholder", tableName: nil, bundle: bundle, value: "", comment: "demo_placeholder")
    template = template.replacingOccurrences(of: "{{name}}", with: "\(name)")
    return template
  }

  static func demo_zh(_ name: Any) -> String? {
    var template = NSLocalizedString("demo_zh", tableName: nil, bundle: bundle, value: "", comment: "demo_zh")
    template = template.replacingOccurrences(of: "{{name}}", with: "\(name)")
    return template
  }

}
