import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

public enum AnySubjectDiagnostic: String, DiagnosticMessage {
    case notAsProperty
    case notAsPrivate
    case notSubject

    public var message: String {
        switch self {
        case .notAsProperty: "@AnySubject can only be applied to a property."
        case .notAsPrivate: "@AnySubject can only be applied to a private property."
        case .notSubject: "@AnySubject can only be applied to a subject."
        }

    }

    public var diagnosticID: MessageID {
        MessageID(domain: "AnySubject", id: rawValue)
    }

    public var severity: DiagnosticSeverity {
        .error
    }
}

public enum AnySubjectMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
            let structError = Diagnostic(
                node: node,
                message: AnySubjectDiagnostic.notAsProperty
            )
            context.diagnose(structError)
            return []
        }
        guard varDecl.modifiers.first?.name.tokenKind == .keyword(.private) else {
            let structError = Diagnostic(
                node: node,
                message: AnySubjectDiagnostic.notAsPrivate
            )
            context.diagnose(structError)
            return []
        }
        let name = varDecl.bindings.first!.pattern.as(IdentifierPatternSyntax.self)!.identifier.text
        guard let expr = varDecl.bindings.first?.initializer?.value
            .as(FunctionCallExprSyntax.self)?.calledExpression
            .as(GenericSpecializationExprSyntax.self) else {
            let structError = Diagnostic(
                node: node,
                message: AnySubjectDiagnostic.notSubject
            )
            context.diagnose(structError)
            return []
        }
        let arguments = expr.genericArgumentClause.arguments
        let output = arguments.first!.argument.as(IdentifierTypeSyntax.self)!.name.text
        let failure = arguments.last!.argument.as(IdentifierTypeSyntax.self)!.name.text
        return ["""
        var \(raw: name)Subject: AnyPublisher<\(raw: output), \(raw: failure)> {
            \(raw: name).eraseToAnyPublisher()
        }
        """]
    }
}

@main
struct AnySubjectPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AnySubjectMacro.self
    ]
}
