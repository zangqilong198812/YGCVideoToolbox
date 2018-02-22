//
//  ResizeViewController.swift
//  YGCVideoToolboxDemo
//
//  Created by Qilong Zang on 22/02/2018.
//  Copyright © 2018 Qilong Zang. All rights reserved.
//

import UIKit
import AVFoundation

class ResizeViewController: UIViewController {

  var result:(AVMutableComposition, AVMutableVideoComposition)!
  var player:AVPlayer!
  var item:AVPlayerItem!
  var playerLayer:AVPlayerLayer!

  var playButton = UIButton(type: .custom)

  override func viewDidLoad() {
    super.viewDidLoad()
    let path = Bundle.main.path(forResource: "timecount", ofType: "MP4")
    let videoAsset = AVURLAsset(url: URL(fileURLWithPath: path!))
    result = try! resizeVideo(videoAsset: videoAsset, targetSize: CGSize(width: 300, height: 300), isKeepAspectRatio: true, isCutBlackEdge: false)
    item = AVPlayerItem(asset: result.0)
    item.videoComposition = result.1
    player = AVPlayer(playerItem: item)
    playerLayer = AVPlayerLayer.init(player: player)
    playerLayer.frame = self.view.bounds
    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect;
    self.view.layer.addSublayer(playerLayer)

    playButton.setTitle("PlayVideo", for: .normal)
    playButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
    playButton.center = CGPoint(x: self.view.center.x, y: self.view.bounds.height - 60)
    playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
    self.view.addSubview(playButton)
    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  @objc func playVideo() {
    player.seek(to: kCMTimeZero)
    player.play()

    let tmp = NSTemporaryDirectory()

    print(tmp)
    exportVideo(outputPath: "\(tmp)test.mp4", asset: result.0, videoComposition: result.1) { (success) in
      if success {
        print("success")
      }else {
        print("error")
      }
    }
  }
}
