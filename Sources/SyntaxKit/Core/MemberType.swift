//
//  MemberType.swift
//  SyntaxKit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

public import SwiftSyntax

/// A member type qualified by another type, with optional generic arguments.
public struct MemberType: TypeRepresentable {
  private let base: any TypeRepresentable
  private let name: String
  private let genericArguments: [any TypeRepresentable]

  /// The SwiftSyntax representation of the member type.
  public var typeSyntax: TypeSyntax {
    TypeSyntax(
      MemberTypeSyntax(
        baseType: base.typeSyntax,
        name: .identifier(name),
        genericArgumentClause: genericArgumentClause
      )
    )
  }

  private var genericArgumentClause: GenericArgumentClauseSyntax? {
    guard !genericArguments.isEmpty else {
      return nil
    }

    return GenericArgumentClauseSyntax(
      arguments: GenericArgumentListSyntax(
        genericArguments.enumerated().map { index, argument in
          GenericArgumentSyntax(
            argument: .type(argument.typeSyntax),
            trailingComma: index < genericArguments.count - 1
              ? .commaToken(trailingTrivia: .space) : nil
          )
        }
      )
    )
  }

  /// Creates a member type without generic arguments.
  /// - Parameters:
  ///   - base: The type that qualifies the member.
  ///   - name: The member type name.
  public init(_ base: any TypeRepresentable, name: String) {
    self.base = base
    self.name = name
    self.genericArguments = []
  }

  /// Creates a member type with generic arguments.
  /// - Parameters:
  ///   - base: The type that qualifies the member.
  ///   - name: The member type name.
  ///   - genericArguments: The generic arguments applied to the member type.
  public init(
    _ base: any TypeRepresentable,
    name: String,
    genericArguments: any TypeRepresentable...
  ) {
    self.base = base
    self.name = name
    self.genericArguments = genericArguments
  }

  /// Creates a member type with a dynamic collection of generic arguments.
  /// - Parameters:
  ///   - base: The type that qualifies the member.
  ///   - name: The member type name.
  ///   - genericArguments: The generic arguments applied to the member type.
  public init(
    _ base: any TypeRepresentable,
    name: String,
    genericArguments: [any TypeRepresentable]
  ) {
    self.base = base
    self.name = name
    self.genericArguments = genericArguments
  }
}
