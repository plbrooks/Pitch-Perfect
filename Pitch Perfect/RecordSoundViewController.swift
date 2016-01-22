//
//  RecordSoundViewController.swift
//  Pitch Perfect
//
//  Created by Peter Brooks on 9/27/15.
//  Copyright (c) 2015 Peter Brooks. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundViewController: UIViewController,AVAudioRecorderDelegate {
    
    // outlets
    @IBOutlet weak var startRecordingButton: UIButton!
    @IBOutlet weak var recordingInProcess: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var pauseRecordingButton: UIButton!
    @IBOutlet weak var resumeRecordingButton: UIButton!
    @IBOutlet weak var stopRecordingLabel: UILabel!
    @IBOutlet weak var pauseRecordingLabel: UILabel!
    @IBOutlet weak var resumeRecordingLabel: UILabel!
    
    // vars and constants
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    let tapToStartRecording = "Tap to Record"
    let InProcess = "Recording In Process"
    let recordingPaused = "Recording Paused"
    
    /********************************************************************************************************
    * set up UI - what shows up and what does not once the microphone button pressed                        *
    ********************************************************************************************************/
    @IBAction func startRecording(sender: UIButton) {
        // change text, disable record button
        startRecordingButton.enabled = false
        
        //show controls
        recordingInProcessSetup()
        
        // set up recording file
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let recordingName = "my_audio.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
                
        // setup up audio recorder
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch _ {
        }
        let recordSettings = ["":0]
        audioRecorder = try? AVAudioRecorder (URL: filePath!, settings: recordSettings)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
   
    // per reviewer request, try out consolidating buttons
    @IBAction func pauseAndResumeRecording(sender: UIButton) {
        // we could show / hide buttons and text but choose to enaable / disable
        if (sender.tag == 1 ) {  // pause
            recordingInProcess.text = recordingPaused
            audioRecorder.pause()
            stopRecordingButton.enabled = false
            stopRecordingLabel.enabled  = false
            resumeRecordingButton.enabled = true
            resumeRecordingLabel.enabled = true
        }
        else {  // resume
            audioRecorder.record()
            recordingInProcessSetup()
        }
    }
    
    
    // recording complete, stop button pressed
    @IBAction func stopRecording(sender: UIButton) {
        audioRecorder.stop()
    }
    
    // save audio to file when finished
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            // set up sender info for seque
            recordedAudio = RecordedAudio(filePathURL:recorder.url, title:recorder.url.lastPathComponent)
            
            // segue to second screen
            performSegueWithIdentifier("StopRecording", sender: recordedAudio)
        } else {
            callAlert("Error", text:"Recording not working, try again later")
            beforeRecordingHasStartedSetup()
        }
    }
    
    // set up segue classes
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let playSoundsVC:PlaySoundViewController = segue.destinationViewController as! PlaySoundViewController
        let data = recordedAudio
        playSoundsVC.receivedAudio = data
    }

    
    // show alert button if recording error
    func callAlert(title: String, text: String) {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // setup before recording started
    func beforeRecordingHasStartedSetup () {
        // show these things
        startRecordingButton.enabled = true
        recordingInProcess.text = tapToStartRecording

        // hide these things
        stopRecordingButton.hidden = true
        stopRecordingLabel.hidden = true
        pauseRecordingButton.hidden = true
        pauseRecordingLabel.hidden = true
        resumeRecordingButton.hidden = true
        resumeRecordingLabel.hidden = true
    }
   
    // change buttons and labels when recording has started
    func recordingInProcessSetup () {
        recordingInProcess.text = InProcess
        stopRecordingButton.hidden = false
        stopRecordingLabel.hidden = false
        stopRecordingButton.enabled = true
        stopRecordingLabel.enabled = true
        pauseRecordingButton.hidden = false
        pauseRecordingLabel.hidden = false
        resumeRecordingButton.hidden = false
        resumeRecordingLabel.hidden = false
        resumeRecordingButton.enabled = false
        resumeRecordingLabel.enabled = false
    }

    // set up default UI when screen first appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        resumeRecordingButton.setTitleColor(UIColor.grayColor(), forState: .Disabled)
        beforeRecordingHasStartedSetup()
    }
        
}

