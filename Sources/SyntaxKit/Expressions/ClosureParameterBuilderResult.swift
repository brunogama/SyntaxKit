//
//  ClosureParameterBuilderResult.swift
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

/// A result builder for creating closure parameter lists.
@resultBuilder
public enum ClosureParameterBuilderResult: Sendable, Equatable {
  /// Wraps a single closure parameter so it can be combined with others.
  public static func buildExpression(_ expression: ClosureParameter) -> [ClosureParameter] {
    [expression]
  }

  /// Passes an existing array of closure parameters through unchanged.
  public static func buildExpression(_ expression: [ClosureParameter]) -> [ClosureParameter] {
    expression
  }

  /// Combines the closure parameters of a block, including those produced by loops and conditions.
  public static func buildBlock(_ components: [ClosureParameter]...) -> [ClosureParameter] {
    components.flatMap { $0 }
  }

  /// Builds the closure parameters of an `if` statement without an `else` branch.
  public static func buildOptional(_ component: [ClosureParameter]?) -> [ClosureParameter] {
    component ?? []
  }

  /// Builds the closure parameters of the first branch of an `if`-`else` or `switch` statement.
  public static func buildEither(first component: [ClosureParameter]) -> [ClosureParameter] {
    component
  }

  /// Builds the closure parameters of the second branch of an `if`-`else` or `switch` statement.
  public static func buildEither(second component: [ClosureParameter]) -> [ClosureParameter] {
    component
  }

  /// Flattens the closure parameters produced by each iteration of a `for` loop.
  public static func buildArray(_ components: [[ClosureParameter]]) -> [ClosureParameter] {
    components.flatMap { $0 }
  }
}
