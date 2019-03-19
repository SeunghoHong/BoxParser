
import UIKit

protocol Box {
  var size: UInt32 { get }
  var type: UInt32 { get }
  var largeSize: UInt64 { get }
  var offset: UInt64 { get }
  var hasChild: Bool { get }
  
  var sibiling: Box! { get }
  var children: [Box]! { get }
  
  mutating func parseBasicProperties(_ dataSource: FilterSource, offset: inout UInt64)
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64)
  
  func showLog()
}

extension Box {
  func showHeader() {
    print("type: \(self.type.fourcc), offset: \(self.offset), size: \(self.size)")
  }
  
  mutating func parseBasicProperties(_ dataSource: FilterSource, offset: inout UInt64) {}
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {}
}

protocol FullBox: Box {
  var version: UInt8 { set get }
  var flag: UInt32 { set get }
}

extension FullBox {
  mutating func parseBasicProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      if self.type == "uuid".fourcc {
        let data = try dataSource.read(&offset, size: 16)
        if let uuid = data?.uuid {
          print("\(uuid.uuidString)")
          let psshUUID = UUID(uuidString: "d08a4f18-10f3-4a82-b6c8-32d8aba183d3")
          print("\(psshUUID?.uuidString as Optional)")
          if uuid == psshUUID {
            print("pssh")
          }
        }
      }
      self.version = try dataSource.readUInt8(&offset)
      self.flag = try dataSource.readUInt24(&offset)
    } catch let e {
      print("E: get mvhd basic properties error")
      print("\(e)")
    }
  }
}

struct UnknownBox: Box {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  func showLog() {
    showHeader()
  }
}

struct UnknownFullBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false

  var version: UInt8 = 0
  var flag: UInt32 = 0

  var sibiling: Box! = nil
  var children: [Box]! = []

  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }

  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
  }
  
  func showLog() {
    showHeader()
  }
}

struct FileTypeBox: Box {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var majorBrand: UInt32!
  var minorBrand: UInt32!
  var compatibleBrands: [UInt32?] = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.majorBrand = try dataSource.readUInt32(&offset)
      self.minorBrand = try dataSource.readUInt32(&offset)
      
      while offset < self.offset+UInt64(self.size) {
        let compatibleBrand = try dataSource.readUInt32(&offset)
        self.compatibleBrands.append(compatibleBrand)
      }
    } catch let e {
      print("\(e)")
      print("E: get ftyp properties error")
    }
  }
  
  func showLog() {
    showHeader()
    print("major brand: \(self.majorBrand.fourcc)")
    print("minor brand: \(self.minorBrand.fourcc)")
    for compatibleBrand in self.compatibleBrands {
      print("compatible brand: \(compatibleBrand?.fourcc)")
    }
  }
}

struct MovieBox: Box {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = true
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  func showLog() {
    showHeader()
  }
}

struct MovieHeaderBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var creationTime: UInt64!
  var modificationTime: UInt64!
  var timescale: UInt32!
  var duration: UInt64!
  
  var rate: UInt32!
  var volume: UInt16!
  var reserved16: UInt16!
  var reserved32s: [UInt32?] = [UInt32!](repeating: nil, count: 2)
  var matrixes: [UInt32?] = [UInt32!](repeating: nil, count: 9)
  var preDefineds: [UInt32?] = [UInt32!](repeating: nil, count: 6)
  var nextTrackID: UInt32!
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      if self.version == 1 {
        self.creationTime = try dataSource.readUInt64(&offset)
        self.modificationTime = try dataSource.readUInt64(&offset)
        self.timescale = try dataSource.readUInt32(&offset)
        self.duration = try dataSource.readUInt64(&offset)
      } else {
        self.creationTime = UInt64(try dataSource.readUInt32(&offset))
        self.modificationTime = UInt64(try dataSource.readUInt32(&offset))
        self.timescale = try dataSource.readUInt32(&offset)
        self.duration = UInt64(try dataSource.readUInt32(&offset))
      }
      
      self.rate = try dataSource.readUInt32(&offset)
      self.volume = try dataSource.readUInt16(&offset)
      self.reserved16 = try dataSource.readUInt16(&offset)
      for i in 0 ..< self.reserved32s.count {
        self.reserved32s[i] = try dataSource.readUInt32(&offset)
      }
      for i in 0 ..< self.matrixes.count {
        self.matrixes[i] = try dataSource.readUInt32(&offset)
      }
      for i in 0 ..< self.preDefineds.count {
        self.preDefineds[i] = try dataSource.readUInt32(&offset)
      }
      self.nextTrackID = try dataSource.readUInt32(&offset)
    } catch let e {
      print("E: get mvhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    
    print("creationTime: \(self.creationTime)")
    print("modificationTime: \(self.modificationTime)")
    print("timescale: \(self.timescale)")
    print("duration: \(self.duration)")
    print("rate: \(self.rate)")
    print("volume: \(self.volume)")
    print("reserved16: \(self.reserved16)")
    print("reserved32s: \(self.reserved32s.count)")
    print("matrix: \(self.matrixes.count)")
    print("preDefined: \(self.preDefineds.count)")
    print("nextTrackID: \(self.nextTrackID)")
  }
}

