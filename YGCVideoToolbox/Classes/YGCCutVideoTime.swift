//
//  YGCCutVideoTime.swift
//  ZQLVideoCompressor
//
//  Created by zang qilong on 2018/2/4.
//  Copyright © 2018年 Qilong Zang. All rights reserved.
//

import Foundation
import AVFoundation

public func cutTime(videoAsset:AVURLAsset,
                    cutTimeRange:YGCTimeRange) throws -> AVMutableComposition
{
  guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else{
    throw YGCVideoError.videoTrackNotFind
  }
  
  guard let audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio).first else {
    throw YGCVideoError.audioTrackNotFind
  }
  
  guard cutTimeRange.validateTime(videoTime: videoAsset.duration) else {
    throw YGCVideoError.timeSetNotCorrect
  }
  
  let cutCompositin = AVMutableComposition(urlAssetInitializationOptions: nil)
  guard let compositionVideoTrack = cutCompositin.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    throw YGCVideoError.compositionTrackInitFailed
  }
  guard let compostiionAudioTrack = cutCompositin.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    throw YGCVideoError.compositionTrackInitFailed
  }
  
  let videoTimeScale = videoAsset.duration.timescale
  let beginTime:CMTime
  let timeRange:CMTimeRange
  switch cutTimeRange {
  case .naturalRange:
    timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
    beginTime = kCMTimeZero
  case .secondsRange(let begin, let end):
    beginTime = CMTimeMakeWithSeconds(begin, videoTimeScale)
    timeRange = CMTimeRangeMake(beginTime, CMTimeMakeWithSeconds(end, videoTimeScale))
  case .cmtimeRange(let begin, let end):
    beginTime = begin
    timeRange = CMTimeRangeMake(begin, end)
  }
  
  try compositionVideoTrack.insertTimeRange(timeRange, of: videoTrack, at: kCMTimeZero)
  try compostiionAudioTrack.insertTimeRange(timeRange, of: audioTrack , at: kCMTimeZero)
  
  compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
  
  let subtractTime = CMTimeSubtract(timeRange.duration, timeRange.start)
  cutCompositin.removeTimeRange(CMTimeRangeMake(subtractTime, cutCompositin.duration))
  
  return cutCompositin
}
