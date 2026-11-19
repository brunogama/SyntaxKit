//
//  ParameterBuilderTests.swift
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

/// Test suite for loops and conditions inside the parameter result builders.
internal struct ParameterBuilderTests {
  @Test("A for loop of arguments mixes with single arguments")
  internal func testArgumentsFromLoopAndSingleArgument() {
    let names = ["first", "second"]
    let call = Init("Pair") {
      for name in names {
        ParameterExp(name: name, value: VariableExp(name))
      }
      ParameterExp(name: "last", value: Literal.integer(1))
    }

    #expect(call.generateCode().normalize() == "Pair(first: first, second: second, last: 1)")
  }

  @Test("A condition can contribute several arguments")
  internal func testConditionWithSeveralArguments() {
    let includeRange = true
    let call = Init("Window") {
      if includeRange {
        ParameterExp(name: "start", value: Literal.integer(0))
        ParameterExp(name: "end", value: Literal.integer(9))
      }
    }

    #expect(call.generateCode().normalize() == "Window(start: 0, end: 9)")
  }

  @Test("A for loop builds closure parameters")
  internal func testClosureParametersFromLoop() {
    let closure = Closure {
      for index in 0..<2 {
        ClosureParameter("value\(index)")
      }
    } body: {
      VariableExp("value0")
    }

    #expect(closure.generateCode().normalize() == "{ (value0, value1) in value0 }")
  }

  @Test("Typed closure parameters are separated by commas")
  internal func testTypedClosureParametersAreSeparated() {
    let closure = Closure {
      ClosureParameter("name", type: "String")
      ClosureParameter("count", type: "Int")
    } body: {
      VariableExp("name")
    }

    #expect(closure.generateCode().normalize() == "{ (name: String, count: Int) in name }")
  }

  @Test("An empty loop builds no closure parameters")
  internal func testClosureParametersFromEmptyLoop() {
    let closure = Closure {
      for index in 0..<0 {
        ClosureParameter("value\(index)")
      }
    } body: {
      VariableExp("value")
    }

    #expect(!closure.generateCode().contains(" in"))
  }
}
