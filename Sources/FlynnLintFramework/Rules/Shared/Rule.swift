import Foundation
import SourceKittenFramework

struct Ruleset {
    var all: [Rule] = []
    var byKind: [SwiftDeclarationKind: [Rule]] = [:]

    init() {
        let allRules: [Rule.Type] = [
            PrivateFunctionInActorRule.self,
            SafeFunctionRule.self,
            InternalBehaviourRule.self,
            PrivateVariablesInActorRule.self,
            SafeVariableRule.self,
            PrivateFunctionInRemoteActorRule.self,
            PrivateVariablesInRemoteActorRule.self,
            RemoveAutogeneratedBehavioursRule.self
        ]

        for ruleClass in allRules {
            let rule = ruleClass.init()

            all.append(rule)

            for trigger in rule.description.syntaxTriggers {
                if self.byKind[trigger] == nil {
                    self.byKind[trigger] = []
                }
                self.byKind[trigger]?.append(rule)
            }
        }
    }
}

protocol Rule {

    init()

    var description: RuleDescription { get }

    func precheck(_ file: File) -> Bool

    @discardableResult
    func check(_ ast: AST, _ syntax: FileSyntax, _ output: inout [PrintError.Packet]) -> Bool
}

extension Rule {

    func precheck(_ file: File) -> Bool {
        return true
    }

    func error(_ offset: Int64?, _ fileSyntax: FileSyntax, _ msg: String) -> PrintError.Packet {
        let path = fileSyntax.file.path ?? "<nopath>"
        if let offset = offset {
            let stringView = StringView.init(fileSyntax.file.contents)
            if let (line, character) = stringView.lineAndCharacter(forByteOffset: ByteCount(offset)) {
                return PrintError.Packet(error: "\(path):\(line):\(character): error: \(msg)")
            }
        }
        return PrintError.Packet(error: "\(path): error: \(msg)")
    }

    func error(_ offset: Int64?, _ fileSyntax: FileSyntax) -> PrintError.Packet {
        return error(offset, fileSyntax, description.consoleDescription)
    }

    func warning(_ offset: Int64?, _ fileSyntax: FileSyntax, _ msg: String) -> PrintError.Packet {
        let path = fileSyntax.file.path ?? "<nopath>"
        if let offset = offset {
            let stringView = StringView.init(fileSyntax.file.contents)
            if let (line, character) = stringView.lineAndCharacter(forByteOffset: ByteCount(offset)) {
                return PrintError.Packet(error: "\(path):\(line):\(character): warning: \(msg)")
            }
        }
        return PrintError.Packet(error: "\(path): warning: \(msg)")
    }

    func warning(_ offset: Int64?, _ fileSyntax: FileSyntax) -> PrintError.Packet {
        return warning(offset, fileSyntax, description.consoleDescription)
    }

    func test(_ code: String) -> Bool {
        var next: [PrintError.Packet] = []

        do {
            let file = File(contents: code)
            let syntax = try StructureAndSyntax(file: file)
            let fileSyntax = FileSyntax(outputPath: "/tmp",
                                        file: file,
                                        structure: syntax.structure,
                                        ancestry: [],
                                        tokens: syntax.syntax,
                                        blacklist: [],
                                        dependency: false)

            let astBuilder = ASTBuilder()
            astBuilder.add(fileSyntax)

            let ast = astBuilder.build()

            for syntax in astBuilder {

                if description.syntaxTriggers.count == 0 {
                    if !check(ast, syntax, &next) {
                        return false
                    }
                } else if description.syntaxTriggers.contains(syntax.structure.kind!) {
                    if !check(ast, syntax, &next) {
                        return false
                    }
                }
            }

        } catch {
            print("Parsing error: \(error)")
        }
        return true
    }

    func test() -> Bool {
        for example in description.nonTriggeringExamples {
            if test(example) != true {
                print("\(description.identifier) failed on nonTriggeringExample:\n\(example)")
                return false
            }
        }
        for example in description.triggeringExamples {
            if test(example) != false {
                print("\(description.identifier) failed on triggeringExamples:\n\(example)")
                return false
            }
        }
        return true
    }

}
