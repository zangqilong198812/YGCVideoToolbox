//
//  YGCAddImageForVideo.swift
//  YGCVideoToolboxDemo
//
//  Created by Qilong Zang on 24/02/2018.
//  Copyright © 2018 Qilong Zang. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

/*
 Notice:
 Add Image use the AVVideoCompositionCoreAnimationTool, so you can't use AVPlayer play the composition with a videoCompositon, you have to export then play it.
 */

public func addImageForVideo(videoAsset:AVURLAsset,
                             image:UIImage,
                             imageRect:CGRect) throws -> (AVMutableComposition, AVMutableVideoComposition) {
  guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else{
    throw YGCVideoError.videoTrackNotFind
  }

  guard let audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio).first else {
    throw YGCVideoError.audioTrackNotFind
  }

  let imageCompositin = AVMutableComposition(urlAssetInitializationOptions: nil)
  guard let compositionVideoTrack = imageCompositin.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    throw YGCVideoError.compositionTrackInitFailed
  }
  guard let compostiionAudioTrack = imageCompositin.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    throw YGCVideoError.compositionTrackInitFailed
  }

  try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: videoTrack, at: kCMTimeZero)
  try compostiionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: audioTrack , at: kCMTimeZero)

  let videoComposition = AVMutableVideoComposition()
  let mainInstruction = AVMutableVideoCompositionInstruction()
  mainInstruction.timeRange = CMTimeRange(start: kCMTimeZero, end: videoAsset.duration)
  let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
  layerInstruction.setTransform(videoTrack.preferredTransform, at: kCMTimeZero)
  mainInstruction.layerInstructions = [layerInstruction]

  let imageLayer = CALayer()
  imageLayer.contents = image.cgImage!
  imageLayer.frame = CGRect(x: 0, y: videoTrack.naturalSize.height - imageRect.maxY, width: imageRect.width, height: imageRect.height)

  let overlayLayer = CALayer()
  overlayLayer.frame = CGRect(origin: CGPoint.zero, size: videoTrack.naturalSize)
  overlayLayer.addSublayer(imageLayer)

  let parentLayer = CALayer()
  let videoLayer = CALayer()
  parentLayer.frame = CGRect(origin: CGPoint.zero, size: videoTrack.naturalSize)
  videoLayer.frame = CGRect(origin: CGPoint.zero, size: videoTrack.naturalSize)
  parentLayer.addSublayer(videoLayer)
  parentLayer.addSublayer(overlayLayer)

  videoComposition.renderSize = videoTrack.naturalSize
  videoComposition.frameDuration = CMTimeMake(1, 30)
  videoComposition.instructions = [mainInstruction]
  videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)

  return (imageCompositin, videoComposition)
}
