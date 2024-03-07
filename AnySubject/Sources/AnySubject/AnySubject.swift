// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
//@attached(member, names: suffixed(Subject))
@attached(peer, names: suffixed(Subject))
public macro AnySubject() = #externalMacro(module: "AnySubjectMacros", type: "AnySubjectMacro")
