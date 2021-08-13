# AKVideoImageView
[![Build Test](https://github.com/numen31337/AKVideoImageView/actions/workflows/ci.yaml/badge.svg)](https://github.com/numen31337/AKVideoImageView/actions/workflows/ci.yaml)
![Platform](https://img.shields.io/cocoapods/p/AKVideoImageView.svg)
![CocoaPods](https://img.shields.io/cocoapods/l/AKVideoImageView.svg)

## Motivation

AKVideoImageView was created because I wasn't satisfied with the standard AVPlayer when I was implementing a video background for one of my apps. The main issue is that AVPlayer doesn't let the phone go to sleep mode. Additionally, you can't insensibly start the video from the first frame when the app enters the background. This class solves these problems and has a less noticeable lag when switching from the last to the first frame of the video.

![AKVideoImageView Example](Resources/example.gif)

## Features

- Allows the phone to go to the sleep mode
- Ability to dynamically switch videos
- Automatically switches to the first frame of video to have a seamless transition when the app returns from the background
- Minimal memory footprint
- Good performance
- Ability to use mp4 files as the video source
- Interface Builder support

## Usage

### Compressing your video file
Before starting using this class, you need to properly compress the video.<br /> Here is an example of libx264 compression options on OS X system using FFmpeg utility:
```
ffmpeg -i input.mov -vcodec libx264 -level 3.1 -pix_fmt yuv420p -threads 1 -preset placebo -crf 19 -tune film -x264opts colorprim=bt709:transfer=bt709:colormatrix=bt709:fullrange=off output.mp4
```

### Using Interface Builder
Just drag the `UIImageView` to your `UIView` and set its class to the `AKVideoImageView`. In the Attributes Inspector set the `Video File Name` to the name of your `.mp4` video file without extension. See an example project for more info if needed.

### Using Code

Objective-C:<br />
```objective-c
#import "AKVideoImageView.h"

NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"videoName" withExtension:@"mp4"];
AKVideoImageView *videoBG = [[AKVideoImageView alloc] initWithFrame:self.view.bounds
                                                           videoURL:videoURL];
[self.view addSubview:videoBG];
[self.view sendSubviewToBack:videoBG];
```

Swift:<br />
```swift
import AKVideoImageView

let url = Bundle.main.url(forResource: "video_1", withExtension: "mp4")!
let videoView = AKVideoImageView(frame: view.bounds, videoURL: url)!
view.addSubview(videoView)
```

### Dynamically changing video

```objective-c
NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"anotherVideoName" withExtension:@"mp4"];
self.videoBG.videoURL = videoURL;
```

## Installation

#### Manually
Just add AKVideoImageView.h and AKVideoImageView.m files to your project.

#### CocoaPods
Add the following line to your Podfile.

```
pod "AKVideoImageView", "~> 1.1"
```

Then run `pod install`.

## License (MIT)

Copyright (c) 2017 Oleksandr Kirichenko

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
