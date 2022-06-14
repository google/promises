//
//  Promises+StringTests.swift
//  FBLPromisesInteroperabilityTests
//
//  Created by Dylan Mace on 6/13/22.
//
import XCTest
@testable import Promises

extension String: Error {}

class PromiseStringTests: XCTestCase {

  func testPromiseInt() {
    func log(_ message: String) {
      print("testPromiseInt: \(message)")
    }
    func work1(_ value: Int) -> Promise<Int> {
//      log("work1: value=\(value)")
      return Promise { value }
    }
    func work2(_ value: Int) -> Promise<Int> {
//      log("work2: value=\(value)")
      return Promise { value }
    }

    let exp = expectation(description: "testPromiseInt")
    let p1 = work1(42)
    let p2 = p1.then(work2).then { _ in exp.fulfill() }
//    log("isFulfilled: p1=\(p1.isFulfilled), p2=\(p2.isFulfilled)")

    XCTAssert(waitForPromises(timeout: 3))
    waitForExpectations(timeout: 3)
//    log("isFulfilled: p1=\(p1.isFulfilled), p2=\(p2.isFulfilled)")
  }

  func testPromiseString() {
    func log(_ message: String) {
//      print("testPromiseString: \(message)")
    }
    func work1(_ value: String) -> Promise<String> {
//      log("work1: value=\(value)")
      return Promise { value }
    }
    func work2(_ value: String) -> Promise<String> {
//      log("work2: value=\(value)")
      return Promise { value }
    }

    print("ERROR TYPE CHECK", "Foo" is Error)
    let exp = expectation(description: "testPromiseString")
    let p1 = work1("42")
    let p2 = p1.then(work2).then { _ in exp.fulfill() }
//    log("isFulfilled: p1=\(p1.isFulfilled), p2=\(p2.isFulfilled)")

    XCTAssert(waitForPromises(timeout: 3))
    waitForExpectations(timeout: 3)
//    log("isFulfilled: p1=\(p1.isFulfilled), p2=\(p2.isFulfilled)")
  }

  func testPromiseVec2() {
    struct Vec2 {
      let x: Int, y: Int
    }
    func log(_ message: String) {
      print("testPromiseVec2: \(message)")
    }
    func work1(_ value: Vec2) -> Promise<Vec2> {
//      log("work1: value=\(value)")
      return Promise { value }
    }
    func work2(_ value: Vec2) -> Promise<Vec2> {
//      log("work2: value=\(value)")
      return Promise { value }
    }

    let exp = expectation(description: "testPromiseVec2")
    let p1 = work1(Vec2(x: 42, y: 43))
    let p2 = p1.then(work2).then { _ in exp.fulfill() }
//    log("isFulfilled: p1=\(p1.isFulfilled), p2=\(p2.isFulfilled)")

    XCTAssert(waitForPromises(timeout: 3))
    waitForExpectations(timeout: 3)
//    log("isFulfilled: p1=\(p1.isFulfilled), p2=\(p2.isFulfilled)")
  }

  func testPromiseVec3() {
    class Vec3: CustomStringConvertible {
      let x: Int, y: Int, z: Int
      init (x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
      }
      public var description: String { return "(\(x), \(y), \(z))" }
    }
    func log(_ message: String) {
      print("testPromiseVec3: \(message)")
    }
    func work1(_ value: Vec3) -> Promise<Vec3> {
//      log("work1: value=\(String(describing: value))")
      return Promise { value }
    }
    func work2(_ value: Vec3) -> Promise<Vec3> {
//      log("work2: value=\(String(describing: value))")
      return Promise { value }
    }

    let exp = expectation(description: "testPromiseVec3")
    let p1 = work1(Vec3(x: 42, y: 43, z: 44))
    let p2 = p1.then(work2).then { _ in exp.fulfill() }
//    log("isFulfilled: p1=\(p1.isFulfilled), p2=\(p2.isFulfilled)")

    XCTAssert(waitForPromises(timeout: 3))
    waitForExpectations(timeout: 3)
//    log("isFulfilled: p1=\(p1.isFulfilled), p2=\(p2.isFulfilled)")
  }
}
