//
//  SystemSoundID+.swift
//  DynamicAnimations
//
//  Created by Marty Avedon on 1/27/17.
//  Copyright © 2017 AccessCode. All rights reserved.
//

import Foundation
import AudioToolbox

// from http://stackoverflow.com/questions/24043904/creating-and-playing-a-sound-in-swift
extension SystemSoundID {
    static func playFileNamed(fileName: String, withExtenstion fileExtension: String) {
        var sound: SystemSoundID = 0
        if let soundURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &sound)
            AudioServicesPlaySystemSound(sound)
        }
    }
}

// sound effect courtesy of https://www.partnersinrhyme.com/soundfx/PUBLIC-DOMAIN-SOUNDS/misc_sounds/beep_beep-spac_wav.shtml