struct TrackBox: Box {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = true
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  func showLog() {
    showHeader()
  }
}

struct TrackHeaderBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var creationTime: UInt64!
  var modificationTime: UInt64!
  var trackID: UInt32!
  var reserved32: UInt32!
  var duration: UInt64!
  
  var reserved32s: [UInt32?] = [UInt32!](repeating: nil, count: 2)
  var layer: UInt16!
  var alternateGroup: UInt16!
  var volume: UInt16!
  var reserved16: UInt16!
  var matrixes: [UInt32?] = [UInt32!](repeating: nil, count: 9)
  var width: UInt32!
  var height: UInt32!
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      if self.version == 1 {
        self.creationTime = try dataSource.readUInt64(&offset)
        self.modificationTime = try dataSource.readUInt64(&offset)
        self.trackID = try dataSource.readUInt32(&offset)
        self.reserved32 = try dataSource.readUInt32(&offset)
        self.duration = try dataSource.readUInt64(&offset)
      } else {
        self.creationTime = UInt64(try dataSource.readUInt32(&offset))
        self.modificationTime = UInt64(try dataSource.readUInt32(&offset))
        self.trackID = try dataSource.readUInt32(&offset)
        self.reserved32 = try dataSource.readUInt32(&offset)
        self.duration = UInt64(try dataSource.readUInt32(&offset))
      }
      
      for i in 0 ..< self.reserved32s.count {
        self.reserved32s[i] = try dataSource.readUInt32(&offset)
      }
      self.layer = try dataSource.readUInt16(&offset)
      self.alternateGroup = try dataSource.readUInt16(&offset)
      self.volume = try dataSource.readUInt16(&offset)
      self.reserved16 = try dataSource.readUInt16(&offset)
      for i in 0 ..< self.matrixes.count {
        self.matrixes[i] = try dataSource.readUInt32(&offset)
      }
      self.width = try dataSource.readUInt32(&offset)
      self.height = try dataSource.readUInt32(&offset)
    } catch let e {
      print("E: get mvhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    
    print("creationTime: \(self.creationTime)")
    print("modificationTime: \(self.modificationTime)")
    print("trackID: \(self.trackID)")
    print("duration: \(self.duration)")
    print("layer: \(self.layer)")
    print("alternateGroup: \(self.alternateGroup)")
    print("volume: \(self.volume)")
    print("reserved16: \(self.reserved16)")
    print("reserved32s: \(self.reserved32s.count)")
    print("matrix: \(self.matrixes.count)")
    print("width: \(self.width)")
    print("height: \(self.height)")
  }
}

struct MediaBox: Box {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = true
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  func showLog() {
    showHeader()
  }
}

