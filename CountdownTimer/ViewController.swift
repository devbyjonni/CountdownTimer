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
    
    // Header Pill
    private lazy var headerPill: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 15
        return view
    }()
    
    private lazy var headerDot: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 129/255, green: 140/255, blue: 248/255, alpha: 1.0) // Indigo-400
        view.layer.cornerRadius = 4
        return view
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "DEEP WORK"
        label.font = Theme.Fonts.pillLabel()
        label.textColor = UIColor(red: 199/255, green: 210/255, blue: 254/255, alpha: 0.8) // Indigo-200/80
        
        // Kern (Tracking)
        let attrString = NSMutableAttributedString(string: "DEEP WORK")
        attrString.addAttribute(NSAttributedString.Key.kern, value: 2.0, range: NSRange(location: 0, length: attrString.length))
        label.attributedText = attrString
        
        return label
    }()
    
    private lazy var headerTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "UI Design Systems"
        label.font = Theme.Fonts.title()
        label.textColor = Theme.Colors.text
        label.textAlignment = .center
        return label
    }()
    
    private lazy var sessionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // Kern (Tracking)
        let attrString = NSMutableAttributedString(string: "SESSION 2 OF 4")
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
        label.text = "00:00:00"
        label.textColor = Theme.Colors.text
        label.font = Theme.Fonts.timer() // Ensure this font is monospaced or looks good for single string
        label.textAlignment = .center
        return label
    }()
    
    // Player Controls
    private lazy var playPauseBtn: UIButton = createGlowButton(icon: Theme.Icons.play(), size: 90)
    private lazy var stopBtn: UIButton = createGlassButton(icon: Theme.Icons.refresh(), size: 64)
    private lazy var skipBtn: UIButton = createGlassButton(icon: Theme.Icons.skip(), size: 64)
    
    private lazy var controlsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stopBtn, playPauseBtn, skipBtn])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalCentering 
        stack.alignment = .center
        stack.spacing = 30
        return stack
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
        
        // Header
        headerPill.addSubview(headerDot)
        headerPill.addSubview(headerLabel)
        
        view.addSubview(headerPill)
        view.addSubview(headerTitle)
        
        view.addSubview(progressBar)
        view.addSubview(timeLabel)
        view.addSubview(controlsStackView)
        view.addSubview(sessionLabel)
        view.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            // Header Pill
            headerPill.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            headerPill.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerPill.heightAnchor.constraint(equalToConstant: 30),
            
            headerDot.leadingAnchor.constraint(equalTo: headerPill.leadingAnchor, constant: 12),
            headerDot.centerYAnchor.constraint(equalTo: headerPill.centerYAnchor),
            headerDot.widthAnchor.constraint(equalToConstant: 8),
            headerDot.heightAnchor.constraint(equalToConstant: 8),
            
            headerLabel.leadingAnchor.constraint(equalTo: headerDot.trailingAnchor, constant: 8),
            headerLabel.trailingAnchor.constraint(equalTo: headerPill.trailingAnchor, constant: -12),
            headerLabel.centerYAnchor.constraint(equalTo: headerPill.centerYAnchor),
            
            // Header Title
            headerTitle.topAnchor.constraint(equalTo: headerPill.bottomAnchor, constant: 20),
            headerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // ProgressBar (Centered)
            progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBar.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            progressBar.widthAnchor.constraint(equalToConstant: 320),
            progressBar.heightAnchor.constraint(equalToConstant: 320),
            
            // Timer Label
            timeLabel.centerXAnchor.constraint(equalTo: progressBar.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor),
            
            // Controls StackView
            controlsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlsStackView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 60),
            controlsStackView.widthAnchor.constraint(equalToConstant: 280),
            
            // Session Label
            sessionLabel.topAnchor.constraint(equalTo: controlsStackView.bottomAnchor, constant: 40),
            sessionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Message Label
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor)
        ])
        
        // Actions
        playPauseBtn.addTarget(self, action: #selector(togglePlay), for: .touchUpInside)
        stopBtn.addTarget(self, action: #selector(stopTimer), for: .touchUpInside)
        skipBtn.addTarget(self, action: #selector(skipTimer), for: .touchUpInside)
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
                let icon = isPlaying ? Theme.Icons.pause() : Theme.Icons.play()
                self?.playPauseBtn.setImage(icon, for: .normal)
            }
            .store(in: &cancellables)
            
        // Timer Finished Event
        viewModel.timerFinished
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.handleTimerFinished()
            }
            .store(in: &cancellables)
    }
    
    private func handleTimerFinished() {
        messageLabel.isHidden = false
        timeLabel.isHidden = true
        progressBar.stop()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        // Auto-reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            // Only reset if we are still in the "done" state (optional check)
            self?.viewModel.stop()
            self?.resetUI()
        }
    }
    
    // MARK: - Factory Methods
    

    
    func createGlowButton(icon: UIImage?, size: CGFloat) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(icon, for: .normal)
        btn.backgroundColor = Theme.Colors.white.withAlphaComponent(0.9) // Soften the stark white
        btn.tintColor = Theme.Colors.indigo // Indigo icon
        btn.layer.cornerRadius = size / 2
        
        // Glow Shadow
        btn.layer.shadowColor = Theme.Colors.indigo.cgColor
        btn.layer.shadowOffset = .zero
        btn.layer.shadowRadius = 20
        btn.layer.shadowOpacity = 0.5
        
        btn.widthAnchor.constraint(equalToConstant: size).isActive = true
        btn.heightAnchor.constraint(equalToConstant: size).isActive = true
        return btn
    }
    
    func createGlassButton(icon: UIImage?, size: CGFloat) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(icon, for: .normal)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        btn.layer.borderWidth = 1
        btn.tintColor = UIColor.white.withAlphaComponent(0.7)
        btn.layer.cornerRadius = size / 2
        
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
