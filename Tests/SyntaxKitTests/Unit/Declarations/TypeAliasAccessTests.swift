//
//  TypeAliasAccessTests.swift
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
import Testing

@testable import SyntaxKit

/// Test suite for access modifiers on ``TypeAlias`` declarations.
internal struct TypeAliasAccessTests {
  @Test internal func testTypeAliasWithoutAccessModifier() {
    let typeAlias = TypeAlias("Factory", equals: "Foo<Int>")

    #expect(typeAlias.generateCode() == "typealias Factory = Foo<Int>")
  }

  @Test internal func testTypeAliasWithPublicAccess() {
    let typeAlias = TypeAlias("Factory", equals: "Foo<Int>").access(.public)

    #expect(typeAlias.generateCode() == "public typealias Factory = Foo<Int>")
  }

  @Test internal func testTypeAliasWithPackageAccess() {
    let typeAlias = TypeAlias("Factory", equals: "Foo<Int>").access(.package)

    #expect(typeAlias.generateCode() == "package typealias Factory = Foo<Int>")
  }

  @Test internal func testTypeAliasUsesLastAccessModifier() {
    let typeAlias = TypeAlias("Factory", equals: "Foo<Int>").access(.public).access(.fileprivate)

    #expect(typeAlias.generateCode() == "fileprivate typealias Factory = Foo<Int>")
  }

  @Test internal func testTypeAliasWithAttributeAndAccess() {
    let typeAlias = TypeAlias("Factory", equals: "Foo<Int>")
      .attribute("available", arguments: ["iOS", "17.0"])
      .access(.public)
    let generated = typeAlias.generateCode()

    #expect(generated.hasPrefix("@available(iOS, 17.0)"))
    #expect(generated.hasSuffix("public typealias Factory = Foo<Int>"))
  }

  @Test internal func testTypeAliasWithAccessInStruct() {
    let structDecl = Struct("Container") {
      TypeAlias("Factory", equals: "Foo<Int>").access(.public)
    }

    let generated = structDecl.generateCode().normalize()

    #expect(generated.contains("public typealias Factory = Foo<Int>"))
  }
}
