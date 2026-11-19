//
//  InjectionSyntaxAPITests.swift
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

import SwiftSyntax
import Testing

@testable import SyntaxKit

/// Tests reusable syntax APIs used by accessor and peer macros.
internal struct InjectionSyntaxAPITests {
  @Test("Getter produces an accessor declaration")
  internal func getterProducesAccessorDeclaration() {
    let getter = Getter {
      Return {
        VariableExp("storage")
      }
    }

    #expect(getter.accessorSyntax.kind == .accessorDecl)
    #expect(getter.accessorSyntax.accessorSpecifier.tokenKind == .keyword(.get))
    #expect(
      getter.generateCode().normalize()
        == """
        get {
          return storage
        }
        """.normalize()
    )
  }

  @Test("Setter produces an accessor declaration")
  internal func setterProducesAccessorDeclaration() {
    let setter = Setter {
      Assignment(VariableExp("storage"), VariableExp("newValue"))
    }

    #expect(setter.accessorSyntax.kind == .accessorDecl)
    #expect(setter.accessorSyntax.accessorSpecifier.tokenKind == .keyword(.set))
    #expect(
      setter.generateCode().normalize()
        == """
        set {
          storage = newValue
        }
        """.normalize()
    )
  }

  @Test("Assignment accepts a structured expression target")
  internal func assignmentAcceptsExpressionTarget() throws {
    let target = SubscriptExp(base: VariableExp("storage")) {
      ParameterExp(unlabeled: VariableExp("key"))
    }
    let assignment = Assignment(target, VariableExp("newValue"))
    let statement = try #require(assignment.syntax.as(ExpressionStmtSyntax.self))
    let sequence = try #require(statement.expression.as(SequenceExprSyntax.self))

    #expect(sequence.elements.first?.is(SubscriptCallExprSyntax.self) == true)
    #expect(assignment.generateCode() == "storage[key] = newValue")
  }

  @Test("Enum supports private access and qualified protocol inheritance")
  internal func enumSupportsAccessAndStructuredInheritance() throws {
    let enumDecl = Enum("Key") {}
      .access(.private)
      .inherits(MemberType(NamedType("Injected"), name: "DependencyKey"))
    let syntax = try #require(enumDecl.syntax.as(EnumDeclSyntax.self))
    let inheritedType = try #require(syntax.inheritanceClause?.inheritedTypes.first?.type)

    #expect(syntax.modifiers.first?.name.tokenKind == .keyword(.private))
    #expect(inheritedType.is(MemberTypeSyntax.self))
    #expect(enumDecl.generateCode().normalize() == "private enum Key: Injected.DependencyKey { }")
  }

  @Test("TypeAlias accepts structured generic and qualified types")
  internal func typeAliasAcceptsStructuredGenericType() throws {
    let valueType = MemberType(
      NamedType("Injected"),
      name: "Dependency",
      genericArguments: NamedType("Value")
    )
    let typeAlias = TypeAlias(
      "Registry",
      equals: NamedType(
        "Dictionary",
        genericArguments: NamedType("String"),
        valueType
      )
    )
    let syntax = try #require(typeAlias.syntax.as(TypeAliasDeclSyntax.self))
    let identifierType = try #require(syntax.initializer.value.as(IdentifierTypeSyntax.self))
    let arguments = try #require(identifierType.genericArgumentClause?.arguments)

    #expect(arguments.count == 2)
    #expect(arguments.last?.argument.is(MemberTypeSyntax.self) == true)
    #expect(
      typeAlias.generateCode()
        == "typealias Registry = Dictionary<String, Injected.Dependency<Value>>"
    )
  }

  @Test("TypeAlias preserves arbitrary TypeSyntax")
  internal func typeAliasPreservesArbitraryTypeSyntax() throws {
    let optionalType = TypeSyntax(
      OptionalTypeSyntax(
        wrappedType: IdentifierTypeSyntax(name: .identifier("Value"))
      )
    )
    let typeAlias = TypeAlias("OptionalValue", equals: SyntaxType(optionalType))
    let syntax = try #require(typeAlias.syntax.as(TypeAliasDeclSyntax.self))

    #expect(syntax.initializer.value.is(OptionalTypeSyntax.self))
    #expect(typeAlias.generateCode() == "typealias OptionalValue = Value?")
  }

  @Test("Existing string APIs remain source compatible")
  internal func existingStringAPIsRemainSourceCompatible() {
    let assignment = Assignment("value", 42)
    let typeAlias = TypeAlias("Value", equals: "Swift.Int")
    let enumDecl = Enum("State") {
      EnumCase("ready")
    }.inherits("Equatable", "Sendable")

    #expect(assignment.generateCode() == "value = 42")
    #expect(typeAlias.generateCode() == "typealias Value = Swift.Int")
    #expect(enumDecl.generateCode().normalize() == "enum State: Equatable, Sendable { case ready }")
  }
}
