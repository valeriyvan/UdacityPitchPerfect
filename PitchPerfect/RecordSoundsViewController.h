//
//  RecordSoundsViewController.h
//  PitchPerfect
//
//  Created by Valeriy Van on 8/19/15.
//  Copyright (c) 2015 Valeriy Van. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordSoundsViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic, weak) IBOutlet UILabel *recordingInProgress;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@end
