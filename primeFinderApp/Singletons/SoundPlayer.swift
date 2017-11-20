//
//  SoundPlayer.swift
//  primeFinderApp
//
//  Created by Yasin TURKOGLU on 11.10.2017.
//  Copyright © 2017 Yasin TURKOGLU. All rights reserved.
//

import UIKit
import AVFoundation

class SoundPlayer: NSObject, AVAudioPlayerDelegate {

    static let sharedInstance = SoundPlayer()
    private var audioSession:AVAudioSession = AVAudioSession.sharedInstance()
    private var bellURL:URL!
    private var buttonTouchDownURL:URL!
    private var buttonTouchUpURL:URL!
    private var shakeURL:URL!
    private let serialQueue = DispatchQueue(label: "soundQueue")
    private var bellSoundPlayer:AVAudioPlayer!
    private var touchDownPlayerSoundID:Int = 0
    private var touchDownPlayerQueue = [AVAudioPlayer]()
    private var globalRate:Float = 1.1
    private var touchDownTime:Date!
    private var touchUpPlayerSoundID:Int = 0
    private var touchUpPlayerQueue = [AVAudioPlayer]()
    private var touchUpDelay:DispatchWorkItem!
    private var shakeSoundPlayer:AVAudioPlayer!
    
    private override init() {
        super.init()
    }
    
    func prepareSoundPlayer() {
        do {
            try self.audioSession.setCategory(AVAudioSessionCategoryAmbient, with: AVAudioSessionCategoryOptions.mixWithOthers)
            try self.audioSession.setMode(AVAudioSessionModeDefault)
            try self.audioSession.setActive(true)
        } catch let error {
            print("audioSession setCategory error:\(error.localizedDescription)")
        }
        self.bellURL = Bundle.main.url(forResource: "bell", withExtension: "mp3")
        self.buttonTouchDownURL = Bundle.main.url(forResource: "buttonTouchDown", withExtension: "mp3")
        self.buttonTouchUpURL = Bundle.main.url(forResource: "buttonTouchUp", withExtension: "mp3")
        self.shakeURL = Bundle.main.url(forResource: "shake", withExtension: "mp3")
    }
    
    func playBell() {
        self.serialQueue.async {
            if self.bellSoundPlayer == nil {
                if let soundURL = self.bellURL {
                    do {
                        self.bellSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
                        self.bellSoundPlayer.delegate = self
                        self.bellSoundPlayer.volume = 0.1
                        self.bellSoundPlayer.numberOfLoops = 0
                        self.bellSoundPlayer.accessibilityHint = "bellSound"
                        self.bellSoundPlayer.prepareToPlay()
                        self.bellSoundPlayer.play()
                    } catch let error {
                        print("AVAudioPlayer error:\(error.localizedDescription)")
                    }
                }
            } else {
                if self.bellSoundPlayer.isPlaying {
                    self.bellSoundPlayer.stop()
                    self.bellSoundPlayer.currentTime = 0.0
                    self.bellSoundPlayer.play()
                }
            }
        }
    }
    
    
    func playTouchDown() {
        self.touchDownTime = Date()
        self.serialQueue.async {
            if let soundURL = self.buttonTouchDownURL {
                do {
                    let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    audioPlayer.delegate = self
                    audioPlayer.volume = 1.0
                    audioPlayer.numberOfLoops = 0
                    audioPlayer.enableRate = true
                    self.globalRate = 1.1 + (Float(arc4random_uniform(UInt32(3))) * 0.1)
                    audioPlayer.rate = self.globalRate
                    audioPlayer.accessibilityHint = "down\(self.touchDownPlayerSoundID)"
                    audioPlayer.prepareToPlay()
                    self.touchDownPlayerQueue.append(audioPlayer)
                    audioPlayer.play()
                    self.touchDownPlayerSoundID += 1
                } catch let error {
                    print("AVAudioPlayer error:\(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func playTouchUp() {
        var timeDifference:Float = 0
        if self.touchDownTime != nil {
            timeDifference = Float(Date().timeIntervalSince(self.touchDownTime))
        }
        self.serialQueue.async {
            if let soundURL = self.buttonTouchUpURL {
                do {
                    let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    audioPlayer.delegate = self
                    audioPlayer.volume = 0.1
                    audioPlayer.numberOfLoops = 0
                    audioPlayer.enableRate = true
                    audioPlayer.rate = self.globalRate
                    audioPlayer.accessibilityHint = "up\(self.touchUpPlayerSoundID)"
                    audioPlayer.prepareToPlay()
                    if timeDifference >= 0.1 {
                        self.touchUpPlayerQueue.append(audioPlayer)
                        audioPlayer.play()
                    } else {
                        if self.touchUpDelay != nil {
                            self.touchUpDelay.cancel()
                            self.touchUpDelay = nil
                        }
                        self.touchUpDelay = delay(delay: 0.1, completionHandler: {
                            self.touchUpPlayerQueue.append(audioPlayer)
                            audioPlayer.play()
                        })
                    }
                    self.touchUpPlayerSoundID += 1
                } catch let error {
                    print("AVAudioPlayer error:\(error.localizedDescription)")
                }
            }
        }
    }
    
    func playShake() {
        self.serialQueue.async {
            if self.shakeSoundPlayer == nil {
                if let soundURL = self.shakeURL {
                    do {
                        self.shakeSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
                        self.shakeSoundPlayer.delegate = self
                        self.shakeSoundPlayer.volume = 1.0
                        self.shakeSoundPlayer.numberOfLoops = 0
                        self.shakeSoundPlayer.accessibilityHint = "shakeSound"
                        self.shakeSoundPlayer.prepareToPlay()
                        self.shakeSoundPlayer.play()
                    } catch let error {
                        print("AVAudioPlayer error:\(error.localizedDescription)")
                    }
                }
            } else {
                if self.shakeSoundPlayer.isPlaying {
                    self.shakeSoundPlayer.stop()
                    self.shakeSoundPlayer.currentTime = 0.0
                    self.shakeSoundPlayer.play()
                }
            }
        }
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.serialQueue.async {
            if let playerHint = player.accessibilityHint {
                if playerHint != "bellSound" && playerHint != "shakeSound" {
                    if let foundPlayer = self.touchDownPlayerQueue.index(where: { (aPlayer) -> Bool in
                        return aPlayer.accessibilityHint == playerHint
                    }) {
                        self.touchDownPlayerQueue.remove(at: foundPlayer)
                    }
                    if let foundPlayer = self.touchUpPlayerQueue.index(where: { (aPlayer) -> Bool in
                        return aPlayer.accessibilityHint == playerHint
                    }) {
                        self.touchUpPlayerQueue.remove(at: foundPlayer)
                    }
                } else {
                    if playerHint == "bellSound" {
                        self.bellSoundPlayer.delegate = nil
                        self.bellSoundPlayer = nil
                    }
                    if playerHint == "shakeSound" {
                        self.shakeSoundPlayer.delegate = nil
                        self.shakeSoundPlayer = nil
                    }
                }
            }
        }
    }
    
    
}