struct MediaHeaderBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var creationTime: UInt64!
  var modificationTime: UInt64!
  var timescale: UInt32!
  var duration: UInt64!
  
  var language: String!
  var preDefineds: UInt16!
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      if self.version == 1 {
        self.creationTime = try dataSource.readUInt64(&offset)
        self.modificationTime = try dataSource.readUInt64(&offset)
        self.timescale = try dataSource.readUInt32(&offset)
        self.duration = try dataSource.readUInt64(&offset)
      } else {
        self.creationTime = UInt64(try dataSource.readUInt32(&offset))
        self.modificationTime = UInt64(try dataSource.readUInt32(&offset))
        self.timescale = try dataSource.readUInt32(&offset)
        self.duration = UInt64(try dataSource.readUInt32(&offset))
      }
      
      if let language = try dataSource.readUInt16(&offset) {
        let cs = UnsafeMutablePointer<CChar>.allocate(capacity: 4)
        var ptr = cs
        ptr.pointee = Int8((language >> 10) & 0x001f) + 0x60
        ptr = ptr.successor()
        ptr.pointee = Int8((language >> 5) & 0x001f) + 0x60
        ptr = ptr.successor()
        ptr.pointee = Int8((language) & 0x001f) + 0x60
        ptr = ptr.successor()
        ptr.pointee = 0
        self.language = String(cString: cs)
      }
      self.preDefineds = try dataSource.readUInt16(&offset)
    } catch let e {
      print("E: get mdhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    
    print("creationTime: \(self.creationTime)")
    print("modificationTime: \(self.modificationTime)")
    print("timescale: \(self.timescale)")
    print("duration: \(self.duration)")
    print("language: \(self.language)")
    print("volume: \(self.preDefineds)")
  }
}

struct HandlerReferenceBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var preDefineds: UInt32!
  var handlerType: UInt32!
  var reserved32s: [UInt32?] = [UInt32!](repeating: nil, count: 3)
  var name: String!
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.preDefineds = try dataSource.readUInt32(&offset)
      self.handlerType = try dataSource.readUInt32(&offset)
      for i in 0 ..< self.reserved32s.count {
        self.reserved32s[i] = try dataSource.readUInt32(&offset)
      }
    } catch let e {
      print("E: get mdhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    
    print("handlerType: \(self.handlerType.fourcc)")
    print("name: \(self.name)")
  }
}

struct MediaInformationBox: Box {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = true
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  func showLog() {
    showHeader()
  }
}

struct VideoMediaHeaderBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var graphicsmode: UInt16!
  var opcolor: [UInt16?] = [UInt16!](repeating: nil, count: 3)
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.graphicsmode = try dataSource.readUInt16(&offset)
      for i in 0 ..< self.opcolor.count {
        self.opcolor[i] = try dataSource.readUInt16(&offset)
      }
    } catch let e {
      print("E: get vmhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    
    print("graphicsmode: \(self.graphicsmode)")
    print("opcolor: \(self.opcolor)")
  }
}

struct SoundMediaHeaderBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var balance: UInt16!
  var reserved: UInt16!
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.balance = try dataSource.readUInt16(&offset)
      self.reserved = try dataSource.readUInt16(&offset)
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    
    print("balance: \(self.balance)")
  }
}

struct HintMediaHeaderBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var maxPDUSize: UInt16!
  var avgPDUSize: UInt16!
  var maxbitrate: UInt32!
  var avgbitrate: UInt32!
  var reserved: UInt32!
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.maxPDUSize = try dataSource.readUInt16(&offset)
      self.avgPDUSize = try dataSource.readUInt16(&offset)
      self.maxbitrate = try dataSource.readUInt32(&offset)
      self.avgbitrate = try dataSource.readUInt32(&offset)
      self.reserved = try dataSource.readUInt32(&offset)
    } catch let e {
      print("E: get hmhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    
    print("maxPDUSize: \(self.maxPDUSize)")
    print("avgPDUSize: \(self.avgPDUSize)")
    print("maxbitrate: \(self.maxbitrate)")
    print("avgbitrate: \(self.avgbitrate)")
  }
}

struct NullMediaHeaderBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
  }
}

struct SampleTableBox: Box {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64 = 0
  let offset: UInt64
  let hasChild: Bool = true
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  init(size: UInt32, type: UInt32, offset: UInt64) {
    self.size = size
    self.type = type
    self.offset = offset
  }
  
  func showLog() {
    showHeader()
  }
}

