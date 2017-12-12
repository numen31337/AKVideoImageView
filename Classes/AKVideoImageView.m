//
//  AKVideoImageView.m
//
//  Created by Oleksandr Kirichenko on 4/23/15.
//  Copyright (c) 2015 Oleksandr Kirichenko. All rights reserved.
//

#import "AKVideoImageView.h"
@import AVFoundation;

IB_DESIGNABLE
@interface AKVideoImageView()

@property (strong) AVAssetReader *reader;
@property (strong) AVAssetReaderTrackOutput *readerVideoTrackOutput;

@property (assign) CMTime previousFrameTime;
@property (assign) CFAbsoluteTime previousActualFrameTime;

@property (assign) BOOL stopAnimation;
@property (assign) BOOL newVideoAvalilible;

///The property used for storyboard support only
@property (retain, nonatomic) IBInspectable NSString *videoFileName;

@end


@implementation AKVideoImageView

- (void)prepareForInterfaceBuilder
{
	[super prepareForInterfaceBuilder];
	
	if (self.videoURL) { [self showFirstFrame]; }
}

- (nullable instancetype)initWithFrame:(CGRect)frame videoURL:(nonnull NSURL *)videoURL
{
    NSCParameterAssert([videoURL isKindOfClass:[NSURL class]]);
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playVideo)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(terminateAnimation)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        self.contentMode = UIViewContentModeScaleAspectFill;
        
        _videoURL = videoURL; //don't use setter here to avoid newVideoAvalilible flag for the initial run
        
        [self showFirstFrame];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	
	if (self.videoURL) { [self playVideo]; }
}

///The property used for storyboard support only
- (void)setVideoFileName:(NSString *)videoFileName
{
	if (videoFileName == _videoFileName) { return; }
	
	_videoFileName = videoFileName;
	NSURL *videoFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:videoFileName withExtension:@"mp4"];
	self.videoURL = videoFileURL;
	
#if !TARGET_INTERFACE_BUILDER
	[self playVideo];
#endif
}

- (void)setVideoURL:(nonnull NSURL *)videoURL
{
    NSCParameterAssert([videoURL isKindOfClass:[NSURL class]]);
    if (videoURL == _videoURL) { return; }
    
    _videoURL = videoURL;
    self.newVideoAvalilible = YES;
}

- (AVAssetReader *)createAssetReader
{
    NSCParameterAssert([self.videoURL isKindOfClass:[NSURL class]]);

    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                             forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:self.videoURL options:inputOptions];
    
    NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
    [outputSettings setObject:@(kCVPixelFormatType_32BGRA)
                       forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    AVAssetTrack *videoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    self.readerVideoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:outputSettings];
    self.readerVideoTrackOutput.alwaysCopiesSampleData = NO;
    
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:videoAsset error:nil];
    [assetReader addOutput:self.readerVideoTrackOutput];
    
    return assetReader;
}

- (void)playVideo
{
    @synchronized(self) {
        NSCParameterAssert([self.videoURL isKindOfClass:[NSURL class]]);
        
        self.stopAnimation = NO;
        
        if (!self.reader) {
            self.reader = [self createAssetReader];
            [self.reader startReading];
            
            self.previousFrameTime = kCMTimeZero;
            self.previousActualFrameTime = CFAbsoluteTimeGetCurrent();
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self processFramesFromReader:self.reader];
            });
        }
    }
}

- (void)terminateAnimation
{
    self.stopAnimation = YES;
    [self showFirstFrame];
}

- (void)processFramesFromReader:(AVAssetReader *)reader
{
    NSCParameterAssert([reader isKindOfClass:[AVAssetReader class]]);
    
    do {
        CMSampleBufferRef sampleBufferRef = [self.readerVideoTrackOutput copyNextSampleBuffer];
        if (!sampleBufferRef) continue;
        
        // Do this outside of the video processing queue to not slow that down while waiting
        CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBufferRef);
        
        CMTime differenceFromLastFrame = CMTimeSubtract(currentSampleTime, self.previousFrameTime);
        CFAbsoluteTime currentActualTime = CFAbsoluteTimeGetCurrent();
        
        CGFloat frameTimeDifference = CMTimeGetSeconds(differenceFromLastFrame);
        CGFloat actualTimeDifference = currentActualTime - self.previousActualFrameTime;
        
        CGImageRef quartzImage = [self imageFromSampleBuffer:sampleBufferRef];
        id layerImage = (__bridge_transfer id)(quartzImage);
        
        CMSampleBufferInvalidate(sampleBufferRef);
        CFRelease(sampleBufferRef);
        
        if (frameTimeDifference > actualTimeDifference) {
            usleep(1000000.0 * (frameTimeDifference - actualTimeDifference));
        }
        
        self.previousFrameTime = currentSampleTime;
        self.previousActualFrameTime = CFAbsoluteTimeGetCurrent();
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (!self.stopAnimation) { self.layer.contents = layerImage; }
        });
    } while (reader.status == AVAssetReaderStatusReading && !self.stopAnimation && !self.newVideoAvalilible);
    
    [self.reader cancelReading];
    self.reader = nil;
    self.newVideoAvalilible = NO;
    
    if (self.stopAnimation) {
        self.readerVideoTrackOutput = nil;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playVideo];
        });
    }
}

//This method implementation is taken from Apple response here: https://developer.apple.com/library/ios/qa/qa1702/_index.html
- (CGImageRef)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return (quartzImage);
}

- (void)showFirstFrame
{
    NSCParameterAssert([self.videoURL isKindOfClass:[NSURL class]]);
    
    UIImage *firstFrameUIImage = [self thumbnailImageForVideo:self.videoURL atTime:0];
    self.image = firstFrameUIImage;
}

- (nullable UIImage *)thumbnailImageForVideo:(nonnull NSURL *)videoURL
                                      atTime:(NSTimeInterval)time
{
    NSCParameterAssert([videoURL isKindOfClass:[NSURL class]]);
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert([asset isKindOfClass:[AVURLAsset class]]);
    
    AVAssetImageGenerator *assetIG = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetIG.appliesPreferredTrackTransform = YES;
    assetIG.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *igError = nil;
    thumbnailImageRef = [assetIG copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)
                                        actualTime:NULL
                                             error:&igError];
    
    if (!thumbnailImageRef) { NSLog(@"Thumbnail image generation error %@", igError ); }
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    CGImageRelease(thumbnailImageRef);
    
    return thumbnailImage;
}

@end
