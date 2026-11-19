//
//  TypeAlias.swift
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

/// A Swift `typealias` declaration.
public struct TypeAlias: CodeBlock, Sendable {
  private let name: String
  private let existingType: TypeSyntax
  private var accessModifier: AccessModifier?
  private var attributes: [AttributeInfo] = []

  /// The SwiftSyntax representation of the typealias declaration.
  public var syntax: any SyntaxProtocol {
    // Build access modifier
    var modifiers: DeclModifierListSyntax = []
    if let access = accessModifier {
      modifiers = DeclModifierListSyntax([
        DeclModifierSyntax(name: .keyword(access.keyword, trailingTrivia: .space))
      ])
    }

    // `typealias` keyword token
    let keyword = TokenSyntax.keyword(.typealias, trailingTrivia: .space)

    // Alias identifier; the initializer clause supplies the spacing around `=`
    let identifier = TokenSyntax.identifier(name)

    // Initializer clause – `= ExistingType`
    let initializer = TypeInitializerClauseSyntax(
      equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
      value: existingType
    )

    return TypeAliasDeclSyntax(
      attributes: buildAttributeList(from: attributes),
      modifiers: modifiers,
      typealiasKeyword: keyword,
      name: identifier,
      initializer: initializer
    )
  }

  /// Creates a `typealias` declaration.
  /// - Parameters:
  ///   - name: The new name that will alias the existing type.
  ///   - type: The existing type that is being aliased.
  public init(_ name: String, equals type: String) {
    self.name = name
    self.existingType = type.typeSyntax
  }

  /// Creates a `typealias` declaration from a structured type representation.
  /// - Parameters:
  ///   - name: The new name that will alias the existing type.
  ///   - type: The existing type that is being aliased.
  public init(_ name: String, equals type: any TypeRepresentable) {
    self.name = name
    self.existingType = type.typeSyntax
  }

  /// Sets the access modifier for the typealias declaration.
  /// - Parameter access: The access modifier.
  /// - Returns: A copy of the typealias with the access modifier set.
  public func access(_ access: AccessModifier) -> Self {
    var copy = self
    copy.accessModifier = access
    return copy
  }

  /// Adds an attribute to the typealias declaration.
  /// - Parameters:
  ///   - attribute: The attribute name (without the @ symbol).
  ///   - arguments: The arguments for the attribute, if any.
  /// - Returns: A copy of the typealias with the attribute added.
  public func attribute(_ attribute: String, arguments: [String] = []) -> Self {
    var copy = self
    copy.attributes.append(AttributeInfo(name: attribute, arguments: arguments))
    return copy
  }

  private func buildAttributeList(from attributes: [AttributeInfo]) -> AttributeListSyntax {
    if attributes.isEmpty {
      return AttributeListSyntax([])
    }
    let attributeElements = attributes.map { attributeInfo in
      let arguments = attributeInfo.arguments

      var leftParen: TokenSyntax?
      var rightParen: TokenSyntax?
      var argumentsSyntax: AttributeSyntax.Arguments?

      if !arguments.isEmpty {
        leftParen = .leftParenToken()
        rightParen = .rightParenToken()

        let argumentList = arguments.map { argument in
          DeclReferenceExprSyntax(baseName: .identifier(argument))
        }

        argumentsSyntax = .argumentList(
          LabeledExprListSyntax(
            argumentList.enumerated().map { index, expr in
              var element = LabeledExprSyntax(expression: ExprSyntax(expr))
              if index < argumentList.count - 1 {
                element = element.with(\.trailingComma, .commaToken(trailingTrivia: .space))
              }
              return element
            }
          )
        )
      }

      return AttributeListSyntax.Element(
        AttributeSyntax(
          atSign: .atSignToken(),
          attributeName: IdentifierTypeSyntax(name: .identifier(attributeInfo.name)),
          leftParen: leftParen,
          arguments: argumentsSyntax,
          rightParen: rightParen
        )
      )
    }
    return AttributeListSyntax(attributeElements)
  }
}
