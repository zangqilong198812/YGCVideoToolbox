//
//  ZQLVideoCompressor.swift
//  ZQLVideoCompressor
//
//  Created by Qilong Zang on 17/01/2018.
//  Copyright © 2018 Qilong Zang. All rights reserved.
//

import UIKit
import AVFoundation

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

    let videoNaturaSize = videoTrack.naturalSize
    if videoNaturaSize.width > targetSize.width || videoNaturaSize.height > targetSize.height {
      throw CompressError.targetSizeNotCorrect
    }

    let compressComposition = AVMutableComposition()
    let videoCompositionTrack = compressComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
    try videoCompositionTrack?.insertTimeRange(cropTimeRange, of: videoTrack, at: beginTime)
    let audioCompositionTrack = compressComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
    try audioCompositionTrack?.insertTimeRange(cropTimeRange, of: audioTrack, at: beginTime)

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = cropTimeRange
    let layerInstruction = AVMutableVideoCompositionLayerInstruction()
    layerInstruction.setTransform(videoTrack.preferredTransform, at: beginTime)
    instruction.layerInstructions = [layerInstruction]


    let videoComposition = AVMutableVideoComposition()
    let fitSize:CGSize
    if isKeepAspectRatio {
      fitSize = AVMakeRect(aspectRatio: videoNaturaSize, insideRect: CGRect(origin: CGPoint.zero, size: targetSize)).size
    }else {
      fitSize = targetSize
    }
    videoComposition.renderSize = fitSize
    videoComposition.instructions = [instruction]

    if FileManager.default.fileExists(atPath: outputPath) {
      try FileManager.default.removeItem(atPath: outputPath)
    }
    let outputURL = URL(fileURLWithPath: outputPath)
    let exporter = AVAssetExportSession(asset: compressComposition, presetName: AVAssetExportPresetHighestQuality)
    exporter?.outputURL = outputURL
    exporter?.outputFileType = AVFileType.mov
    exporter?.shouldOptimizeForNetworkUse = false
    exporter?.exportAsynchronously(completionHandler: {

    })

  }

}
