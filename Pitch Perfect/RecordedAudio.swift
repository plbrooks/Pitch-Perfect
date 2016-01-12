//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Peter Brooks on 9/28/15.
//  Copyright (c) 2015 Peter Brooks. All rights reserved.
//

import Foundation

class RecordedAudio {
    var filePathURL: NSURL!
    var title: String!
    init (filePathURL: NSURL!, title: String!) {
        self.filePathURL = filePathURL
        self.title = title
    }
}

