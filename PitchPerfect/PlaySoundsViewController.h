//
//  PlaySoundsViewController.h
//  PitchPerfect
//
//  Created by Valeriy Van on 8/19/15.
//  Copyright (c) 2015 Valeriy Van. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecordedAudio;

@interface PlaySoundsViewController : UIViewController
@property (nonatomic, strong) RecordedAudio *recordedAudio;
@end
