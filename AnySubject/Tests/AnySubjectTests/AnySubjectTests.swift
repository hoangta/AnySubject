import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(AnySubjectMacros)
import AnySubjectMacros

let testMacros: [String: Macro.Type] = [
    "AnySubject": AnySubjectMacro.self
]
#endif

final class AnySubjectTests: XCTestCase {
    func testMarcroPassthroughSubject() throws {
        assertMacroExpansion(
        #"""
        final class ViewModel {
            @AnySubject
            private let aSubject = PassthroughSubject<Void, Error>()
        }
        """#,
        expandedSource: #"""
        final class ViewModel {
            private let aSubject = PassthroughSubject<Void, Error>()

            var aSubjectSubject: AnyPublisher<Void, Error> {
                aSubject.eraseToAnyPublisher()
            }
        }
        """#,
        macros: testMacros
        )
    }

    func testMarcroInt() throws {
        assertMacroExpansion(
        #"""
        final class ViewModel {
            @AnySubject
            private let aSubject = 1
        }
        """#,
        expandedSource: #"""
        final class ViewModel {
            private let aSubject = 1
        }
        """#,
        diagnostics: [DiagnosticSpec(message: AnySubjectDiagnostic.notSubject.message, line: 2, column: 5)],
        macros: testMacros
        )
    }
}
