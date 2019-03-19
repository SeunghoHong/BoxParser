
import UIKit

final class FilterSource: DataSource {
    let uri: String
    let size: UInt64

    let dataSource: DataSource
    
    init?(dataSource: DataSource) {
        self.dataSource = dataSource
        self.uri = dataSource.uri
        self.size = dataSource.size
    }
    
    func read(_ offset: inout UInt64, size: UInt32) throws -> Data! {
        do {
            return try self.dataSource.read(&offset, size: size)
        } catch let e {
            throw e
        }
    }

    func readUInt8(_ offset: inout UInt64) throws -> UInt8! {
        do {
            if let data = try self.dataSource.read(&offset, size: 1) {
                var value: UInt8 = 0
                (data as NSData).getBytes(&value, length: 1)
                return value
            } else {
                print("E: read UInt8 error")
                return nil
            }
        } catch let e {
            throw e
        }
    }

    func readUInt16(_ offset: inout UInt64) throws -> UInt16! {
        do {
            if let data = try self.dataSource.read(&offset, size: 2) {
                var value: UInt16 = 0
                (data as NSData).getBytes(&value, length: 2)
                return value.bigEndian
            } else {
                print("E: read UInt16 error")
                return nil
            }
        } catch let e {
            throw e
        }
    }

    func readUInt24(_ offset: inout UInt64) throws -> UInt32! {
        do {
            if let data = try self.dataSource.read(&offset, size: 3) {
                var value: UInt32 = 0
                (data as NSData).getBytes(&value, length: 3)
                return ((value.bigEndian & 0x00ffffff) >> 8)
            } else {
                print("E: read UInt32 error")
                return nil
            }
        } catch let e {
            throw e
        }
    }

    func readUInt32(_ offset: inout UInt64) throws -> UInt32! {
        do {
            if let data = try self.dataSource.read(&offset, size: 4) {
                var value: UInt32 = 0
                (data as NSData).getBytes(&value, length: 4)
                return value.bigEndian
            } else {
                print("E: read UInt32 error")
                return nil
            }
        } catch let e {
            throw e
        }
    }

    func readUInt64(_ offset: inout UInt64) throws -> UInt64! {
        do {
            if let data = try self.dataSource.read(&offset, size: 8) {
                var value: UInt64 = 0
                (data as NSData).getBytes(&value, length: 8)
                return value.bigEndian
            } else {
                print("E: read UInt64 error")
                return nil
            }
        } catch let e {
            throw e
        }
    }
}
