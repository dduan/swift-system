/*
 This source file is part of the Swift System open source project

 Copyright (c) 2020 Apple Inc. and the Swift System project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
*/

import XCTest

#if SYSTEM_PACKAGE
import SystemPackage
#else
import System
#endif

final class ExitTest: XCTestCase {
  func testConstants() {
    XCTAssert(EXIT_SUCCESS == ExitStatus.success.rawValue)
    XCTAssert(EXIT_FAILURE == ExitStatus.failure.rawValue)
  }
}
