//
//  RecordedAudio.swift
//  PitchPerfect
//
//  Created by Valeriy Van on 8/9/15.
//  Copyright (c) 2015 Valeriy Van. All rights reserved.
//

import Foundation

class RecordedAudio {
    var fileURL: NSURL!
    var title: String!
    init(fileURL aFileURL: NSURL, title aTitle: String) {
        fileURL = aFileURL
        title = aTitle
    }
}