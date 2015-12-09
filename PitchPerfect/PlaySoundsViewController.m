//
//  PlaySoundsViewController.m
//  PitchPerfect
//
//  Created by Valeriy Van on 8/19/15.
//  Copyright (c) 2015 Valeriy Van. All rights reserved.
//

#import "PlaySoundsViewController.h"
#import "RecordedAudio.h"
#import <AVFoundation/AVFoundation.h>

@interface PlaySoundsViewController () <AVAudioPlayerDelegate>
@property (nonatomic, weak) IBOutlet UIButton *chipmunkButton;
@property (nonatomic, weak) IBOutlet UIButton *darthvaderButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, readonly) AVAudioPlayer *player;
@property (nonatomic, readonly) AVAudioFile *audioFile;
@property (nonatomic, strong) AVAudioPlayerNode *audioPlayerNode;
@property (nonatomic, readonly) AVAudioEngine *audioEngine;
@end

@implementation PlaySoundsViewController
@synthesize player, audioFile, audioEngine;

- (AVAudioPlayer*)player {
    if (!player) {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordedAudio.fileURL error:nil];
    }
    return player;
}

- (AVAudioFile*)audioFile {
    if (!audioFile) {
        audioFile = [[AVAudioFile alloc] initForReading:self.recordedAudio.fileURL error:nil];
    }
    return audioFile;
}

- (AVAudioEngine*)audioEngine {
    if (!audioEngine) {
        audioEngine = [[AVAudioEngine alloc] init];
    }
    return audioEngine;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!NSClassFromString(@"AVAudioEngine")) {
        // AVAudioEngine is available starting iOS 8.
        // Make buttons unavailable if AVAudioEngine is unavailable.
        self.chipmunkButton.enabled = NO;
        self.darthvaderButton.enabled = NO;
    }
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
}

// Helper
- (void)stopPlayer {
    [self.player stop];
    [self.audioEngine stop];
    [self.audioEngine reset];
}

// Helper
- (void)playWithRate:(float)rate {
    self.player.enableRate = YES;
    self.player.rate = rate;
    self.player.currentTime = 0.0;
    self.player.delegate = self;
    [self.player play];
    self.stopButton.enabled = YES;
}

- (IBAction)playSlow:(UIButton*)sender {
    [self stopPlayer];
    [self playWithRate:0.5];
}

- (IBAction)playFast:(UIButton*)sender {
    [self stopPlayer];
    [self playWithRate:2.0];
}

- (void)playAudioWithPith:(float)pitch {
    [self.player stop];
    self.stopButton.enabled = YES;
    [self.audioEngine stop];
    [self.audioEngine reset];
    // Forward audio output to speaker
    /*
    var inputDeviceID: UInt32 = 53 // TODO: get this using AudioObjectGetPropertyData
    let audioUnit: AudioUnit = audioEngine.inputNode.audioUnit
    let error: OSStatus  = AudioUnitSetProperty(audioUnit, AudioUnitPropertyID(kAudioOutputUnitProperty_CurrentDevice), AudioUnitScope(kAudioUnitScope_Global), AudioUnitElement(0), &inputDeviceID, UInt32(sizeof(inputDeviceID.dynamicType)))
    */
    self.audioPlayerNode = [[AVAudioPlayerNode alloc] init];
    [audioEngine attachNode:self.audioPlayerNode];

    AVAudioUnitTimePitch *changePitchEffect = [[AVAudioUnitTimePitch alloc] init];
    changePitchEffect.pitch = pitch;
    [self.audioEngine attachNode:changePitchEffect];
    [self.audioEngine connect: self.audioPlayerNode to: changePitchEffect format: nil];
    [self.audioEngine connect:changePitchEffect to: self.audioEngine.outputNode format: nil];

    [self.audioPlayerNode scheduleFile:self.audioFile atTime: nil completionHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.stopButton.enabled = NO;
        });
    }];
    [self.audioEngine startAndReturnError:nil];
    [self.audioPlayerNode play];
}

- (IBAction)playChipmunk:(UIButton*)sender {
    [self stopPlayer];
    [self playAudioWithPith:1000.0];
}

- (IBAction)playDarthvader:(UIButton*)sender {
    [self stopPlayer];
    [self playAudioWithPith:-1000.0];
}

- (IBAction)stop:(UIButton*)sender {
    [self.player stop];
    [self.audioPlayerNode stop];
    self.stopButton.enabled = NO;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag
{
    self.stopButton.enabled = NO;
}

@end
