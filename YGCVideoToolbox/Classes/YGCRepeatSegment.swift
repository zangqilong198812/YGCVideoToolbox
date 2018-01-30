//
//  YGCRepeatSegment.swift
//  ZQLVideoCompressor
//
//  Created by Qilong Zang on 23/01/2018.
//  Copyright © 2018 Qilong Zang. All rights reserved.
//

import UIKit

import UIKit
import AVFoundation

public func repeatVideo(videoAsset:AVURLAsset, beginRepeatTime:Double, repeatTimeRange:YGCTimeRange, repeatCount:Int, outputPath:String) throws {
  guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else{
    throw YGCVideoError.videoTrackNotFind
  }

  guard let audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio).first else {
    throw YGCVideoError.audioTrackNotFind
  }

  guard repeatTimeRange.validateTime(videoTime: videoAsset.duration) else {
    throw YGCVideoError.timeSetNotCorrect
  }

  let mixCompositin = AVMutableComposition(urlAssetInitializationOptions: nil)
  guard let compositionVideoTrack = mixCompositin.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    throw YGCVideoError.compositionTrackInitFailed
  }
  guard let compostiionAudioTrack = mixCompositin.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    throw YGCVideoError.compositionTrackInitFailed
  }

  let videoTimeScale = videoAsset.duration.timescale
  var insert:CMTime = CMTimeMakeWithSeconds(beginRepeatTime, videoTimeScale);
  let repeatRange:CMTimeRange
  let repeatDuration:CMTime
  switch repeatTimeRange {
  case .naturalRange:
    repeatRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
  //  beginTime = kCMTimeZero
  case .secondsRange(let begin, let end):
   // beginTime = CMTimeMake(Int64(Double(videoTimeScale) * begin), videoTimeScale)
    repeatRange = CMTimeRangeMake(CMTimeMakeWithSeconds(begin, videoTimeScale), CMTimeMakeWithSeconds(end, videoTimeScale))
  case .cmtimeRange(let begin, let end):
   // beginTime = begin
    repeatRange = CMTimeRangeMake(begin, end)
  }

  repeatDuration = CMTimeSubtract(repeatRange.start, repeatRange.end)

  // add first Segment

  if CMTimeCompare(repeatRange.start, kCMTimeZero) == 1{
    try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, repeatRange.start), of: videoTrack, at: kCMTimeZero)
    for _ in 0..<repeatCount {
      try compositionVideoTrack.insertTimeRange(repeatRange, of: videoTrack, at: insert)
      insert = CMTimeAdd(insert, repeatDuration)
    }
    try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, repeatRange.start), of: videoTrack, at: kCMTimeZero)
  }else {

  }

  
  try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: videoTrack, at: kCMTimeZero)
  try compostiionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: audioTrack , at: kCMTimeZero)

  compositionVideoTrack.preferredTransform = videoTrack.preferredTransform

  if FileManager.default.fileExists(atPath: outputPath) {
    try FileManager.default.removeItem(atPath: outputPath)
  }
  print(outputPath)
  let outputURL = URL(fileURLWithPath: outputPath)
  guard let exporter = AVAssetExportSession(asset: mixCompositin, presetName: AVAssetExportPresetHighestQuality) else{
    print("generate export failed")
    return
  }
  exporter.outputURL = outputURL
  exporter.outputFileType = AVFileType.mp4
  exporter.shouldOptimizeForNetworkUse = false
  exporter.exportAsynchronously(completionHandler: {
    if exporter.status == .completed {

    }else {

    }
  })
}
