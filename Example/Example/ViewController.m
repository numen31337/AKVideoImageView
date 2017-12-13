//
//  ViewController.m
//  AKVideoImageView_Example
//
//  Created by Oleksandr Kirichenko on 10/16/15.
//  Copyright © 2015 Oleksandr Kirichenko. All rights reserved.
//

#import "ViewController.h"
#import "AKVideoImageView.h"

NSString *const kFirstVideoName = @"video_1";
NSString *const kSecondVideoName = @"video_2";

@interface ViewController()

@property (weak, nonatomic) AKVideoImageView *videoBG;
@property (weak, nonatomic) IBOutlet UILabel *usingCodeLabel;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:kFirstVideoName withExtension:@"mp4"];
    AKVideoImageView *videoBG = [[AKVideoImageView alloc] initWithFrame:self.view.bounds
                                                               videoURL:videoURL];
    [self.view addSubview:videoBG];
    [self.view sendSubviewToBack:videoBG];
    videoBG.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[self constraintWitItem:videoBG attribute:NSLayoutAttributeBottom]];
    [self.view addConstraint:[self constraintWitItem:videoBG attribute:NSLayoutAttributeLeft]];
    [self.view addConstraint:[self constraintWitItem:videoBG attribute:NSLayoutAttributeRight]];
	NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:videoBG
																	 attribute:NSLayoutAttributeTop
																	 relatedBy:NSLayoutRelationEqual
																		toItem:self.usingCodeLabel
																	 attribute:NSLayoutAttributeBottom
																	multiplier:1.0
																	  constant:8.0];
	[self.view addConstraint:topConstraint];
	
    self.videoBG = videoBG;
}

- (NSLayoutConstraint *)constraintWitItem:(UIView *)view attribute:(NSLayoutAttribute)attribute
{
    return [NSLayoutConstraint constraintWithItem:view
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                        attribute:attribute
                                       multiplier:1.0
                                         constant:0.0];
}

- (IBAction)switchButtonPressed:(UIButton *)sender
{
    static BOOL i = NO;
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:i ? kFirstVideoName : kSecondVideoName withExtension:@"mp4"];
    i = !i;
    
    self.videoBG.videoURL = videoURL;
}

@end
