//
//  SubscriptExpTests.swift
//  SyntaxKitTests
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import SwiftSyntax
import Testing

@testable import SyntaxKit

/// Test suite for ``SubscriptExp`` and the ``CodeBlock`` subscript convenience.
internal struct SubscriptExpTests {
  // MARK: - Argument Tests

  @Test("Subscript with an unlabeled argument generates correct syntax")
  internal func testSubscriptWithUnlabeledArgument() {
    let subscriptExp = SubscriptExp(base: VariableExp("values")) {
      ParameterExp(unlabeled: VariableExp("key"))
    }

    #expect(subscriptExp.generateCode() == "values[key]")
    #expect(subscriptExp.syntax.is(SubscriptCallExprSyntax.self))
  }

  @Test("Subscript with a labeled argument generates correct syntax")
  internal func testSubscriptWithLabeledArgument() {
    let subscriptExp = SubscriptExp(base: VariableExp("values")) {
      ParameterExp(name: "name", value: VariableExp("key"))
    }

    #expect(subscriptExp.generateCode() == "values[name:key]")
    #expect(subscriptExp.generateCode().normalize() == "values[name: key]")
  }

  @Test("Subscript with multiple arguments separates them with commas")
  internal func testSubscriptWithMultipleArguments() {
    let subscriptExp = SubscriptExp(base: VariableExp("matrix")) {
      ParameterExp(unlabeled: VariableExp("row"))
      ParameterExp(unlabeled: VariableExp("column"))
    }

    #expect(subscriptExp.generateCode() == "matrix[row, column]")
  }

  @Test("Subscript with mixed arguments generates correct syntax")
  internal func testSubscriptWithMixedArguments() {
    let subscriptExp = SubscriptExp(base: VariableExp("values")) {
      ParameterExp(unlabeled: VariableExp("key"))
      ParameterExp(name: "default", value: Literal.integer(0))
    }

    #expect(subscriptExp.generateCode() == "values[key, default:0]")
  }

  @Test("Subscript with a literal argument generates correct syntax")
  internal func testSubscriptWithLiteralArgument() {
    let subscriptExp = SubscriptExp(base: VariableExp("names")) {
      ParameterExp(unlabeled: Literal.string("first"))
    }

    #expect(subscriptExp.generateCode() == "names[\"first\"]")
  }

  @Test("Subscript without arguments generates empty brackets")
  internal func testSubscriptWithoutArguments() {
    let subscriptExp = SubscriptExp(base: VariableExp("values")) {}

    #expect(subscriptExp.generateCode() == "values[]")
  }

  // MARK: - Base Expression Tests

  @Test("Subscript on a property access generates correct syntax")
  internal func testSubscriptOnPropertyAccess() {
    let subscriptExp = SubscriptExp(base: VariableExp("self").property("storage")) {
      ParameterExp(unlabeled: VariableExp("key"))
    }

    #expect(subscriptExp.generateCode() == "self.storage[key]")
  }

  @Test("Subscript on a function call generates correct syntax")
  internal func testSubscriptOnFunctionCall() {
    let subscriptExp = SubscriptExp(base: Call("loadValues")) {
      ParameterExp(unlabeled: Literal.integer(0))
    }

    #expect(subscriptExp.generateCode() == "loadValues()[0]")
  }

  @Test("Subscript on a ternary expression parenthesizes the base")
  internal func testSubscriptOnConditionalOp() {
    let base = ConditionalOp(
      if: VariableExp("flag"),
      then: VariableExp("first"),
      else: VariableExp("second")
    )
    let subscriptExp = SubscriptExp(base: base) {
      ParameterExp(unlabeled: VariableExp("key"))
    }

    #expect(subscriptExp.generateCode() == "(flag ? first : second)[key]")
  }

  @Test("Subscript on an infix expression parenthesizes the base")
  internal func testSubscriptOnInfix() {
    let base = Infix("+", lhs: VariableExp("head"), rhs: VariableExp("tail"))
    let subscriptExp = SubscriptExp(base: base) {
      ParameterExp(unlabeled: VariableExp("key"))
    }

    #expect(subscriptExp.generateCode() == "(head + tail)[key]")
  }

  // MARK: - CodeBlock Convenience Tests

  @Test("CodeBlock subscript convenience generates correct syntax")
  internal func testCodeBlockSubscriptConvenience() {
    let subscriptExp = VariableExp("values").subscript {
      ParameterExp(unlabeled: VariableExp("key"))
    }

    #expect(subscriptExp.generateCode() == "values[key]")
  }

  @Test("Chained subscripts generate correct syntax")
  internal func testChainedSubscripts() {
    let subscriptExp = VariableExp("matrix")
      .subscript {
        ParameterExp(unlabeled: VariableExp("row"))
      }
      .subscript {
        ParameterExp(unlabeled: VariableExp("column"))
      }

    #expect(subscriptExp.generateCode() == "matrix[row][column]")
  }

  @Test("Method call on a subscript generates correct syntax")
  internal func testMethodCallOnSubscript() {
    let call = VariableExp("values")
      .subscript {
        ParameterExp(unlabeled: VariableExp("key"))
      }
      .call("resolve")

    #expect(call.generateCode() == "values[key].resolve()")
  }

  // MARK: - Integration Tests

  @Test("Subscript as an infix operand generates correct syntax")
  internal func testSubscriptAsInfixOperand() {
    let subscriptExp = SubscriptExp(base: VariableExp("values")) {
      ParameterExp(unlabeled: VariableExp("key"))
    }
    let comparison = Infix(.equal, lhs: subscriptExp, rhs: Literal.nil)

    #expect(comparison.generateCode() == "values[key] == nil")
  }

  @Test("Subscript as a call argument generates correct syntax")
  internal func testSubscriptAsCallArgument() {
    let call = Call("register") {
      ParameterExp(
        name: "factory",
        value: SubscriptExp(base: VariableExp("values")) {
          ParameterExp(unlabeled: VariableExp("key"))
        }
      )
    }

    #expect(call.generateCode() == "register(factory:values[key])")
  }

  @Test("Subscript in a return statement generates correct syntax")
  internal func testSubscriptInReturn() {
    let returnStatement = Return {
      SubscriptExp(base: VariableExp("values")) {
        ParameterExp(unlabeled: VariableExp("key"))
      }
    }

    #expect(returnStatement.generateCode() == "return values[key]")
  }
}