struct TimeToSampleBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var entryCount: UInt32 = 0
  typealias Entry = (sampleCount: UInt32, sampleDelta: UInt32)
  var entries: [Entry] = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.entryCount = try dataSource.readUInt32(&offset)
      for _ in 0..<self.entryCount {
        if let sampleCount = try dataSource.readUInt32(&offset),
          let sampleDelta = try dataSource.readUInt32(&offset) {
          self.entries.append((sampleCount, sampleDelta))
        }
      }
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    print("entryCount: \(self.entryCount)")
  }
}

struct CompositionOffsetBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var entryCount: UInt32 = 0
  typealias Entry = (sampleCount: UInt32, sampleOffset: UInt32)
  var entries: [Entry] = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.entryCount = try dataSource.readUInt32(&offset)
      for _ in 0..<self.entryCount {
        if let sampleCount = try dataSource.readUInt32(&offset),
          let sampleOffset = try dataSource.readUInt32(&offset) {
          self.entries.append((sampleCount, sampleOffset))
        }
      }
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    print("entryCount: \(self.entryCount)")
  }
}

struct SyncSampleBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var entryCount: UInt32 = 0
  var sampleNumbers: [UInt32] = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.entryCount = try dataSource.readUInt32(&offset)
      for _ in 0..<self.entryCount {
        if let sampleNumber = try dataSource.readUInt32(&offset) {
          self.sampleNumbers.append(sampleNumber)
        }
      }
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    print("entryCount: \(self.entryCount)")
  }
}

struct ShadowSyncSampleBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var entryCount: UInt32 = 0
  typealias Entry = (shadowedSampleNumber: UInt32, syncSampleNumber: UInt32)
  var entries: [Entry] = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.entryCount = try dataSource.readUInt32(&offset)
      for _ in 0..<self.entryCount {
        if let shadowedSampleNumber = try dataSource.readUInt32(&offset),
          let syncSampleNumber = try dataSource.readUInt32(&offset) {
          self.entries.append((shadowedSampleNumber, syncSampleNumber))
        }
      }
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    print("entryCount: \(self.entryCount)")
  }
}

struct SampleToChunkBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var entryCount: UInt32 = 0
  typealias Entry = (firstChunk: UInt32, samplesPerChunk: UInt32, sampleDescriptionIndex: UInt32)
  var entries: [Entry] = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.entryCount = try dataSource.readUInt32(&offset)
      for _ in 0..<self.entryCount {
        if let firstChunk = try dataSource.readUInt32(&offset),
          let samplesPerChunk = try dataSource.readUInt32(&offset),
          let sampleDescriptionIndex = try dataSource.readUInt32(&offset) {
          self.entries.append((firstChunk, samplesPerChunk, sampleDescriptionIndex))
        }
      }
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    print("entryCount: \(self.entryCount)")
  }
}

struct ChunkOffsetBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var entryCount: UInt32 = 0
  var chunkOffsets: [UInt32] = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.entryCount = try dataSource.readUInt32(&offset)
      for _ in 0..<self.entryCount {
        if let chunkOffset = try dataSource.readUInt32(&offset) {
          self.chunkOffsets.append(chunkOffset)
        }
      }
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    print("entryCount: \(self.entryCount)")
  }
}

struct ChunkLargeOffsetBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var entryCount: UInt32 = 0
  var chunkOffsets: [UInt64] = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.entryCount = try dataSource.readUInt32(&offset)
      for _ in 0..<self.entryCount {
        if let chunkOffset = try dataSource.readUInt64(&offset) {
          self.chunkOffsets.append(chunkOffset)
        }
      }
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    print("entryCount: \(self.entryCount)")
  }
}

struct SampleSizeBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var sampleSize: UInt32 = 0
  var sampleCount: UInt32 = 0
  var entrySizes: [UInt32] = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.sampleSize = try dataSource.readUInt32(&offset)
      self.sampleCount = try dataSource.readUInt32(&offset)
      if self.sampleSize == 0 {
        for _ in 0..<self.sampleCount {
          if let entrySize = try dataSource.readUInt32(&offset) {
            self.entrySizes.append(entrySize)
          }
        }
      }
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    print("sampleSize: \(self.sampleSize)")
    print("sampleCount: \(self.sampleCount)")
  }
}

/*
 struct CompactSampleSizeBox: FullBox {
 }
 */

