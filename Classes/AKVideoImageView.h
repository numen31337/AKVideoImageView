//
//  AKVideoImageView.h
//
//  Created by Oleksandr Kirichenko on 4/23/15.
//  Copyright (c) 2015 Oleksandr Kirichenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AKVideoImageView : UIImageView

/** Assign this property with a new video NSURL to dynamically switch the playing video */
@property (strong, nonatomic, nonnull) NSURL *videoURL;

/**
 * Designated Initializer
 *
 * @param frame The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it.
 * @param videoURL The NSURL of the video object to present
 * @code
 * NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"videoFileName" withExtension:@"mp4"];
 * AKVideoImageView *videoBG = [[AKVideoImageView alloc] initWithFrame:self.view.bounds videoURL:videoURL];
 * @endcode
 * @return An initialized view object.
 */
- (nullable instancetype)initWithFrame:(CGRect)frame
                              videoURL:(nonnull NSURL *)videoURL NS_DESIGNATED_INITIALIZER;

/** Returns the first frame of the video as a UIImage */
+ (nullable UIImage *)firstFrameImageForVideo:(nonnull NSURL *)videoURL;

@end
