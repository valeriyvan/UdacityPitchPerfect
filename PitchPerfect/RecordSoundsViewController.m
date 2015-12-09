//
//  RecordSoundsViewController.m
//  PitchPerfect
//
//  Created by Valeriy Van on 8/19/15.
//  Copyright (c) 2015 Valeriy Van. All rights reserved.
//

#import "RecordSoundsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "RecordedAudio.h"
#import "PlaySoundsViewController.h"

@interface RecordSoundsViewController () <AVAudioRecorderDelegate>
@property (nonatomic, strong) AVAudioSession *recordingSession;
@property (nonatomic, readonly) AVAudioRecorder *recorder;
@property (nonatomic, readonly) NSURL *fileURL;
@end

@implementation RecordSoundsViewController
@synthesize fileURL, recorder;

- (NSURL*)fileURL {
    if (!fileURL) {
        fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/Documents/audio.aif", NSHomeDirectory()]];
    }
    return fileURL;
}

- (AVAudioRecorder*)recorder {
    if (!recorder) {
        NSDictionary *settings =
        @{ AVFormatIDKey: @(kAudioFormatAppleIMA4),
           AVSampleRateKey: @16400.0,
           AVNumberOfChannelsKey: @2 };
        recorder = [[AVAudioRecorder alloc] initWithURL:[self fileURL] settings:settings error:nil];
    }
    return recorder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.recordButton.enabled = YES;
    self.stopButton.hidden = YES;
}

- (IBAction)recordAudio:(UIButton*)button {
    self.recordingSession = [AVAudioSession sharedInstance];
    BOOL ret1 = [self.recordingSession setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    BOOL ret2 = [self.recordingSession setActive:YES error:nil];
    if (ret1 && ret2) {
        __weak RecordSoundsViewController *weakSelf = self;
        [self.recordingSession requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [weakSelf.recorder record];
                    weakSelf.recordButton.enabled = NO;
                    weakSelf.recordingInProgress.hidden = NO;
                    weakSelf.stopButton.hidden = NO;
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"there is no permission to access microphone" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Continue", nil] show];
                }
            });
        }];
    }
}

- (IBAction)stopAudio:(UIButton*)button {
    [self.recorder stop];
    self.recorder.delegate = self;
    self.recordingInProgress.hidden = YES;
    [self.recordingSession setActive:NO error:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"show player"]) {
        PlaySoundsViewController *pvc = (PlaySoundsViewController*)segue.destinationViewController;
        RecordedAudio *recordedAudio = [[RecordedAudio alloc] init];
        recordedAudio.fileURL = recorder.url;
        recordedAudio.title = recorder.url.lastPathComponent;
        pvc.recordedAudio = recordedAudio;
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder*)recorder successfully:(BOOL)flag {
    if (flag) {
        [self performSegueWithIdentifier:@"show player" sender:self.stopButton];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"writing audio file"delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Continue", nil] show];
    }
}

@end
