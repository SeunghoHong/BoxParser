
import UIKit

extension String {
    var fourcc: UInt32 {
        get {
            if let cs = self.cString(using: String.Encoding.utf8) , cs.count == 5 {
                let cs0: UInt32 = UInt32(cs[0]) << 24
                let cs1: UInt32 = UInt32(cs[1]) << 16
                let cs2: UInt32 = UInt32(cs[2]) << 8
                let cs3: UInt32 = UInt32(cs[3])
                return (cs0 | cs1 | cs2 | cs3)
            } else {
                return 0
            }
        }
    }
}