struct SampleDescriptionBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = true
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var entryCount: UInt32!
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.entryCount = try dataSource.readUInt32(&offset)
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
  }
}

// ISO 14496-14
protocol SampleEntryBox: Box {
  var reserved8s: [UInt8?] { get }
  var dataReferenceIndex: UInt16 { get }
}

protocol VisualSampleEnty: SampleEntryBox {
  var preDefined: UInt16 { get }
  var reserved16: UInt16 { get }
  var preDefineds: [UInt32?] { get }
  var width: UInt16 { get }
  var height: UInt16 { get }
  var horizresolution: UInt32 { get }
  var vertresolution: UInt32 { get }
  var reserved32: UInt32 { get }
  var frameCount: UInt16 { get }
  var compressorname: String { get }
  var depth: UInt16 { get }
  var preDefined2: UInt16 { get }
}

struct MP4VisualSampleDescriptionBox: VisualSampleEnty {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = true
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var reserved8s: [UInt8?] = [UInt8!](repeating: nil, count: 6)
  var dataReferenceIndex: UInt16 = 0
  
  var preDefined: UInt16 = 0
  var reserved16: UInt16 = 0
  var preDefineds: [UInt32?] = [UInt32!](repeating: nil, count: 3)
  var width: UInt16 = 0
  var height: UInt16 = 0
  var horizresolution: UInt32 = 0
  var vertresolution: UInt32 = 0
  var reserved32: UInt32 = 0
  var frameCount: UInt16 = 0
  var compressorname: String = ""
  var depth: UInt16 = 0
  var preDefined2: UInt16 = 0
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      for i in 0 ..< self.reserved8s.count {
        self.reserved8s[i] = try dataSource.readUInt8(&offset)
      }
      self.dataReferenceIndex = try dataSource.readUInt16(&offset)
      
      self.preDefined = try dataSource.readUInt16(&offset)
      self.reserved16 = try dataSource.readUInt16(&offset)
      for i in 0 ..< self.preDefineds.count {
        self.preDefineds[i] = try dataSource.readUInt32(&offset)
      }
      self.width = try dataSource.readUInt16(&offset)
      self.height = try dataSource.readUInt16(&offset)
      self.horizresolution = try dataSource.readUInt32(&offset)
      self.vertresolution = try dataSource.readUInt32(&offset)
      self.reserved32 = try dataSource.readUInt32(&offset)
      self.frameCount = try dataSource.readUInt16(&offset)
      if let data = try dataSource.read(&offset, size: 4) {
        self.compressorname = String(data: data, encoding: String.Encoding.utf8) ?? ""
      }
      self.depth = try dataSource.readUInt16(&offset)
      self.preDefined2 = try dataSource.readUInt16(&offset)
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    
    print("dataReferenceIndex: \(self.dataReferenceIndex)")
    print("width: \(self.width)")
    print("height: \(self.height)")
    print("horizresolution: \(self.horizresolution)")
    print("vertresolution: \(self.vertresolution)")
    print("frameCount: \(self.frameCount)")
    print("compressorname: \(self.compressorname)")
    print("depth: \(self.depth)")
  }
}

protocol AudioSampleEntryBox: SampleEntryBox {
  var reserved32s: [UInt32?] { get }
  var channelCount: UInt16 { get }
  var sampleSize: UInt16 { get }
  var preDefined: UInt16 { get }
  var reserved16: UInt16 { get }
  var sampleRate: UInt32 { get }
}

struct MP4AudioSampleDescriptionBox: AudioSampleEntryBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = true
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var reserved8s: [UInt8?] = [UInt8!](repeating: nil, count: 6)
  var dataReferenceIndex: UInt16 = 0
  
  var reserved32s: [UInt32?] = [UInt32!](repeating: nil, count: 2)
  var channelCount: UInt16 = 2
  var sampleSize: UInt16 = 16
  var preDefined: UInt16 = 0
  var reserved16: UInt16 = 0
  var sampleRate: UInt32 = 0
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      for i in 0 ..< self.reserved8s.count {
        self.reserved8s[i] = try dataSource.readUInt8(&offset)
      }
      self.dataReferenceIndex = try dataSource.readUInt16(&offset)
      
      for i in 0 ..< self.reserved32s.count {
        self.reserved32s[i] = try dataSource.readUInt32(&offset)
      }
      self.channelCount = try dataSource.readUInt16(&offset)
      self.sampleSize = try dataSource.readUInt16(&offset)
      self.preDefined = try dataSource.readUInt16(&offset)
      self.reserved16 = try dataSource.readUInt16(&offset)
      self.sampleRate = try dataSource.readUInt32(&offset) >> 16
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    
    print("dataReferenceIndex: \(self.dataReferenceIndex)")
    print("channelCount: \(self.channelCount)")
    print("sampleSize: \(self.sampleSize)")
    print("sampleRate: \(self.sampleRate)")
  }
}

