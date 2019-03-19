
import UIKit

struct MemorySource: DataSource {
    let uri: String
    let size: UInt64
    let data: Data
    
    func read(_ offset: inout UInt64, size: UInt32) throws -> Data! {
        return nil
    }
}
