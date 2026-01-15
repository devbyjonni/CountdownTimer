//
//  CountdownTimer.swift
//  CountdownTimer
//
//  Created by Jonni Akesson on 2017-04-20.
//  Copyright © 2017 Jonni Akesson. All rights reserved.
//

import Foundation
import Combine

/// A high-precision countdown timer engine powered by Combine.
/// Uses `Date` calculations to prevent drift and ensures accuracy.
class CountdownTimer {
    
    // MARK: - Publishers
    // ViewModels subscribe to these for reactive updates.
    
    /// Emits the current remaining time as strings (HH, MM, SS).
    @Published var timeString: (hours: String, minutes: String, seconds: String) = ("00", "00", "00")
    
    /// Emits progress from 0.0 (start) to 1.0 (finished).
    @Published var progress: Float = 0.0
    
    /// Emits true when the timer reaches zero.
    @Published var isDone: Bool = false
    
    // MARK: - Private Properties
    
    private var totalDuration: TimeInterval = 0
    private var timeRemaining: TimeInterval = 0
    private var targetEndTime: Date?
    private var timerCancellable: AnyCancellable?
    
    // MARK: - Public Methods
    
    func setTimer(hours: Int, minutes: Int, seconds: Int) {
        let totalSeconds = (hours * 3600) + (minutes * 60) + seconds
        self.totalDuration = TimeInterval(totalSeconds)
        self.timeRemaining = self.totalDuration
        
        updateState()
    }
    
    func start() {
        // If already running, do nothing
        guard timerCancellable == nil else { return }
        
        // Calculate target end time based on current remaining time
        targetEndTime = Date().addingTimeInterval(timeRemaining)
        isDone = false
        
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    func pause() {
        stopTimer()
        // timeRemaining is preserved
    }
    
    func stop() {
        stopTimer()
        reset()
    }
    
    // MARK: - Private Helpers
    
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func reset() {
        timeRemaining = totalDuration
        isDone = false
        updateState()
    }
    
    private func tick() {
        guard let endTime = targetEndTime else { return }
        
        let now = Date()
        let remaining = endTime.timeIntervalSince(now)
        
        if remaining <= 0 {
            stopTimer()
            timeRemaining = 0
            isDone = true
        } else {
            timeRemaining = remaining
        }
        
        updateState()
    }
    
    private func updateState() {
        // Time String
        let time = Int(ceil(timeRemaining))
        let h = time / 3600
        let m = (time % 3600) / 60
        let s = time % 60
        
        timeString = (
            String(format: "%02d", h),
            String(format: "%02d", m),
            String(format: "%02d", s)
        )
        
        // Progress (0.0 to 1.0)
        if totalDuration > 0 {
            // Calculate elapsed fraction. 0.0 = Start, 1.0 = End.
            let elapsed = totalDuration - timeRemaining
            progress = Float(elapsed / totalDuration)
        } else {
            progress = 0.0
        }
    }
}
