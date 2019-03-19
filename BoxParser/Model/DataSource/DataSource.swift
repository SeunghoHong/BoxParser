
import UIKit

enum Result<T> {
    case value(T)
    case error(NSError)
}

enum DataSourceError: Error {
    case ioError
}

protocol DataSource {
    var uri: String { get }
    var size: UInt64 { get }
    func read(_ offset: inout UInt64, size: UInt32) throws -> Data!
}
