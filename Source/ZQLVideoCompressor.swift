//
//  ZQLVideoCompressor.swift
//  ZQLVideoCompressor
//
//  Created by Qilong Zang on 17/01/2018.
//  Copyright © 2018 Qilong Zang. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

enum ZQLTimeRange {
  case naturalRange
  case secondsRange(Double, Double)
  case cmtimeRange(CMTime, CMTime)

  func validateTime(videoTime:CMTime) -> Bool {
    switch self {
    case .naturalRange:
      return true
    case .secondsRange(let begin, let end):
      let seconds = CMTimeGetSeconds(videoTime)
      if end > begin, begin > 0, end < seconds {
        return true
      }else {
        return false
      }
    case .cmtimeRange(_, let end):
      if CMTimeCompare(end, videoTime) == 1 {
        return false
      }else {
        return true
      }
    }
  }
}

enum CompressError:Error {
  case videoFileNotFind
  case videoTrackNotFind
  case audioTrackNotFind
  case targetSizeNotCorrect
  case timeSetNotCorrect
}

class ZQLVideoCompressor: NSObject {
  private let filePath:String
  private let videoAsset:AVURLAsset

  public var isKeepAspectRatio = true

  init(filePath:String) throws {
    guard FileManager.default.fileExists(atPath: filePath) else {
      print("file not exist")
      throw CompressError.videoFileNotFind
    }
    self.filePath = filePath
    self.videoAsset = AVURLAsset(url: URL(fileURLWithPath: filePath))
  }

  func compressVideo(targetSize:CGSize, timeRange:ZQLTimeRange = .naturalRange, outputPath:String) throws {
    guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else{
      throw CompressError.videoTrackNotFind
    }

    guard let audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio).first else {
      throw CompressError.audioTrackNotFind
    }

    guard timeRange.validateTime(videoTime: videoAsset.duration) else {
      throw CompressError.timeSetNotCorrect
    }

    let videoTimeScale = videoAsset.duration.timescale
    let beginTime:CMTime
    let cropTimeRange:CMTimeRange
    switch timeRange {
    case .naturalRange:
      cropTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
      beginTime = kCMTimeZero
    case .secondsRange(let begin, let end):
      beginTime = CMTimeMake(Int64(Double(videoTimeScale) * begin), videoTimeScale)
      cropTimeRange = CMTimeRangeMake(beginTime, CMTimeMake(Int64(Double(videoTimeScale) * end), videoTimeScale))
    case .cmtimeRange(let begin, let end):
      beginTime = begin
      cropTimeRange = CMTimeRangeMake(begin, end)
    }

    let originTransform = videoTrack.preferredTransform
    let info = orientationFromTransform(transform: originTransform)
    let videoNaturaSize:CGSize
    if info.isPortrait {
      videoNaturaSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
    }else {
      videoNaturaSize = videoTrack.naturalSize
    }
    if videoNaturaSize.width < targetSize.width || videoNaturaSize.height < targetSize.height {
      throw CompressError.targetSizeNotCorrect
    }


    let fitSize:CGSize
    if isKeepAspectRatio {
      fitSize = AVMakeRect(aspectRatio: videoNaturaSize, insideRect: CGRect(origin: CGPoint.zero, size: targetSize)).size
    }else {
      fitSize = targetSize
    }

    let compressComposition = AVMutableComposition()
    let videoCompositionTrack = compressComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
    try videoCompositionTrack?.insertTimeRange(cropTimeRange, of: videoTrack, at: beginTime)
    let audioCompositionTrack = compressComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
    try audioCompositionTrack?.insertTimeRange(cropTimeRange, of: audioTrack, at: beginTime)

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = cropTimeRange
    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)

    let concatTransform:CGAffineTransform
    if info.isPortrait && info.orientation == .right {
     // let rotateTransform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
     // let scaleTransform = CGAffineTransform(scaleX: fitSize.width/videoNaturaSize.width, y: fitSize.height/videoNaturaSize.height)
      concatTransform = originTransform.rotated(by: CGFloat.pi/2)
    }else if info.isPortrait && info.orientation == .left {
      let rotateTransform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
      // let scaleTransform = CGAffineTransform(scaleX: fitSize.width/videoNaturaSize.width, y: fitSize.height/videoNaturaSize.height)
      concatTransform = originTransform.concatenating(rotateTransform)
    }else {
      concatTransform = originTransform
    }
    layerInstruction.setTransform(originTransform, at: beginTime)
    instruction.layerInstructions = [layerInstruction]

    let videoComposition = AVMutableVideoComposition()
    videoComposition.frameDuration = CMTimeMake(1, 30)
    videoComposition.renderSize = targetSize
    videoComposition.instructions = [instruction]


    if FileManager.default.fileExists(atPath: outputPath) {
      try FileManager.default.removeItem(atPath: outputPath)
    }
    let outputURL = URL(fileURLWithPath: outputPath)
    let exporter = AVAssetExportSession(asset: compressComposition, presetName: AVAssetExportPresetHighestQuality)
    exporter?.outputURL = outputURL
    exporter?.outputFileType = AVFileType.mov
    exporter?.shouldOptimizeForNetworkUse = false
    exporter?.videoComposition = videoComposition
    exporter?.exportAsynchronously(completionHandler: {
      if exporter?.status == .failed {

      }else if exporter?.status == .completed {

      }
      PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
      }, completionHandler: { (saved, error) in
        if saved {
          
        }
      })
    })

  }

}

extension ZQLVideoCompressor {
  fileprivate func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
    var assetOrientation = UIImageOrientation.up
    var isPortrait = false
    if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
      assetOrientation = .right
      isPortrait = true
    } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
      assetOrientation = .left
      isPortrait = true
    } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
      assetOrientation = .up
    } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
      assetOrientation = .down
    }
    return (assetOrientation, isPortrait)
  }
}
