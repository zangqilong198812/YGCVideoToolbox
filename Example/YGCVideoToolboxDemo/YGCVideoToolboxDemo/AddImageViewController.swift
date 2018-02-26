//
//  AddImageViewController.swift
//  YGCVideoToolboxDemo
//
//  Created by Qilong Zang on 24/02/2018.
//  Copyright © 2018 Qilong Zang. All rights reserved.
//

import UIKit
import AVFoundation

class AddImageViewController: UIViewController {

  var result:(AVMutableComposition, AVMutableVideoComposition)!
  var player:AVPlayer!
  var item:AVPlayerItem?
  var playerLayer:AVPlayerLayer!
  let progressView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

  var playButton = UIButton(type: .custom)

  override func viewDidLoad() {
    super.viewDidLoad()
    let path = Bundle.main.path(forResource: "test", ofType: "MOV")
    let videoAsset = AVURLAsset(url: URL(fileURLWithPath: path!))
    result = try! addImageForVideo(videoAsset: videoAsset, image: UIImage(named: "tiger.jpeg")!, imageRect: CGRect(x: 100, y: 100, width: 200, height: 200))

    playButton.setTitle("PlayVideo", for: .normal)
    playButton.setTitleColor(UIColor.blue, for: .normal)
    playButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
    playButton.center = CGPoint(x: self.view.center.x, y: self.view.bounds.height - 60)
    playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
    self.view.addSubview(playButton)
    // Do any additional setup after loading the view.

    progressView.center = self.view.center
    self.view.addSubview(progressView)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func initilizePlayer(url:URL) {
    item = AVPlayerItem(url: url)
    player = AVPlayer(playerItem: item)
    playerLayer = AVPlayerLayer.init(player: player)
    playerLayer.frame = CGRect(x: 0, y: 64, width: self.view.bounds.width, height: self.view.bounds.height - 128)
    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect;
    self.view.layer.addSublayer(playerLayer)

    self.view.bringSubview(toFront: playButton)
  }

  @objc func playVideo() {
    if let _ = self.item {
      player.seek(to: kCMTimeZero)
      player.play()
      return
    }

    progressView.startAnimating()
    let tmp = NSTemporaryDirectory()
    let filePath = "\(tmp)test.mov"
    exportVideo(outputPath: filePath, asset: result.0, videoComposition: nil, fileType: AVFileType.mov) { (success) in
      DispatchQueue.main.async {
        self.progressView.stopAnimating()
        if success {
          print("success")
          self.initilizePlayer(url: URL(fileURLWithPath: filePath))
        }else {
          print("error")
        }
      }
    }
  }

}
