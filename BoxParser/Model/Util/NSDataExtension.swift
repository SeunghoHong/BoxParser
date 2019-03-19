
import Foundation

extension Data {
  var uint8: UInt8 {
    get {
      let number: UInt8 = self.withUnsafeBytes {
        return $0.pointee
      }
      return number
    }
  }
}

extension Data {
  var uint16: UInt16 {
    get {
      let number: UInt16 = self.withUnsafeBytes {
        return $0.pointee
      }
      return number
    }
  }
}

extension Data {
  var uint32: UInt32 {
    get {
      let number: UInt32 = self.withUnsafeBytes {
        return $0.pointee
      }
      return number
    }
  }
}

extension Data {
  var uuid: UUID? {
    get {
      let bytes: uuid_t = self.withUnsafeBytes {
        return $0.pointee
      }
      return UUID(uuid: bytes)
    }
  }
}

extension Data {
  var stringASCII: String? {
    get {
      return NSString(data: self, encoding: String.Encoding.ascii.rawValue) as String?
    }
  }
}

extension Data {
  var stringUTF8: String? {
    get {
      return NSString(data: self, encoding: String.Encoding.utf8.rawValue) as String?
    }
  }
}

extension Int {
  var data: Data {
    var int = self
    return Data(bytes: &int, count: MemoryLayout<Int>.size)
  }
}

extension UInt8 {
  var data: Data {
    var int = self
    return Data(bytes: &int, count: MemoryLayout<UInt8>.size)
  }
}

extension UInt16 {
  var data: Data {
    var int = self
    return Data(bytes: &int, count: MemoryLayout<UInt16>.size)
  }
}

extension UInt32 {
  var data: Data {
    var int = self
    return Data(bytes: &int, count: MemoryLayout<UInt32>.size)
  }
}

extension UUID {
  var data: Data {
    var uuid = self.uuid
    return Data(bytes: &uuid, count: 16)
  }
}

extension String {
  var dataUTF8: Data? {
    return self.data(using: String.Encoding.utf8)
  }
}

extension NSString {
  var dataASCII: Data? {
    return self.data(using: String.Encoding.ascii.rawValue)
  }
}
