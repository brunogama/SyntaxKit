//
//  Getter.swift
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

/// A Swift `get` accessor declaration.
public struct Getter: CodeBlock {
  private let body: [any CodeBlock]

  /// The SwiftSyntax accessor declaration.
  public var accessorSyntax: AccessorDeclSyntax {
    AccessorDeclSyntax(
      accessorSpecifier: .keyword(.get),
      body: CodeBlockSyntax(
        leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
        statements: CodeBlockItemListSyntax(
          body.compactMap { block in
            CodeBlockItemSyntax.Item.create(from: block.syntax).map {
              CodeBlockItemSyntax(item: $0, trailingTrivia: .newline)
            }
          }
        ),
        rightBrace: .rightBraceToken(leadingTrivia: .newline)
      )
    )
  }

  /// The SwiftSyntax representation of the getter declaration.
  public var syntax: any SyntaxProtocol {
    accessorSyntax
  }

  /// Creates a getter declaration.
  /// - Parameter body: A ``CodeBlockBuilder`` that provides the getter body.
  public init(@CodeBlockBuilderResult _ body: () throws -> [any CodeBlock]) rethrows {
    self.body = try body()
  }
}
