//
//  TimerViewModel.swift
//  CountdownTimer
//
//  Created by Jonni Akesson on 2026-01-15.
//  Copyright © 2026 Jonni Akesson. All rights reserved.
//

import Foundation
import Combine

/// Manages the state and logic of the Timer screen.
/// Acts as the ViewModel in the MVVM pattern, exposing data via Closures or Publishers.
class TimerViewModel {
    
    // MARK: - Properties
    
    private let timer = CountdownTimer()
    private let defaultDuration: Int = 120 // 2 minutes
    private var cancellables = Set<AnyCancellable>()
    
    /// True if the timer is currently counting down.
    var isPlaying = false
    
    // MARK: - Observables (Outputs)
    // The View binds to these closures to update its UI.
    
    /// Called when the time string changes (HH, MM, SS).
    var onTimeUpdate: ((String, String, String) -> Void)?
    
    /// Called when progress changes (0.0 to 1.0).
    var onProgressUpdate: ((Float) -> Void)?
    
    /// Called when the play/pause state changes.
    var onStateChange: ((Bool) -> Void)?
    
    /// Called when the timer finishes.
    var onDone: (() -> Void)?
    
    init() {
        setupBindings()
        reset()
    }
    
    private func setupBindings() {
        // Bind Timer Publishers to ViewModel Observables
        timer.$timeString
            .sink { [weak self] (h, m, s) in
                self?.onTimeUpdate?(h, m, s)
            }
            .store(in: &cancellables)
        
        timer.$progress
            .sink { [weak self] progress in
                self?.onProgressUpdate?(progress)
            }
            .store(in: &cancellables)
        
        timer.$isDone
            .dropFirst() // Ignore initial false
            .filter { $0 == true }
            .sink { [weak self] _ in
                self?.handleTimerDone()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Inputs
    // Methods called by the View to triggers actions.
    
    /// Starts the timer if not already running.
    func start() {
        if !isPlaying {
            timer.start()
            isPlaying = true
            onStateChange?(true)
        }
    }
    
    func pause() {
        if isPlaying {
            timer.pause()
            isPlaying = false
            onStateChange?(false)
        }
    }
    
    func toggle() {
        if isPlaying {
            pause()
        } else {
            start()
        }
    }
    
    func stop() {
        timer.stop()
        reset()
        onStateChange?(false)
    }
    
    func skip() {
        // Skip behavior: Force done
        timer.stop()
        handleTimerDone()
    }
    
    func refresh() {
        // Re-emit current state for UI binding
        let t = timer.timeString
        onTimeUpdate?(t.hours, t.minutes, t.seconds)
        onProgressUpdate?(timer.progress)
        onStateChange?(isPlaying)
    }
    
    // MARK: - Private Helpers
    
    private func reset() {
        isPlaying = false
        // Initialize timer with default
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds: defaultDuration)
        timer.setTimer(hours: 0, minutes: 0, seconds: defaultDuration)
    }
    
    private func handleTimerDone() {
        isPlaying = false
        onStateChange?(false)
        onProgressUpdate?(1.0)
        onDone?()
    }
    
    private func secondsToHoursMinutesSeconds (seconds : Int) -> (String, String, String) {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = (seconds % 3600) % 60
        return (String(format: "%02d", h), String(format: "%02d", m), String(format: "%02d", s))
    }
}
