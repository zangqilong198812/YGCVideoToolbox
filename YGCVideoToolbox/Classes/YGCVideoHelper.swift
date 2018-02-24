//
//  YGCVideoType.swift
//  ZQLVideoCompressor
//
//  Created by zang qilong on 2018/1/20.
//  Copyright © 2018年 Qilong Zang. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

enum YGCVideoError:Error {
  case videoFileNotFind
  case videoTrackNotFind
  case audioTrackNotFind
  case compositionTrackInitFailed
  case targetSizeNotCorrect
  case timeSetNotCorrect
}

public enum YGCTimeRange {
  case naturalRange
  case secondsRange(Double, Double)
  case cmtimeRange(CMTime, CMTime)

  func validateTime(videoTime:CMTime) -> Bool {
    switch self {
    case .naturalRange:
      return true
    case .secondsRange(let begin, let end):
      let seconds = CMTimeGetSeconds(videoTime)
      if end > begin, begin >= 0, end < seconds {
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

public func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
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

public func videoCompositionInstructionForTrack(track: AVCompositionTrack, videoTrack: AVAssetTrack, targetSize:CGSize) -> AVMutableVideoCompositionLayerInstruction {
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

public func exportVideo(outputPath:String, asset:AVAsset, videoComposition:AVMutableVideoComposition?, fileType:AVFileType = AVFileType.mp4, complete:@escaping ((Bool) -> Void)) {
  if FileManager.default.fileExists(atPath: outputPath) {
    do {
      try FileManager.default.removeItem(atPath: outputPath)
    } catch {
      print("remove file failed")
    }
  }
  let outputURL = URL(fileURLWithPath: outputPath)
  guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else{
    print("generate export failed")
    return
  }
  exporter.outputURL = outputURL
  exporter.outputFileType = fileType
  exporter.shouldOptimizeForNetworkUse = false
  if let composition = videoComposition {
    exporter.videoComposition = composition
  }
  exporter.exportAsynchronously(completionHandler: {
    if exporter.status == .completed {
      complete(true)
    }else {
      complete(false)
    }
  })
}

public func saveVideoToLibrary(url:URL) {
  PHPhotoLibrary.shared().performChanges({
    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
  }, completionHandler: { (saved, error) in
    if saved {

    }
  })
}
