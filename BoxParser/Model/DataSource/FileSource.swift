
import UIKit

final class FileSource: DataSource {
    let uri: String
    let size: UInt64

    lazy fileprivate var fileHandle: FileHandle! = {
        print("\(self.uri)")
        return FileHandle(forReadingAtPath: self.uri)
    }()

    init?(uri: String) {
        self.uri = uri
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: self.uri) as NSDictionary
            self.size = attributes.fileSize();
        } catch let e {
            print("E: \(e)")
            return nil
        }
    }

    deinit {
        print(#function)
        if let fileHandle = self.fileHandle {
            fileHandle.closeFile()
        }
    }

    func read(_ offset: inout UInt64, size: UInt32) throws -> Data! {
        if let fileHandle = self.fileHandle {
            fileHandle.seek(toFileOffset: offset)
            offset += UInt64(size)
            return fileHandle.readData(ofLength: Int(size))
        } else {
            throw DataSourceError.ioError
        }
    }
}
