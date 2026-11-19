//
//  ParameterExpBuilderResult.swift
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

import Foundation

/// A result builder for creating arrays of ``ParameterExp``s.
@resultBuilder
public enum ParameterExpBuilderResult: Sendable, Equatable {
  /// Wraps a single parameter expression so it can be combined with others.
  public static func buildExpression(_ expression: ParameterExp) -> [ParameterExp] {
    [expression]
  }

  /// Passes an existing array of parameter expressions through unchanged.
  public static func buildExpression(_ expression: [ParameterExp]) -> [ParameterExp] {
    expression
  }

  /// Combines the parameter expressions of a block, including those produced by loops and conditions.
  public static func buildBlock(_ components: [ParameterExp]...) -> [ParameterExp] {
    components.flatMap { $0 }
  }

  /// Builds the parameter expressions of an `if` statement without an `else` branch.
  public static func buildOptional(_ component: [ParameterExp]?) -> [ParameterExp] {
    component ?? []
  }

  /// Builds the parameter expressions of the first branch of an `if`-`else` or `switch` statement.
  public static func buildEither(first component: [ParameterExp]) -> [ParameterExp] {
    component
  }

  /// Builds the parameter expressions of the second branch of an `if`-`else` or `switch` statement.
  public static func buildEither(second component: [ParameterExp]) -> [ParameterExp] {
    component
  }

  /// Flattens the parameter expressions produced by each iteration of a `for` loop.
  public static func buildArray(_ components: [[ParameterExp]]) -> [ParameterExp] {
    components.flatMap { $0 }
  }
}
