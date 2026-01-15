//
//  ViewController.swift
//  CountdownTimer
//
//  Created by Jonni Akesson on 2017-04-20.
//  Copyright © 2017 Jonni Akesson. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {

    // MARK: - Properties
    
    private let viewModel = TimerViewModel()
    
    // MARK: - UI Components
    
    private lazy var progressBar: ProgressBar = {
        let view = ProgressBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    // Timer Label
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00:00"
        label.textColor = Theme.Colors.text
        label.font = Theme.Fonts.timer() // Ensure this font is monospaced or looks good for single string
        label.textAlignment = .center
        return label
    }()
    
    // Player Controls
    private lazy var playPauseBtn: UIButton = createCircleButton(icon: Theme.Icons.play(), size: Theme.Layout.playButtonSize)
    private lazy var stopBtn: UIButton = createIconOnlyButton(icon: Theme.Icons.stop(), size: Theme.Layout.sideButtonSize)
    private lazy var skipBtn: UIButton = createIconOnlyButton(icon: Theme.Icons.skip(), size: Theme.Layout.sideButtonSize)
    
    private lazy var controlsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stopBtn, playPauseBtn, skipBtn])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalCentering // Spreads them out nicely or Center with spacing?
        stack.alignment = .center
        stack.spacing = 40
        return stack
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.Fonts.title()
        label.textColor = Theme.Colors.text
        label.textAlignment = .center
        label.text = "Done!"
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.refresh()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - Setup & Binding

private extension ViewController {
    
    func setupUI() {
        view.backgroundColor = Theme.Colors.background
        
        view.addSubview(progressBar)
        view.addSubview(timeLabel)
        view.addSubview(controlsStackView)
        view.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            // ProgressBar
            progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBar.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50), // Move up slightly
            progressBar.widthAnchor.constraint(equalToConstant: 300),
            progressBar.heightAnchor.constraint(equalToConstant: 300),
            
            // Timer Label
            timeLabel.centerXAnchor.constraint(equalTo: progressBar.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor),
            
            // Controls StackView
            controlsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            controlsStackView.heightAnchor.constraint(equalToConstant: Theme.Layout.playButtonSize), // Constrain height to tallest item
            
            // Message Label
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor)
        ])
        
        // Actions
        playPauseBtn.addTarget(self, action: #selector(togglePlay), for: .touchUpInside)
        stopBtn.addTarget(self, action: #selector(stopTimer), for: .touchUpInside)
        skipBtn.addTarget(self, action: #selector(skipTimer), for: .touchUpInside)
        
        playPauseBtn.backgroundColor = Theme.Colors.white
        playPauseBtn.tintColor = Theme.Colors.black
    }
    
    /// Binds the ViewModel's outputs to the View's inputs.
    /// This is where the magic happens: Data (VM) -> UI (View).
    func bindViewModel() {
        // updates the timer text labels (e.g. "00" "05" "30")
        viewModel.onTimeUpdate = { [weak self] h, m, s in
            self?.timeLabel.text = "\(h):\(m):\(s)"
        }
        
        viewModel.onStateChange = { [weak self] isPlaying in
            let icon = isPlaying ? Theme.Icons.pause() : Theme.Icons.play()
            self?.playPauseBtn.setImage(icon, for: .normal)
            
            // ProgressBar is now driven by onProgressUpdate, no need to start/pause animation
        }
        
        viewModel.onProgressUpdate = { [weak self] progress in
             self?.progressBar.setProgress(progress)
        }
        
        viewModel.onDone = { [weak self] in
            // Handle done state (e.g. show message, vibrate)
            self?.messageLabel.isHidden = false
            self?.timeLabel.isHidden = true
            self?.progressBar.stop()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    // MARK: - Factory Methods
    

    
    func createCircleButton(icon: UIImage?, size: CGFloat) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(icon, for: .normal)
        btn.layer.cornerRadius = size / 2
        btn.widthAnchor.constraint(equalToConstant: size).isActive = true
        btn.heightAnchor.constraint(equalToConstant: size).isActive = true
        return btn
    }
    
    func createIconOnlyButton(icon: UIImage?, size: CGFloat) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(icon, for: .normal)
        btn.tintColor = Theme.Colors.white
        btn.widthAnchor.constraint(equalToConstant: size).isActive = true
        btn.heightAnchor.constraint(equalToConstant: size).isActive = true
        return btn
    }
}

// MARK: - Actions

extension ViewController {
    @objc func togglePlay() {
        messageLabel.isHidden = true
        timeLabel.isHidden = false
        viewModel.toggle()
    }
    
    @objc func stopTimer() {
        viewModel.stop()
        resetUI()
    }
    
    @objc func skipTimer() {
        viewModel.skip()
    }
    
    private func resetUI() {
        messageLabel.isHidden = true
        timeLabel.isHidden = false
        progressBar.stop() // Reset animation
    }
}
