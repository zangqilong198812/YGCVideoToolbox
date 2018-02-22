//
//  SlowMotionViewController.swift
//  YGCVideoToolboxDemo
//
//  Created by Qilong Zang on 22/02/2018.
//  Copyright © 2018 Qilong Zang. All rights reserved.
//

import UIKit
import AVFoundation

class SlowMotionViewController: UIViewController {

  var composition:AVMutableComposition!
  var player:AVPlayer!
  var item:AVPlayerItem!
  var playerLayer:AVPlayerLayer!

 var playButton = UIButton(type: .custom)

  override func viewDidLoad() {
    super.viewDidLoad()
    let path = Bundle.main.path(forResource: "timecount", ofType: "MP4")
    let videoAsset = AVURLAsset(url: URL(fileURLWithPath: path!))
    composition = try! slowMotion(videoAsset: videoAsset, slowTimeRange: YGCTimeRange.secondsRange(2, 4), slowMotionRate: 8)
    print("video range is \(CMTimeGetSeconds(composition.duration))")
    item = AVPlayerItem(asset: composition)
    player = AVPlayer(playerItem: item)
    playerLayer = AVPlayerLayer.init(player: player)
    playerLayer.frame = self.view.bounds
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
  }

}
