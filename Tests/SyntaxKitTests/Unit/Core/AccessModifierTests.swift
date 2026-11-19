//
//  AccessModifierTests.swift
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

/// Test suite for ``AccessModifier`` and the declarations that render it.
internal struct AccessModifierTests {
  // MARK: - Keyword Mapping Tests

  @Test("Every access modifier maps to its matching keyword")
  internal func testKeywordMapping() {
    #expect(AccessModifier.public.keyword == .public)
    #expect(AccessModifier.private.keyword == .private)
    #expect(AccessModifier.internal.keyword == .internal)
    #expect(AccessModifier.fileprivate.keyword == .fileprivate)
    #expect(AccessModifier.open.keyword == .open)
    #expect(AccessModifier.package.keyword == .package)
  }

  @Test("Keyword initializer converts the package access modifier")
  internal func testKeywordInitializerWithPackage() {
    #expect(Keyword(AccessModifier.package) == .package)
  }

  @Test("All cases include the package access modifier")
  internal func testAllCasesIncludesPackage() {
    #expect(AccessModifier.allCases.contains(.package))
    #expect(AccessModifier.allCases.count == 6)
  }

  // MARK: - Rendering Tests

  @Test("Package access renders on a variable")
  internal func testPackageAccessOnVariable() {
    let variable = Variable(.let, name: "test", type: "String").access(.package)

    #expect(variable.generateCode().normalize() == "package let test: String")
  }

  @Test("Package access renders on a computed property")
  internal func testPackageAccessOnComputedProperty() {
    let property = ComputedProperty("count", type: "Int") {
      Return {
        Literal.integer(0)
      }
    }
    .access(.package)

    #expect(property.generateCode().normalize() == "package var count: Int { return 0 }")
  }

  @Test("Package access renders on a struct")
  internal func testPackageAccessOnStruct() {
    let structDecl = Struct("Container") {
      Variable(.let, name: "value", type: "Int")
    }
    .access(.package)

    #expect(structDecl.generateCode().normalize().hasPrefix("package struct Container"))
  }

  @Test("Package access renders on an import")
  internal func testPackageAccessOnImport() {
    let importDecl = Import("Dependencies").access(.package)

    #expect(importDecl.generateCode() == "package import Dependencies")
  }
}
