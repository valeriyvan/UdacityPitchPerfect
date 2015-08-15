//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Valeriy Van on 8/9/15.
//  Copyright (c) 2015 Valeriy Van. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!

    var recordingSession: AVAudioSession!

    lazy var fileURL: NSURL? = {
        return NSURL(fileURLWithPath: "\(NSHomeDirectory())/Documents/audio.aif")
    }()

    lazy var recorder: AVAudioRecorder? = {
        [unowned self] in
        if let fileURL = self.fileURL {
            let settings: [NSObject : AnyObject] = [ AVFormatIDKey: kAudioFormatAppleIMA4, AVSampleRateKey: 16400.0, AVNumberOfChannelsKey: 2]
            return AVAudioRecorder(URL: fileURL, settings: settings, error: nil)
        } else {
            return nil
        }
    }()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        recordButton.enabled = true
        stopButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func recordAudio(sender: UIButton) {
        recordingSession = AVAudioSession.sharedInstance()
        if recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil) &&
           recordingSession.setActive(true, error: nil)
        {
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        self.recorder?.record()
                        self.recordButton.enabled = false
                        self.recordingInProgress.hidden = false
                        self.stopButton.hidden = false
                    } else {
                        let alert = UIAlertView(title: "Error", message: "there is no permission to access microphone", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Continue")
                        alert.show()
                    }
                }
            }
        }
    }

    @IBAction func stopAudio(sender: UIButton) {
        if let recorder = recorder {
            recorder.stop()
            recorder.delegate = self
            recordingInProgress.hidden = true
            recordingSession.setActive(false, error: nil)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show player",
            let recorder = recorder,
            let player = segue.destinationViewController as? PlaySoundsViewController,
            let fileURL = self.fileURL
        {
            player.recordedAudio = RecordedAudio(fileURL: recorder.url, title: recorder.url.lastPathComponent!)
        }
    }

    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if flag {
            self.performSegueWithIdentifier("show player", sender: stopButton)
        } else {
            let alert = UIAlertView(title: "Error", message: "writing audio file", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Continue")
            alert.show()
        }
    }

}

