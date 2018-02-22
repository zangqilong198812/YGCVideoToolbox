//
//  YGCRepeatSegment.swift
//  ZQLVideoCompressor
//
//  Created by Qilong Zang on 23/01/2018.
//  Copyright © 2018 Qilong Zang. All rights reserved.
//

import UIKit
import AVFoundation

public func repeatVideo(videoAsset:AVURLAsset, insertAtSeconds:Double, repeatTimeRange:YGCTimeRange, repeatCount:Int) throws -> AVMutableComposition {
  
  assert(insertAtSeconds >= 0, "insert seconds can't less than 0")
  
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
  var insert:CMTime = CMTimeMakeWithSeconds(insertAtSeconds, videoTimeScale);
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
  
  repeatDuration = CMTimeSubtract(repeatRange.duration, repeatRange.start)
  
  // insertAt bigger than kcmtimezero,we should add left side time range first
  if CMTimeCompare(insert, kCMTimeZero) == 1 {
    // add repeatRange Left side
    try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, insert), of: videoTrack, at: kCMTimeZero)
    try compostiionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, insert), of: audioTrack, at: kCMTimeZero)
    
    // add repeat range
    for _ in 0..<repeatCount {
      try compositionVideoTrack.insertTimeRange(repeatRange, of: videoTrack, at: insert)
      try compostiionAudioTrack.insertTimeRange(repeatRange, of: audioTrack, at: insert)
      insert = CMTimeAdd(insert, repeatDuration)
    }
    
    // add repeatRange right side
    if CMTimeCompare(repeatRange.end, videoAsset.duration) == -1 {
      try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(repeatRange.end, videoAsset.duration), of: videoTrack, at: insert)
      try compostiionAudioTrack.insertTimeRange(CMTimeRangeMake(repeatRange.end, videoAsset.duration), of: audioTrack, at: insert)
    }
  }else {
    // insertAt equal kcmtimezero,we should add repeat range directly
    for _ in 0..<repeatCount {
      try compositionVideoTrack.insertTimeRange(repeatRange, of: videoTrack, at: insert)
      insert = CMTimeAdd(insert, repeatDuration)
    }
    
    if CMTimeCompare(repeatRange.end, videoAsset.duration) == -1 {
      try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(repeatRange.end, videoAsset.duration), of: videoTrack, at: insert)
      try compostiionAudioTrack.insertTimeRange(CMTimeRangeMake(repeatRange.end, videoAsset.duration), of: audioTrack, at: insert)
    }
    
  }
  
  compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
  return mixCompositin
}

