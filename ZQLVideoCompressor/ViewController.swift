//
//  ViewController.swift
//  ZQLVideoCompressor
//
//  Created by Qilong Zang on 17/01/2018.
//  Copyright © 2018 Qilong Zang. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let path = Bundle.main.path(forResource: "cat", ofType: "MOV")
    let tmp = NSTemporaryDirectory()
    let tempFile = tmp + "testvideo.mov"
    let videoAsset = AVURLAsset(url: URL(fileURLWithPath: path!))
    try! slowMotion(videoAsset: videoAsset, slowTimeRange: YGCTimeRange.secondsRange(2, 4), slowMotionRate: 10, outputPath: tempFile)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

