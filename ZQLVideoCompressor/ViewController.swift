//
//  ViewController.swift
//  ZQLVideoCompressor
//
//  Created by Qilong Zang on 17/01/2018.
//  Copyright © 2018 Qilong Zang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  var compressor:ZQLVideoCompressor!

  override func viewDidLoad() {
    super.viewDidLoad()
    let path = Bundle.main.path(forResource: "talk", ofType: "MP4")
    let tmp = NSTemporaryDirectory()
    let tempFile = tmp + "testvideo.mov"
    compressor = try! ZQLVideoCompressor(filePath: path!)
    try! compressor.compressVideo(targetSize: CGSize(width: 500, height: 500), outputPath: tempFile)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

