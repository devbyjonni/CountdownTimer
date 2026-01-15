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
    private let defaultDuration: Int = 30 // 2 minutes
    private var cancellables = Set<AnyCancellable>()
    

    
    // MARK: - Observables (Outputs)
    
    @Published var timeLabelText: String = "00:00:00"
    @Published var progress: Float = 0.0
    @Published var isPlaying: Bool = false
    
    /// Emits when the timer finishes.
    let timerFinished = PassthroughSubject<Void, Never>()
    
    init() {
        setupBindings()
        reset()
    }
    
    private func setupBindings() {
        // Transform the Timer's timeString (tuple) into a formatted String
        timer.$timeString
            .map { "\($0.0):\($0.1):\($0.2)" }
            .assign(to: &$timeLabelText)
        
        // Forward progress
        timer.$progress
            .assign(to: &$progress)
        
        // Timer done logic
        timer.$isDone
            .dropFirst()
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
        }
    }
    
    func pause() {
        if isPlaying {
            timer.pause()
            isPlaying = false
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
    }
    
    func skip() {
        // Skip behavior: Force done
        timer.stop()
        handleTimerDone()
    }
    
    // MARK: - Private Helpers
    
    private func reset() {
        isPlaying = false
        // Initialize timer with default
        timer.setTimer(hours: 0, minutes: 0, seconds: defaultDuration)
        // Reset progress manually since timer might not emit immediately on reset if stopped
        progress = 0.0
    }
    
    private func handleTimerDone() {
        isPlaying = false
        progress = 1.0
        timerFinished.send()
    }
}
