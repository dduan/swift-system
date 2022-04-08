/*
 This source file is part of the Swift System open source project

 Copyright (c) 2020 Apple Inc. and the Swift System project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
*/

/*System 0.0.2, @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)*/
extension String {
  /// Creates a string by interpreting the null-terminated platform string as
  /// UTF-8 on Unix and UTF-16 on Windows.
  ///
  /// - Parameter platformString: The null-terminated platform string to be
  ///  interpreted as `CInterop.PlatformUnicodeEncoding`.
  ///
  /// If the content of the platform string isn't well-formed Unicode,
  /// this initializer replaces invalid bytes with U+FFFD.
  /// This means that, depending on the semantics of the specific platform,
  /// conversion to a string and back might result in a value that's different
  /// from the original platform string.
  public init(platformString: UnsafePointer<CInterop.PlatformChar>) {
    self.init(_errorCorrectingPlatformString: platformString)
  }

  public init(platformString: [CInterop.PlatformChar]) {
    guard let _ = platformString.firstIndex(of: 0) else {
      preconditionFailure(
        "input of String.init(platformString:) must be null-terminated"
      )
    }
    self = platformString.withUnsafeBufferPointer {
      String(_errorCorrectingPlatformString: $0.baseAddress!)
    }
  }

  @available(*, deprecated, message: "Use String(_ scalar: Unicode.Scalar)")
  public init(platformString: inout CInterop.PlatformChar) {
    guard platformString == 0 else {
      preconditionFailure(
        "input of String.init(platformString:) must be null-terminated"
      )
    }
    self = ""
  }

  @available(*, deprecated, message: "Use a copy of the String argument")
  public init(platformString: String) {
    self = platformString.withCString(String.init(cString:))
  }

  /// Creates a string by interpreting the null-terminated platform string as
  /// UTF-8 on Unix and UTF-16 on Windows.
  ///
  /// - Parameter platformString: The null-terminated platform string to be
  ///  interpreted as `CInterop.PlatformUnicodeEncoding`.
  ///
  /// If the contents of the platform string isn't well-formed Unicode,
  /// this initializer returns `nil`.
  public init?(
    validatingPlatformString platformString: UnsafePointer<CInterop.PlatformChar>
  ) {
    self.init(_platformString: platformString)
  }

  public init?(
    validatingPlatformString platformString: [CInterop.PlatformChar]
  ) {
    if let _ = platformString.firstIndex(of: 0),
       let string = platformString.withUnsafeBufferPointer({
         String(validatingPlatformString: $0.baseAddress!)
       }) {
      self = string
      return
    }
    return nil
  }

  @available(*, deprecated, message: "Use String(_ scalar: Unicode.Scalar)")
  public init?(
    validatingPlatformString platformString: inout CInterop.PlatformChar
  ) {
    guard platformString == 0 else { return nil }
    self = ""
  }

  @available(*, deprecated, message: "Use a copy of the String argument")
  public init?(
    validatingPlatformString platformString: String
  ) {
    self = platformString.withCString(String.init(cString:))
  }

  /// Calls the given closure with a pointer to the contents of the string,
  /// represented as a null-terminated platform string.
  ///
  /// - Parameter body: A closure with a pointer parameter
  ///   that points to a null-terminated platform string.
  ///   If `body` has a return value,
  ///   that value is also used as the return value for this method.
  /// - Returns: The return value, if any, of the `body` closure parameter.
  ///
  /// The pointer passed as an argument to `body` is valid
  /// only during the execution of this method.
  /// Don't try to store the pointer for later use.
  public func withPlatformString<Result>(
    _ body: (UnsafePointer<CInterop.PlatformChar>) throws -> Result
  ) rethrows -> Result {
    try _withPlatformString(body)
  }

}

extension CInterop.PlatformChar {
  internal var _platformCodeUnit: CInterop.PlatformUnicodeEncoding.CodeUnit {
    #if os(Windows)
    return self
    #else
    return CInterop.PlatformUnicodeEncoding.CodeUnit(bitPattern: self)
    #endif
  }
}
extension CInterop.PlatformUnicodeEncoding.CodeUnit {
  internal var _platformChar: CInterop.PlatformChar {
    #if os(Windows)
    return self
    #else
    return CInterop.PlatformChar(bitPattern: self)
    #endif
  }
}

internal protocol _PlatformStringable {
  func _withPlatformString<Result>(
    _ body: (UnsafePointer<CInterop.PlatformChar>) throws -> Result
  ) rethrows -> Result

  init?(_platformString: UnsafePointer<CInterop.PlatformChar>)
}
extension String: _PlatformStringable {}
