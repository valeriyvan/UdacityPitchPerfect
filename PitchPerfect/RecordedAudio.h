//
//  RecordedAudio.h
//  PitchPerfect
//
//  Created by Valeriy Van on 8/19/15.
//  Copyright (c) 2015 Valeriy Van. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordedAudio : NSObject
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) NSString *title;
@end