struct ESDBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  // ISO/IEC 14496-1 7.2.6.5
  var esDescriptor: Data!
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      let remain: UInt32 = self.size-UInt32((offset-self.offset))
      self.esDescriptor = try dataSource.read(&offset, size: remain)
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
  }
}

// ISO 14496-15
struct AVCConfigurationBox: Box {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  // AAVCDecoderConfigurationRecord
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  func showLog() {
    showHeader()
  }
}

struct AVCSampleEntryBox: VisualSampleEnty {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = true
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var reserved8s: [UInt8?] = [UInt8!](repeating: nil, count: 6)
  var dataReferenceIndex: UInt16 = 0
  
  var preDefined: UInt16 = 0
  var reserved16: UInt16 = 0
  var preDefineds: [UInt32?] = [UInt32!](repeating: nil, count: 3)
  var width: UInt16 = 0
  var height: UInt16 = 0
  var horizresolution: UInt32 = 0
  var vertresolution: UInt32 = 0
  var reserved32: UInt32 = 0
  var frameCount: UInt16 = 0
  var compressorname: String = ""
  var depth: UInt16 = 0
  var preDefined2: UInt16 = 0
  
  // AVCConfigurationBox
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      for i in 0 ..< self.reserved8s.count {
        self.reserved8s[i] = try dataSource.readUInt8(&offset)
      }
      self.dataReferenceIndex = try dataSource.readUInt16(&offset)
      
      self.preDefined = try dataSource.readUInt16(&offset)
      self.reserved16 = try dataSource.readUInt16(&offset)
      for i in 0 ..< self.preDefineds.count {
        self.preDefineds[i] = try dataSource.readUInt32(&offset)
      }
      self.width = try dataSource.readUInt16(&offset)
      self.height = try dataSource.readUInt16(&offset)
      self.horizresolution = try dataSource.readUInt32(&offset)
      self.vertresolution = try dataSource.readUInt32(&offset)
      self.reserved32 = try dataSource.readUInt32(&offset)
      self.frameCount = try dataSource.readUInt16(&offset)
      if let data = try dataSource.read(&offset, size: 32) {
        self.compressorname = String(data: data, encoding: String.Encoding.utf8) ?? ""
      }
      self.depth = try dataSource.readUInt16(&offset)
      self.preDefined2 = try dataSource.readUInt16(&offset)
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    
    print("dataReferenceIndex: \(self.dataReferenceIndex)")
    print("width: \(self.width)")
    print("height: \(self.height)")
    print("horizresolution: \(self.horizresolution)")
    print("vertresolution: \(self.vertresolution)")
    print("frameCount: \(self.frameCount)")
    print("compressorname: \(self.compressorname)")
    print("depth: \(self.depth)")
  }
}

struct MovieExtendsBox: Box {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = true
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  func showLog() {
    showHeader()
  }
}

struct MovieExtendsHeaderBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8
  var flag: UInt32
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var fragmentDuration: UInt64 = 0
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
    
    self.version = 0
    self.flag = 0
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      if self.version == 1 {
        self.fragmentDuration = try dataSource.readUInt64(&offset)
      } else {
        self.fragmentDuration = UInt64(try dataSource.readUInt32(&offset))
      }
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    print("fragmentDuration: \(self.fragmentDuration)")
  }
}

