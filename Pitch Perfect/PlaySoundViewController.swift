//
//  PlaySoundViewController.swift
//  Pitch Perfect
//
//  Created by Peter Brooks on 9/27/15.
//  Copyright (c) 2015 Peter Brooks. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundViewController: UIViewController {

    // vars
    var audioPlayer:AVAudioPlayer!
    var audioPlayerForEcho:AVAudioPlayer!
    var receivedAudio:RecordedAudio!
    
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    
    // actions
    @IBAction func playFastButton(sender: UIButton) {
        playAtRate(1.5)
    }
    @IBAction func playSlowButton(sender: AnyObject) {
        playAtRate(0.5)
    }
    @IBAction func stopPlay(sender: UIButton) {
        stopAndResetAudio()
    }
    
    @IBAction func playChimpmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    /********************************************************************************************************
     * create an echo by playing sound twice including at a delay                                           *
     ********************************************************************************************************/
    @IBAction func PlayEcho(sender: UIButton) {
        // play audio
        stopAndResetAudio()
        setCurrentTime(audioPlayer, time:0.0)
        audioPlayer.play()
        
        // play audio + dela
        // updated from stackoverflow
        var error:NSError?
        do {
            audioPlayerForEcho = try AVAudioPlayer(contentsOfURL:receivedAudio.filePathURL)
        } catch let error1 as NSError {
            error = error1
            audioPlayerForEcho = nil
        }
        if (error == nil) {
            audioPlayerForEcho.enableRate = true
        }
        let delay:NSTimeInterval = 0.5
        var playtime:NSTimeInterval
        playtime = audioPlayerForEcho.deviceCurrentTime + delay
        audioPlayerForEcho.stop()
        audioPlayerForEcho.currentTime = 0
        audioPlayerForEcho.volume = 0.75;
        audioPlayerForEcho.playAtTime(playtime)
    }
    
    // change pitch. Used for Chipmuck and DarthVader sounds
    func playAudioWithVariablePitch(pitch: Float) {
        
        stopAndResetAudio()
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngineProcessing(changePitchEffect)
    }
    
    // play at rate
    func playAtRate(rate: Float) {
        stopAndResetAudio()
        setRate(rate)
        setCurrentTime(audioPlayer,time:0.0)
        audioPlayer.play()
    }
    
    // set rate
    func setRate(rate: Float) {
        audioPlayer.rate = rate
    }
    
    // set time
    func setCurrentTime(player: AVAudioPlayer, time: NSTimeInterval) {
        player.currentTime = time
    }
    
    // init audioPlayer and audioEngine before being used
    func stopAndResetAudio () {
        audioPlayer.stop()
        audioEngine.stop()
        if (audioPlayerForEcho != nil) {audioPlayerForEcho.stop()}
        audioEngine.reset()
        setRate(1.0)
    }

    // perform audioEngine processing to play pitch-change buttons
    func audioEngineProcessing (pitchEffect: AVAudioUnitTimePitch) {
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(pitchEffect)
        audioEngine.connect(audioPlayerNode, to: pitchEffect, format: nil)
        audioEngine.connect(pitchEffect, to: audioEngine.outputNode, format: nil)
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        do {
        try audioEngine.start()
        } catch _ {
        }
        audioPlayerNode.play()
    }
    
    override func viewDidLoad() {
        
        // initializations
        super.viewDidLoad()
        var error:NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL:receivedAudio.filePathURL)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        if (error == nil) {
            audioPlayer.enableRate = true
        }
        audioEngine = AVAudioEngine()
        audioFile = try? AVAudioFile(forReading: receivedAudio.filePathURL)
    }
}
