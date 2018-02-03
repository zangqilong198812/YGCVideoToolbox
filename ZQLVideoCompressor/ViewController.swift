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
    
    var composition:AVMutableComposition!
    var player:AVPlayer!
    var item:AVPlayerItem!
    var playerLayer:AVPlayerLayer!

    @IBOutlet weak var playButton: UIButton!
    override func viewDidLoad() {
    super.viewDidLoad()
    let path = Bundle.main.path(forResource: "self", ofType: "MP4")
    let videoAsset = AVURLAsset(url: URL(fileURLWithPath: path!))
    composition = try! cutTime(videoAsset: videoAsset, cutTimeRange: YGCTimeRange.secondsRange(4, 5))
    
    item = AVPlayerItem(asset: composition)
    player = AVPlayer(playerItem: item)
    playerLayer = AVPlayerLayer.init(player: player)
    playerLayer.frame = self.view.bounds
    self.view.layer.addSublayer(playerLayer)
    self.view.bringSubview(toFront: playButton)
  }
    
    @IBAction func playVideo() {
        player.play()
    }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

