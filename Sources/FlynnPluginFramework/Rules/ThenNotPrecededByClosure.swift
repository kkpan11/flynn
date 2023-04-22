import Foundation
import SourceKittenFramework

struct ThenNotPrecededByClosure: Rule {

    let description = RuleDescription(
        identifier: "then_not_preceded_by_closure",
        name: "Then/Do Violation",
        description: ".then() must by immediately preceded by a behaviour's closure callback",
        syntaxTriggers: [.exprCall],
        nonTriggeringExamples: [
            Example("Actor().beCall { }.then().doCall()\n"),
        ],
        triggeringExamples: [
            Example("ThenActor().then().doFourth()\n"),
            Example("Actor().beCall { }.then(); print();\n"),
            Example("Actor().beCall { }.then()\n")
        ]
    )

    func check(_ ast: AST, _ syntax: FileSyntax, _ output: inout [PrintError.Packet]) -> Bool {        
        var errorOffsets: [Int64] = []
        
        // Check for then() which is not followed by a doCall()
        syntax.matches(#"then[\s\n\r\t]*\([\s\n\r\t]*\)(?![\s\n\r\t]*\.do[A-Z])"#) { offset, match, groups in
            errorOffsets.append(offset)
        }
        errorOffsets.forEach {
            output.append(error($0, syntax))
        }
        return errorOffsets.count == 0
    }

}
