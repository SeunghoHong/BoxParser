
import UIKit

enum BoxFactory: String {
  case unknown
  case uuid
  case ftyp
  case moov
  case mvhd
  case trak
  case tkhd
  case mdia
  case mdhd
  case hdlr
  case minf
  case vmhd
  case smhd
  case hmhd
  case nmhd
  case stbl
  case stts
  case ctts
  case stss
  case stsh
  case stsc
  case stco
  case co64
  case stsz
  case stz2
  case stsd
  case mp4a
  case mp4v
  case esds
  case avcC
  case avc1
  case avc2
  case avc3
  case mvex
  case mehd
  case trex
  case moof
  case mfhd
  case traf
  case tfhd
  case trun
  case mdat
  case mfra
  case tfra
  case mfro
  case pssh // uuid=d08a4f18-10f3-4a82-b6c8-32d8aba183d3
  case senc // uuid=a2394f52-5a9b-4f14-a244-6c427c648df4
  case tenc // uuid=8974dbce-7be7-4c51-84f9-7148f9882554
  case tfxd // uuid=6d1d9b05-42d5-44e6-80e2-141daff757b2
  case tfrf // uuid=d4807ef2-ca39-4695-8e54-26cb9e46a79f
  
  static func createBox(_ dataSource: FilterSource, offset: inout UInt64, handlerType: UInt32! = nil) -> Box! {
    do {
      let start: UInt64 = offset
      guard let size = try dataSource.readUInt32(&offset),
        let type = try dataSource.readUInt32(&offset) else {
          return nil
      }
      
      var largeSize: UInt64 = 0
      if size == 1 {
        largeSize = try dataSource.readUInt64(&offset)
      }
      
      switch type {
      case uuid.rawValue.fourcc:
        return UnknownFullBox(size: size, type: type, offset: start)
      case ftyp.rawValue.fourcc:
        return FileTypeBox(size: size, type: type, offset: start)
      case moov.rawValue.fourcc:
        return MovieBox(size: size, type: type, offset: start)
      case mvhd.rawValue.fourcc:
        return MovieHeaderBox(size: size, type: type, offset: start)
      case trak.rawValue.fourcc:
        return TrackBox(size: size, type: type, offset: start)
      case tkhd.rawValue.fourcc:
        return TrackHeaderBox(size: size, type: type, offset: start)
      case mdia.rawValue.fourcc:
        return MediaBox(size: size, type: type, offset: start)
      case mdhd.rawValue.fourcc:
        return MediaHeaderBox(size: size, type: type, offset: start)
      case hdlr.rawValue.fourcc:
        return HandlerReferenceBox(size: size, type: type, offset: start)
      case minf.rawValue.fourcc:
        return MediaInformationBox(size: size, type: type, offset: start)
      case vmhd.rawValue.fourcc:
        return VideoMediaHeaderBox(size: size, type: type, offset: start)
      case smhd.rawValue.fourcc:
        return SoundMediaHeaderBox(size: size, type: type, offset: start)
      case hmhd.rawValue.fourcc:
        return HintMediaHeaderBox(size: size, type: type, offset: start)
      case nmhd.rawValue.fourcc:
        return NullMediaHeaderBox(size: size, type: type, offset: start)
      case stts.rawValue.fourcc:
        return TimeToSampleBox(size: size, type: type, offset: start)
      case ctts.rawValue.fourcc:
        return CompositionOffsetBox(size: size, type: type, offset: start)
      case stss.rawValue.fourcc:
        return SyncSampleBox(size: size, type: type, offset: start)
      case stsh.rawValue.fourcc:
        return ShadowSyncSampleBox(size: size, type: type, offset: start)
      case stsc.rawValue.fourcc:
        return SampleToChunkBox(size: size, type: type, offset: start)
      case stco.rawValue.fourcc:
        return ChunkOffsetBox(size: size, type: type, offset: start)
      case co64.rawValue.fourcc:
        return ChunkLargeOffsetBox(size: size, type: type, offset: start)
      case stsz.rawValue.fourcc:
        return SampleSizeBox(size: size, type: type, offset: start)
      case stbl.rawValue.fourcc:
        return SampleTableBox(size: size, type: type, offset: start)
      case stsd.rawValue.fourcc:
        return SampleDescriptionBox(size: size, type: type, offset: start)
      case mp4a.rawValue.fourcc:
        return MP4AudioSampleDescriptionBox(size: size, type: type, offset: start)
      case mp4v.rawValue.fourcc:
        return MP4VisualSampleDescriptionBox(size: size, type: type, offset: start)
      case esds.rawValue.fourcc:
        return ESDBox(size: size, type: type, offset: start)
      case avc1.rawValue.fourcc, avc2.rawValue.fourcc, avc3.rawValue.fourcc:
        return AVCSampleEntryBox(size: size, type: type, offset: start)
      case avcC.rawValue.fourcc:
        return AVCConfigurationBox(size: size, type: type, offset: start)
      case mvex.rawValue.fourcc:
        return MovieExtendsBox(size: size, type: type, offset: start)
      case mehd.rawValue.fourcc:
        return MovieExtendsHeaderBox(size: size, type: type, offset: start)
      case trex.rawValue.fourcc:
        return TrackExtendsBox(size: size, type: type, offset: start)
      case moof.rawValue.fourcc:
        return MovieFragmentBox(size: size, type: type, offset: start)
      case mfhd.rawValue.fourcc:
        return MovieFragmentHeaderBox(size: size, type: type, offset: start)
      case traf.rawValue.fourcc:
        return TrackFragmentBox(size: size, type: type, offset: start)
      case tfhd.rawValue.fourcc:
        return TrackFragmentHeaderBox(size: size, type: type, offset: start)
      case trun.rawValue.fourcc:
        return TrackRunBox(size: size, type: type, offset: start)
      case mdat.rawValue.fourcc:
        return MediaDataBox(size: size, type: type, offset: start)
      case mfra.rawValue.fourcc:
        return MovieFragmentRandomAccessBox(size: size, type: type, offset: start)
      case tfra.rawValue.fourcc:
        return TrackFragmentRandomAccessBox(size: size, type: type, offset: start)
      case mfro.rawValue.fourcc:
        return MovirFragmentRandomAccessBox(size: size, type: type, offset: start)
      default:
        return UnknownBox(size: size, type: type, offset: start, largeSize: largeSize)
      }
    } catch let e {
      print("\(e)")
      return nil
    }
  }
}