struct TrackExtendsBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8
  var flag: UInt32
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var trackID: UInt32 = 0
  var defaultSampleDescriptionIndex: UInt32 = 0
  var defaultSampleDuration: UInt32 = 0
  var defaultSampleSize: UInt32 = 0
  var defaultSampleFlags: UInt32 = 0
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
    
    self.version = 0
    self.flag = 0
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.trackID = try dataSource.readUInt32(&offset)
      self.defaultSampleDescriptionIndex = try dataSource.readUInt32(&offset)
      self.defaultSampleDuration = try dataSource.readUInt32(&offset)
      self.defaultSampleSize = try dataSource.readUInt32(&offset)
      self.defaultSampleFlags = try dataSource.readUInt32(&offset)
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    print("trackID: \(self.trackID)")
    print("defaultSampleDescriptionIndex: \(self.defaultSampleDescriptionIndex)")
    print("defaultSampleDuration: \(self.defaultSampleDuration)")
    print("defaultSampleSize: \(self.defaultSampleSize)")
    print("defaultSampleFlags: \(self.defaultSampleFlags)")
  }
}

struct MovieFragmentBox: Box {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = true
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  func showLog() {
    showHeader()
  }
}

struct MovieFragmentHeaderBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8
  var flag: UInt32
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var sequenceNumber: UInt32 = 0
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
    
    self.version = 0
    self.flag = 0
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.sequenceNumber = try dataSource.readUInt32(&offset)
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    print("sequenceNumber: \(self.sequenceNumber)")
  }
}

struct TrackFragmentBox: Box {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = true
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  func showLog() {
    showHeader()
  }
}

struct TrackFragmentHeaderBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8
  var flag: UInt32
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var trackID: UInt32 = 0
  var baseDataOffset: UInt64 = 0
  var sampleDescriptionIndex: UInt32 = 0
  var defaultSampleDuration: UInt32 = 0
  var defaultSampleSize: UInt32 = 0
  var defaultSampleFlags: UInt32 = 0
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
    
    self.version = 0
    self.flag = 0
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.trackID = try dataSource.readUInt32(&offset)
      if (self.flag & 0x000001) != 0x000000 {
        self.baseDataOffset = try dataSource.readUInt64(&offset)
      }
      if (self.flag & 0x000002) != 0x000000 {
        self.sampleDescriptionIndex = try dataSource.readUInt32(&offset)
      }
      if (self.flag & 0x000008) != 0x000000 {
        self.defaultSampleDuration = try dataSource.readUInt32(&offset)
      }
      if (self.flag & 0x000010) != 0x000000 {
        self.defaultSampleSize = try dataSource.readUInt32(&offset)
      }
      if (self.flag & 0x000020) != 0x000000 {
        self.defaultSampleFlags = try dataSource.readUInt32(&offset)
      }
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    print("trackID: \(self.trackID)")
    print("baseDataOffset: \(self.baseDataOffset)")
    print("sampleDescriptionIndex: \(self.sampleDescriptionIndex)")
    print("defaultSampleDuration: \(self.defaultSampleDuration)")
    print("defaultSampleSize: \(self.defaultSampleSize)")
    print("defaultSampleFlags: \(self.defaultSampleFlags)")
  }
}

struct TrackRunBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8
  var flag: UInt32
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var sampleCount: UInt32 = 0
  var dataOffset: UInt32 = 0
  var firstSampleFlags: UInt32 = 0
  typealias Sample = (sampleDuration: UInt32, sampleSize: UInt32, sampleFlags: UInt32, sampleCompositionTimeOffset: Int32)
  var samples: [Sample] = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
    
    self.version = 0
    self.flag = 0
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.sampleCount = try dataSource.readUInt32(&offset)
      
      if (self.flag & 0x000001) != 0x000000 {
        self.dataOffset = try dataSource.readUInt32(&offset)
      }
      if (self.flag & 0x000004) != 0x000000 {
        self.firstSampleFlags = try dataSource.readUInt32(&offset)
      }
      for _ in 0 ..< self.sampleCount {
        var sampleDuration: UInt32 = 0
        var sampleSize: UInt32 = 0
        var sampleFlags: UInt32 = 0
        var sampleCompositionTimeOffset: UInt32 = 0
        
        if (self.flag & 0x000100) != 0x000000 {
          sampleDuration = try dataSource.readUInt32(&offset)
        }
        if (self.flag & 0x000200) != 0x000000 {
          sampleSize = try dataSource.readUInt32(&offset)
        }
        if (self.flag & 0x000400) != 0x000000 {
          sampleFlags = try dataSource.readUInt32(&offset)
        }
        if (self.flag & 0x000800) != 0x000000 {
          sampleCompositionTimeOffset = try dataSource.readUInt32(&offset)
        }
        self.samples.append((sampleDuration, sampleSize, sampleFlags, Int32(bitPattern: sampleCompositionTimeOffset)))
      }
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    print("sampleCount: \(self.sampleCount)")
    print("dataOffset: \(self.dataOffset)")
    print("firstSampleFlags: \(self.firstSampleFlags)")
    for sample in self.samples {
      print("duration: \(sample.sampleDuration), size: \(sample.sampleSize), flag: \(sample.sampleFlags), compositionTimeOffset: \(sample.sampleCompositionTimeOffset)")
    }
  }
}

