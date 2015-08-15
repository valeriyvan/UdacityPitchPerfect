//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Valeriy Van on 8/9/15.
//  Copyright (c) 2015 Valeriy Van. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var darthvaderButton: UIButton!

    @IBOutlet weak var stopButton: UIButton!

    var recordedAudio: RecordedAudio?
    
    lazy var player: AVAudioPlayer? = {
        [unowned self] in
        if let recordedAudio = self.recordedAudio,
            let fileURL = recordedAudio.fileURL {
            return AVAudioPlayer(contentsOfURL: fileURL, error: nil)
        } else {
            return nil
        }
    }()

    lazy var audioEngine: AVAudioEngine? = {
        return AVAudioEngine()
    }()

    lazy var audioFile: AVAudioFile? = {
        [unowned self] in
        if let recordedAudio = self.recordedAudio,
            let fileURL = recordedAudio.fileURL {
                return AVAudioFile(forReading: recordedAudio.fileURL, error: nil)
        } else {
            return nil
        }
    }()

    var audioPlayerNode: AVAudioPlayerNode?

    override func viewDidLoad() {
        super.viewDidLoad()
        if NSClassFromString("AVAudioEngine") == nil {
            chipmunkButton.enabled = false
            darthvaderButton.enabled = false
        }

        AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: nil)
    }

    // Helper
    func stopPlayer() {
        player?.stop()
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    // Helper
    func playWithRate(rate: Float) {
        if let player = player {
            player.enableRate = true
            player.rate = rate
            player.currentTime = 0.0
            player.delegate = self
            player.play()
            stopButton.enabled = true
        }
    }
    @IBAction func playSlow(sender: UIButton) {
        stopPlayer()
        playWithRate(0.5)
    }

    @IBAction func playFast(sender: UIButton) {
        stopPlayer()
        playWithRate(2.0)
    }

    // Helper
    func playAudioWithPith(pitch: Float) {
        player?.stop()
        stopButton.enabled = true
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
            // Forward audio output to speaker
            var inputDeviceID: UInt32 = 53 // TODO: get this using AudioObjectGetPropertyData
            let audioUnit: AudioUnit = audioEngine.inputNode.audioUnit
            let error: OSStatus  = AudioUnitSetProperty(audioUnit, AudioUnitPropertyID(kAudioOutputUnitProperty_CurrentDevice), AudioUnitScope(kAudioUnitScope_Global), AudioUnitElement(0), &inputDeviceID, UInt32(sizeof(inputDeviceID.dynamicType)))
            //
            audioPlayerNode = AVAudioPlayerNode()
            audioEngine.attachNode(audioPlayerNode)
            let changePitchEffect = AVAudioUnitTimePitch()
            changePitchEffect.pitch = pitch
            audioEngine.attachNode(changePitchEffect)
            audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
            audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
            audioPlayerNode?.scheduleFile(audioFile, atTime: nil, completionHandler: {
                [unowned self] in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.stopButton.enabled = false
                })
            })
            audioEngine.startAndReturnError(nil)
            audioPlayerNode?.play()
        }
    }

    @IBAction func playChipmunk(sender: AnyObject) {
        stopPlayer()
        playAudioWithPith(1000.0)
    }
    
    @IBAction func playDarthvader(sender: UIButton) {
        stopPlayer()
        playAudioWithPith(-1000.0)
    }

    @IBAction func stop(sender: UIButton) {
        if let player = player {
            player.stop()
            stopButton.enabled = false
        }
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
            stopButton.enabled = false
        }
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        stopButton.enabled = false
    }
}
