//
//  YGCResizeVideo.swift
//  ZQLVideoCompressor
//
//  Created by zang qilong on 2018/1/20.
//  Copyright © 2018年 Qilong Zang. All rights reserved.
//

import UIKit
import AVFoundation

public func resideVideo(videoAsset:AVURLAsset,
                        targetSize:CGSize,
                        timeRange:YGCTimeRange = .naturalRange,
                        isKeepAspectRatio:Bool,
                        isCutBlackEdge:Bool,
                        outputPath:String) throws
{
    guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else{
        throw YGCVideoError.videoTrackNotFind
    }
    
    guard timeRange.validateTime(videoTime: videoAsset.duration) else {
        throw YGCVideoError.timeSetNotCorrect
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
    if (info.isPortrait && info.orientation != .up) {
        videoNaturaSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
    }else {
        videoNaturaSize = videoTrack.naturalSize
    }
    if videoNaturaSize.width < targetSize.width && videoNaturaSize.height < targetSize.height {
        throw YGCVideoError.targetSizeNotCorrect
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
        if isCutBlackEdge {
            finalTransform = originTransform.concatenating(CGAffineTransform(scaleX: fitRect.width/videoNaturaSize.width, y: fitRect.height/videoNaturaSize.height))
        }else {
            finalTransform = originTransform.concatenating(CGAffineTransform(scaleX: fitRect.width/videoNaturaSize.width, y: fitRect.height/videoNaturaSize.height)).concatenating(CGAffineTransform(translationX: fitRect.minX, y: fitRect.minY))
        }
        
    }else {
        if isCutBlackEdge {
            finalTransform = originTransform.concatenating(CGAffineTransform(scaleX: fitRect.width/videoNaturaSize.width, y: fitRect.height/videoNaturaSize.height))
        }else {
            finalTransform = originTransform.concatenating(CGAffineTransform(scaleX: fitRect.width/videoNaturaSize.width, y: fitRect.height/videoNaturaSize.height)).concatenating(CGAffineTransform(translationX: fitRect.minX, y: fitRect.minY))
        }
        
    }
    layerInstruction.setTransform(finalTransform, at: beginTime)
    mainInstruction.layerInstructions = [layerInstruction]
    
    let videoComposition = AVMutableVideoComposition()
    videoComposition.frameDuration = CMTimeMake(1, 30)
    if isCutBlackEdge && isKeepAspectRatio {
        videoComposition.renderSize = fitRect.size
    }else {
        videoComposition.renderSize = targetSize
    }
    
    videoComposition.instructions = [mainInstruction]
    
    
    if FileManager.default.fileExists(atPath: outputPath) {
        try FileManager.default.removeItem(atPath: outputPath)
    }
    let outputURL = URL(fileURLWithPath: outputPath)
    guard let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality) else{
        print("generate export failed")
        return
    }
    exporter.outputURL = outputURL
    exporter.outputFileType = AVFileType.mp4
    exporter.shouldOptimizeForNetworkUse = false
    exporter.videoComposition = videoComposition
    exporter.exportAsynchronously(completionHandler: {
        if exporter.status == .completed {
            
        }else {
            
        }
    })
    
}
