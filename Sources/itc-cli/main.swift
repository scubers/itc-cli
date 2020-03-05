
import Foundation

#if DEBUG
let command = [
    "path",
    "i18n",
    "--module=Biz",
    "--help",
    "--namespace=i18n",
    "--dir=/Users/j/Desktop/desk/workspace/youzan/youzan_beauty/BeautyBiz/BeautyUI",
    "--output=/Users/j/Desktop",
    "--target=zh-hans",
]
let parser = ArgParser(options: command)
#else
let parser = ArgParser(options: CommandLine.arguments)
#endif

StringsParser.handleCommand(parser)
