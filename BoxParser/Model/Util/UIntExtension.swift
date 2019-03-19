
import UIKit

extension UInt32 {// : BooleanType {
    public var boolValue: Bool {
        return self != 0
    }
}

extension UInt32 {
    var fourcc: String {
        get {
            let cs = UnsafeMutablePointer<CChar>.allocate(capacity: 5)
            var ptr = cs
            ptr.pointee = Int8(self >> 24)
            ptr = ptr.successor()
            ptr.pointee = Int8((self >> 16) & 0xff)
            ptr = ptr.successor()
            ptr.pointee = Int8((self >> 8) & 0xff)
            ptr = ptr.successor()
            ptr.pointee = Int8(self & 0xff)
            ptr = ptr.successor()
            ptr.pointee = 0
            return String(cString: cs)
        }
    }
}
