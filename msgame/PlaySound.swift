//
//  PlaySound.swift
//  msgame
//
//  Created by chunlei on 30/12/2024.
//

import Foundation
import AVFoundation
import UIKit

var audioPlayer: AVAudioPlayer?

func playSound(sound: String, type: String){
    if let path = Bundle.main.path(forResource: sound, ofType: type){
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
        } catch{
            print("Could not play the sound file")
        }
    }
}

