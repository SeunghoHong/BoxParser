
import UIKit

protocol Parser {
    func parse()
}

class BoxParser: Parser {
    fileprivate let dataSource: FilterSource!
    fileprivate var box: Box!

    init(dataSource: DataSource) {
        self.dataSource = FilterSource(dataSource: dataSource)
        self.box = UnknownBox(size: 0, type: "uuid".fourcc, offset: 0)
    }

    func parse() {
        self.parseInternal(0, end: self.dataSource.size, box: self.box)
    }

    fileprivate func parseInternal(_ offset: UInt64, end: UInt64, box: Box) {
        guard offset < self.dataSource.size else {
            return
        }

        var offset = offset
        while offset < end {
            if var box = BoxFactory.createBox(dataSource, offset: &offset) {
                box.parseBasicProperties(dataSource, offset: &offset)
                box.parseProperties(dataSource, offset: &offset)
                box.showLog()

                if box.hasChild {
                    self.parseInternal(offset, end:box.offset+UInt64(box.size), box: box)
                }

                offset = box.offset+UInt64(box.size)
            }
        }
    }
}
