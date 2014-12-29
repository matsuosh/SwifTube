//
//  SeekBar.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/29.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import AVFoundation

class SeekBar: UIView {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!

    func configure() {
        slider.minimumValue = 0
        slider.maximumValue = 0
        startTimeLabel.text = formatTime(CMTimeMakeWithSeconds(Float64(slider.minimumValue), Int32(NSEC_PER_SEC)))
        endTimeLabel.text = formatTime(CMTimeMakeWithSeconds(Float64(slider.maximumValue), Int32(NSEC_PER_SEC)))
    }

    func configure(duration: CMTime) {
        slider.minimumValue = 0
        slider.maximumValue = Float(CMTimeGetSeconds(duration))
        startTimeLabel.text = formatTime(CMTimeMakeWithSeconds(Float64(slider.minimumValue), Int32(NSEC_PER_SEC)))
        endTimeLabel.text = formatTime(CMTimeMakeWithSeconds(Float64(slider.maximumValue), Int32(NSEC_PER_SEC)))
    }
    
    func setTime(currentTime: CMTime, duration: CMTime) {
        slider.value = Float(CMTimeGetSeconds(currentTime))
        startTimeLabel.text = formatTime(currentTime)
        let secondsOfEndTime = CMTimeGetSeconds(duration) - CMTimeGetSeconds(currentTime)
        endTimeLabel.text = formatTime(CMTimeMakeWithSeconds(secondsOfEndTime, Int32(NSEC_PER_SEC)))
    }

    private func formatTime(time: CMTime) -> String {
        let minutes = Int(CMTimeGetSeconds(time) / 60)
        let seconds = Int(CMTimeGetSeconds(time) % 60)
        return NSString(format: "%02ld:%02ld", minutes, seconds)
    }

}
