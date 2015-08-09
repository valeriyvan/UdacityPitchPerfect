//
//  ViewController.swift
//  PitchPerfect
//
//  Created by Valeriy Van on 8/9/15.
//  Copyright (c) 2015 Valeriy Van. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

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
        recordButton.enabled = false
        recordingInProgress.hidden = false
        stopButton.hidden = false
    }

    @IBAction func stopAudio(sender: UIButton) {
        recordingInProgress.hidden = true
    }
}

