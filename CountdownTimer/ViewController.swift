//
//  ViewController.swift
//  CountdownTimer
//
//  Created by Jonni Akesson on 2017-04-20.
//  Copyright © 2017 Jonni Akesson. All rights reserved.
//

import UIKit
import AudioToolbox
import Combine

class ViewController: UIViewController {

    // MARK: - Properties
    
    private let viewModel = TimerViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var backgroundLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.type = .radial
        layer.colors = [Theme.Colors.zenBackgroundStart.cgColor, Theme.Colors.zenBackgroundEnd.cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        return layer
    }()
    
    // MARK: - UI Components
    
    private lazy var headerView: HeaderView = {
        let view = HeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var sessionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // Kern (Tracking)
        let attrString = NSMutableAttributedString(string: "DEMO MODE")
        attrString.addAttribute(NSAttributedString.Key.kern, value: 3.0, range: NSRange(location: 0, length: attrString.length))
        label.attributedText = attrString
        
        label.font = Theme.Fonts.tinyLabel()
        label.textColor = Theme.Colors.textSecondary
        return label
    }()
    
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
        label.text = "00:00"
        label.textColor = Theme.Colors.text
        label.font = Theme.Fonts.timer()
        label.textAlignment = .center
        return label
    }()
    
    // Timer Icon
    private lazy var timerIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "timer", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
        iv.tintColor = Theme.Colors.textSecondary
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    // Timer Stack (Text + Icon)
    private lazy var timerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timeLabel, timerIconImageView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()
    
    // Player Controls
    private lazy var controlsView: ControlsView = {
        let view = ControlsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.Fonts.title(size: 40)
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
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - Setup & Binding

extension ViewController {
    
    func setupUI() {
        // Background
        view.layer.insertSublayer(backgroundLayer, at: 0)
        
        view.addSubview(headerView)
        view.addSubview(progressBar)
        // Add Stack instead of label directly
        view.addSubview(timerStackView)
        view.addSubview(controlsView)
        view.addSubview(sessionLabel)
        view.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            headerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // ProgressBar (Centered)
            progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBar.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            progressBar.widthAnchor.constraint(equalToConstant: 320),
            progressBar.heightAnchor.constraint(equalToConstant: 320),
            
            // Timer Stack (Centered in ProgressBar)
            timerStackView.centerXAnchor.constraint(equalTo: progressBar.centerXAnchor),
            timerStackView.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor, constant: 10),
            
            // Controls
            controlsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlsView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 60),
            controlsView.widthAnchor.constraint(equalToConstant: 280),
            
            // Session Label
            sessionLabel.topAnchor.constraint(equalTo: controlsView.bottomAnchor, constant: 40),
            sessionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Message Label
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor)
        ])
        
        setupInteractions()
    }
    
    private func setupInteractions() {
        timerStackView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTimeLabel))
        timerStackView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapTimeLabel() {
        guard !viewModel.isPlaying else { return } // Disable when playing
        presentTimePicker()
    }
    
    private func presentTimePicker() {
        let alertController = UIAlertController(title: "Set Timer", message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let picker = UIDatePicker()
        picker.datePickerMode = .countDownTimer
        picker.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.addSubview(picker)
        
        NSLayoutConstraint.activate([
            picker.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor),
            picker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 20),
            picker.heightAnchor.constraint(equalToConstant: 160)
        ])
        
        let selectAction = UIAlertAction(title: "Start", style: .default) { [weak self] _ in
            let duration = picker.countDownDuration
            self?.viewModel.setDuration(duration)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        
        // iPad support
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = timerStackView
            popover.sourceRect = timerStackView.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundLayer.frame = view.bounds
    }
    
    /// Binds the ViewModel's outputs to the View's inputs.
    /// This is where the magic happens: Data (VM) -> UI (View).
    func bindViewModel() {
        // Time Label
        viewModel.$timeLabelText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.timeLabel.text = text
            }
            .store(in: &cancellables)
        
        // Progress
        viewModel.$progress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.progressBar.setProgress(progress)
            }
            .store(in: &cancellables)
            
        // Play/Pause State
        viewModel.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                self?.controlsView.setPlayingState(isPlaying)
            }
            .store(in: &cancellables)
            
        // Timer Finished Event
        viewModel.timerFinished
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.handleTimerFinished()
            }
            .store(in: &cancellables)
            
        // User Inputs (View -> ViewModel)
        controlsView.playPauseTapped
            .sink { [weak self] in self?.viewModel.toggle() }
            .store(in: &cancellables)
            
        controlsView.stopTapped
            .sink { [weak self] in
                self?.viewModel.stop()
                self?.resetUI()
            }
            .store(in: &cancellables)
            
        controlsView.skipTapped
            .sink { [weak self] in self?.viewModel.skip() }
            .store(in: &cancellables)
    }
    
    // MARK: - Private Helpers
    
    private func handleTimerFinished() {
        messageLabel.isHidden = false
        timerStackView.isHidden = true
        progressBar.stop()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        // Auto-reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            // Only reset if we are still in the "done" state (optional check)
            self?.viewModel.stop()
            self?.resetUI()
        }
    }
    
    private func resetUI() {
        messageLabel.isHidden = true
        timerStackView.isHidden = false
        progressBar.stop() // Reset animation
    }
}
