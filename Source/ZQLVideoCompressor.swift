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
    if videoNaturaSize.width < targetSize.width && videoNaturaSize.height < targetSize.height {
      throw CompressError.targetSizeNotCorrect
    }


    let fitRect:CGRect
    if isKeepAspectRatio {
      fitRect = AVMakeRect(aspectRatio: videoNaturaSize, insideRect: CGRect(origin: CGPoint.zero, size: targetSize))
    }else {
      fitRect = CGRect(origin: CGPoint.zero, size: targetSize)
    }

    let mainInstruction = AVMutableVideoCompositionInstruction()
    mainInstruction.timeRange = cropTimeRange
    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)

    let finalTransform:CGAffineTransform
    if info.isPortrait {
      finalTransform = originTransform.concatenating(CGAffineTransform(scaleX: fitRect.width/videoNaturaSize.width, y: fitRect.height/videoNaturaSize.height)).concatenating(CGAffineTransform(translationX: fitRect.minX, y: fitRect.minY))
    }else {
      finalTransform = originTransform.concatenating(CGAffineTransform(scaleX: fitRect.width/videoNaturaSize.width, y: fitRect.height/videoNaturaSize.height)).concatenating(CGAffineTransform(translationX: fitRect.minX, y: fitRect.minY))
    }
    layerInstruction.setTransform(finalTransform, at: beginTime)
    mainInstruction.layerInstructions = [layerInstruction]

    let videoComposition = AVMutableVideoComposition()
    videoComposition.frameDuration = CMTimeMake(1, 30)
    videoComposition.renderSize = targetSize
    videoComposition.instructions = [mainInstruction]


    if FileManager.default.fileExists(atPath: outputPath) {
      try FileManager.default.removeItem(atPath: outputPath)
    }
    let outputURL = URL(fileURLWithPath: outputPath)
    guard let exporter = AVAssetExportSession(asset: self.videoAsset, presetName: AVAssetExportPresetHighestQuality) else{
      print("generate export failed")
      return
    }
    exporter.outputURL = outputURL
    exporter.outputFileType = AVFileType.mp4
    exporter.shouldOptimizeForNetworkUse = false
    exporter.videoComposition = videoComposition
    exporter.exportAsynchronously(completionHandler: {
      if exporter.status == .failed {

      }else if exporter.status == .completed {

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

  fileprivate func videoCompositionInstructionForTrack(track: AVCompositionTrack, videoTrack: AVAssetTrack, targetSize:CGSize) -> AVMutableVideoCompositionLayerInstruction {
    let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)

    let transform = videoTrack.preferredTransform
    let assetInfo = orientationFromTransform(transform: transform)

    var scaleToFitRatio = targetSize.width / videoTrack.naturalSize.width
    if assetInfo.isPortrait {
      scaleToFitRatio = targetSize.width / videoTrack.naturalSize.height
      let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)

      instruction.setTransform(videoTrack.preferredTransform.concatenating(scaleFactor), at: kCMTimeZero)
    } else {
      let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)

      var concat = videoTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: targetSize.width/2))
      if assetInfo.orientation == .down {
        let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat.pi)
        let yFix = videoTrack.naturalSize.height + targetSize.height
        let centerFix = CGAffineTransform(translationX: videoTrack.naturalSize.width, y: yFix)
        concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
      }
      instruction.setTransform(concat, at: kCMTimeZero)
    }

    return instruction
  }

  /*
   func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
   let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
   let assetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0]

   let transform = assetTrack.preferredTransform
   let assetInfo = orientationFromTransform(transform)

   var scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.width
   if assetInfo.isPortrait {
   scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.height
   let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
   instruction.setTransform(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor),
   atTime: kCMTimeZero)
   } else {
   let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
   var concat = CGAffineTransformConcat(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor), CGAffineTransformMakeTranslation(0, UIScreen.mainScreen().bounds.width / 2))
   if assetInfo.orientation == .Down {
   let fixUpsideDown = CGAffineTransformMakeRotation(CGFloat(M_PI))
   let windowBounds = UIScreen.mainScreen().bounds
   let yFix = assetTrack.naturalSize.height + windowBounds.height
   let centerFix = CGAffineTransformMakeTranslation(assetTrack.naturalSize.width, yFix)
   concat = CGAffineTransformConcat(CGAffineTransformConcat(fixUpsideDown, centerFix), scaleFactor)
   }
   instruction.setTransform(concat, atTime: kCMTimeZero)
   }

   return instruction
   }
   */
}
