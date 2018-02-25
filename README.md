<div align = "center">
<img src="https://ws1.sinaimg.cn/large/006tNc79gy1fnpmgl15rnj30jg05k0u2.jpg" width="700" />
</div>

<p align="center">
<img src="https://img.shields.io/badge/Swift-4.0-orange.svg" alt="Swift 4.0"/>
<img src="https://img.shields.io/badge/platform-iOS-brightgreen.svg" alt="Platform: iOS"/>
<img src="https://img.shields.io/badge/Xcode-9%2B-brightgreen.svg" alt="XCode 9+"/>
<img src="https://img.shields.io/badge/iOS-11%2B-brightgreen.svg" alt="iOS 11"/>
<img src="https://img.shields.io/badge/licence-MIT-lightgray.svg" alt="Licence MIT"/>
</a>
</p>

# YGCVideoToolbox

A series of video tools base on AVFoundation framework.



### Features
- [x] Resize video
- [x] Crop video by timerange
- [x] Slow motion video
- [x] Repeat a video segment
- [x] Add image on video
- [x] Add text on video
- [x] Pure Swift 4.

### Todo
- [ ] Add CoreImage filter to a video file
- [ ] Add gif on video
- [ ] Reverse a video

## Usage
This is the original video.  
![](https://ws4.sinaimg.cn/large/006tNc79ly1foq37le2hog30b70juhdw.gif)
### Slowmotion

```
 let videoAsset = AVURLAsset(url: URL(fileURLWithPath: path!))
    composition = try! slowMotion(videoAsset: videoAsset, slowTimeRange: YGCTimeRange.secondsRange(2, 4), slowMotionRate: 8)
```

it means I want to slow motion the 2s - 4s, and I want to make it slow to 1/8 speed.
This is the slowmotion video.
![](https://ws3.sinaimg.cn/large/006tNc79ly1foq38erllrg30d60oyqv6.gif)

### Repeat 

```
let videoAsset = AVURLAsset(url: URL(fileURLWithPath: path!))
    composition = try! repeatVideo(videoAsset: videoAsset, insertAtSeconds: 2, repeatTimeRange: YGCTimeRange.secondsRange(2, 4), repeatCount: 2)
```

the demo code means i will repeat the 2s - 4s video segment, and I want to repeat twice.  
This is the repeat video.
![](https://ws4.sinaimg.cn/large/006tNc79ly1foq38x0kmyg30d60oyx6r.gif)

### Resize


```
let videoAsset = AVURLAsset(url: URL(fileURLWithPath: path!))
    result = try! resizeVideo(videoAsset: videoAsset, targetSize: CGSize(width: 300, height: 300), isKeepAspectRatio: true, isCutBlackEdge: false)
```

the demo code means I want to resize the video size to (300, 300). and I want to the video scale AspectFit. and Want to the black edge.

### Cut Video

```
let videoAsset = AVURLAsset(url: URL(fileURLWithPath: path!))
    composition = try! cutTime(videoAsset: videoAsset, cutTimeRange: YGCTimeRange.secondsRange(2, 4))
```

the demo code means I want the 2s - 4s time range video. And crop it to me .
## Installing

#### Cocoapods
pod 'YGCVideoToolbox'

## Requirements

* Swift 4
* iOS 11 or higher

## Authors

* **zang qilong** -  [zangqilong](https://github.com/zangqilong198812)

## Communication

* If you **found a bug**, open an issue.
* If you **have a feature request**, open an issue.
* If you **want to contribute**, submit a pull request.

## License

This project is licensed under the MIT License.

