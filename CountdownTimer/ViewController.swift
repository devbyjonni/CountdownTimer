//
//  ViewController.swift
//  CountdownTimer
//
//  Created by Jonni Akesson on 2017-04-20.
//  Copyright © 2017 Jonni Akesson. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController, CountdownTimerDelegate {

    //MARK: - UI Components
    
    lazy var progressBar: ProgressBar = {
        let view = ProgressBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var hoursLabel: UILabel = createLabel(text: "00")
    lazy var minutesLabel: UILabel = createLabel(text: "00")
    lazy var secondsLabel: UILabel = createLabel(text: "00")
    lazy var colon1Label: UILabel = createLabel(text: ":")
    lazy var colon2Label: UILabel = createLabel(text: ":")
    
    lazy var counterStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [hoursLabel, colon1Label, minutesLabel, colon2Label, secondsLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 3
        stack.alignment = .center
        return stack
    }()
    
    lazy var stopBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("STOP", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.gray, for: .highlighted)
        btn.addTarget(self, action: #selector(stopTimer), for: .touchUpInside)
        return btn
    }()
    
    lazy var startBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("START", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.gray, for: .highlighted)
        btn.addTarget(self, action: #selector(startTimer), for: .touchUpInside)
        return btn
    }()
    
    lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stopBtn, startBtn])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0 // Buttons were catching properly in storyboard
        return stack
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24.0, weight: .light)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.text = "Done!"
        label.isHidden = true
        return label
    }()
    
    //MARK: - Vars
    
    var countdownTimerDidStart = false
    
    lazy var countdownTimer: CountdownTimer = {
        let countdownTimer = CountdownTimer()
        return countdownTimer
    }()
    
    // Test, for dev
    let selectedSecs:Int = 120
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        countdownTimer.delegate = self
        countdownTimer.setTimer(hours: 0, minutes: 0, seconds: selectedSecs)
        progressBar.setProgressBar(hours: 0, minutes: 0, seconds: selectedSecs)
        
        stopBtn.isEnabled = false
        stopBtn.alpha = 0.5
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(progressBar)
        view.addSubview(counterStackView)
        view.addSubview(buttonStackView)
        view.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            // ProgressBar
            progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressBar.widthAnchor.constraint(equalToConstant: 300),
            progressBar.heightAnchor.constraint(equalToConstant: 300),
            
            // Counter StackView (Center of view, same as progress bar center)
            counterStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            counterStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            counterStackView.heightAnchor.constraint(equalToConstant: 48),
            
            // Button StackView
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30), // Adjusted from top layout guide logic loosely
            buttonStackView.heightAnchor.constraint(equalToConstant: 50),
            
            // Message Label (Centered)
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 32, weight: .light)
        label.textAlignment = .center
        
        // Add width constraints for fixed width digits if needed, but stackview distribution might handle it.
        // Original storyboard had widths: 39, 10, 39, 10, 40.
        // To be safe and identical:
        let width: CGFloat = (text == ":") ? 10 : 39
        label.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        return label
    }

    //MARK: - Countdown Timer Delegate
    
    func countdownTime(time: (hours: String, minutes: String, seconds: String)) {
        hoursLabel.text = time.hours
        minutesLabel.text = time.minutes
        secondsLabel.text = time.seconds
    }
    
    func countdownTimerDone() {
        counterStackView.isHidden = true
        messageLabel.isHidden = false
        secondsLabel.text = String(selectedSecs)
        countdownTimerDidStart = false
        stopBtn.isEnabled = false
        stopBtn.alpha = 0.5
        startBtn.setTitle("START",for: .normal)
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        print("countdownTimerDone")
    }
    
    //MARK: - Actions
    
    @objc func startTimer(_ sender: UIButton) {
        
        messageLabel.isHidden = true
        counterStackView.isHidden = false
        
        stopBtn.isEnabled = true
        stopBtn.alpha = 1.0
        
        if !countdownTimerDidStart{
            countdownTimer.start()
            progressBar.start()
            countdownTimerDidStart = true
            startBtn.setTitle("PAUSE",for: .normal)
            
        }else{
            countdownTimer.pause()
            progressBar.pause()
            countdownTimerDidStart = false
            startBtn.setTitle("RESUME",for: .normal)
        }
    }
    
    @objc func stopTimer(_ sender: UIButton) {
        countdownTimer.stop()
        progressBar.stop()
        countdownTimerDidStart = false
        stopBtn.isEnabled = false
        stopBtn.alpha = 0.5
        startBtn.setTitle("START",for: .normal)
    }
}
