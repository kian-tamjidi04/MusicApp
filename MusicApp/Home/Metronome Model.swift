//
//  Metronome Model.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 26/01/2023.
//

import SwiftUI
import Combine

class Metronome: ObservableObject {
    var timer: Timer?
    public let objectWillChange = PassthroughSubject<Void, Never>()
    public let granularity: Int = 16
    
    public var timeInterval: TimeInterval {
        return 1 / ((Double(beatsPerMinute) / 60.0) * 4)
    }
    
    func configureTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { timer in
            self.tick()
        }
    }
    public var current: Int = 0
    
    var crotchet: (current: Int, total: Int) {
        (current / 4, 4)
    }

    func tick() {
        current += 1
        if current >= granularity {
            current = 0
        }
        objectWillChange.send()
    }
    
    var beatsPerMinute: Int {
        Int(sliderPercent * 300)
    }
    
    var sliderPercent: Double = 0 {
        didSet {
            configureTimer()
            objectWillChange.send()
        }
    }
}