struct MediaDataBox: Box {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  func showLog() {
    showHeader()
  }
}

struct MovieFragmentRandomAccessBox: Box {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = true
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  func showLog() {
    showHeader()
  }
}

struct TrackFragmentRandomAccessBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var trackID: UInt32 = 0
  var reserved26: UInt32 = 0
  var lengthSizeOfTrafNum: UInt32 = 0
  var lengthSizeOfTrunNum: UInt32 = 0
  var lengthSizeOfSampleNum: UInt32 = 0
  
  var numberOfEntry: UInt32 = 0
  typealias Entry = (time: UInt64, moofOffset: UInt64, trafNumber: Data, trunNumber: Data, sampleNumber: Data)
  var entries: [Entry] = []
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.trackID = try dataSource.readUInt32(&offset)
      if let temp = try dataSource.readUInt32(&offset) {
        self.reserved26 = temp >> 6
        self.lengthSizeOfTrafNum = (temp >> 4) & 0x03
        self.lengthSizeOfTrunNum = (temp >> 2) & 0x03
        self.lengthSizeOfSampleNum = temp & 0x03
      }
      
      self.numberOfEntry = try dataSource.readUInt32(&offset)
      for _ in 0 ..< self.numberOfEntry {
        var time: UInt64 = 0
        var moofOffset: UInt64 = 0
        if self.version == 1 {
          time = try dataSource.readUInt64(&offset)
          moofOffset = try dataSource.readUInt64(&offset)
        } else {
          time = UInt64(try dataSource.readUInt32(&offset))
          moofOffset = UInt64(try dataSource.readUInt32(&offset))
        }
        if let trafNumber = try dataSource.read(&offset, size: self.lengthSizeOfTrafNum+1),
          let trunNumber = try dataSource.read(&offset, size: self.lengthSizeOfTrafNum+1),
          let sampleNumber = try dataSource.read(&offset, size: self.lengthSizeOfTrafNum+1) {
          self.entries.append((time: time, moofOffset: moofOffset, trafNumber: trafNumber, trunNumber: trunNumber, sampleNumber: sampleNumber))
        }
      }
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    for entry in self.entries {
      print("time: \(entry.time), moofOffset: \(entry.moofOffset)")
    }
  }
}

struct MovirFragmentRandomAccessBox: FullBox {
  let size: UInt32
  let type: UInt32
  let largeSize: UInt64
  let offset: UInt64
  let hasChild: Bool = false
  
  var version: UInt8 = 0
  var flag: UInt32 = 0
  
  var sibiling: Box! = nil
  var children: [Box]! = []
  
  var mfraSize: UInt32 = 0
  
  init(size: UInt32, type: UInt32, offset: UInt64, largeSize: UInt64 = 0) {
    self.size = size
    self.type = type
    self.offset = offset
    self.largeSize = largeSize
  }
  
  mutating func parseProperties(_ dataSource: FilterSource, offset: inout UInt64) {
    do {
      self.mfraSize = try dataSource.readUInt32(&offset)
    } catch let e {
      print("E: get smhd properties error")
      print("\(e)")
    }
  }
  
  func showLog() {
    showHeader()
    print("version: \(self.version)")
    print("flas: \(self.flag)")
    print("mfraSize: \(self.mfraSize)")
  }
}

