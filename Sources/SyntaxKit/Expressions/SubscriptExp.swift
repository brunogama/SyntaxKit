//
//  SubscriptExp.swift
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

/// A Swift subscript expression, e.g. `values[key]`.
public struct SubscriptExp: CodeBlock, ExprCodeBlock {
  private let base: any CodeBlock
  private let arguments: [ParameterExp]

  /// The SwiftSyntax expression representation of the subscript expression.
  public var exprSyntax: ExprSyntax {
    ExprSyntax(
      SubscriptCallExprSyntax(
        calledExpression: baseExpression,
        leftSquare: .leftSquareToken(),
        arguments: argumentList,
        rightSquare: .rightSquareToken()
      )
    )
  }

  /// The SwiftSyntax representation of the subscript expression.
  public var syntax: any SyntaxProtocol {
    exprSyntax
  }

  /// The base expression, parenthesized when a trailing subscript would otherwise
  /// bind to only part of it (e.g. `(flag ? first : second)[key]`).
  private var baseExpression: ExprSyntax {
    let expression: ExprSyntax
    if let exprBlock = base as? any ExprCodeBlock {
      expression = exprBlock.exprSyntax
    } else {
      expression =
        base.syntax.as(ExprSyntax.self)
        ?? ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier("")))
    }

    switch expression.kind {
    case .ternaryExpr, .sequenceExpr, .infixOperatorExpr, .prefixOperatorExpr,
      .tryExpr, .awaitExpr, .asExpr, .isExpr:
      return ExprSyntax(
        TupleExprSyntax(
          leftParen: .leftParenToken(),
          elements: LabeledExprListSyntax([
            LabeledExprSyntax(expression: expression)
          ]),
          rightParen: .rightParenToken()
        )
      )
    default:
      return expression
    }
  }

  /// The comma-separated subscript arguments.
  private var argumentList: LabeledExprListSyntax {
    LabeledExprListSyntax(
      arguments.enumerated().compactMap { index, argument in
        let element: LabeledExprSyntax
        if let labeled = argument.syntax as? LabeledExprSyntax {
          element = labeled
        } else if let unlabeled = argument.syntax.as(ExprSyntax.self) {
          element = LabeledExprSyntax(
            label: nil,
            colon: nil,
            expression: unlabeled
          )
        } else {
          return nil
        }
        if index < arguments.count - 1 {
          return element.with(
            \.trailingComma,
            .commaToken(trailingTrivia: .space)
          )
        }
        return element
      }
    )
  }

  /// Creates a subscript expression.
  /// - Parameters:
  ///   - base: The expression being subscripted.
  ///   - arguments: A ``ParameterExpBuilderResult`` that provides the subscript arguments.
  public init(base: any CodeBlock, @ParameterExpBuilderResult _ arguments: () -> [ParameterExp]) {
    self.base = base
    self.arguments = arguments()
  }
}
