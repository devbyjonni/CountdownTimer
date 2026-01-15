import UIKit
import Combine

class ControlsView: UIView {
    
    // MARK: - Publishers
    
    let playPauseTapped = PassthroughSubject<Void, Never>()
    let stopTapped = PassthroughSubject<Void, Never>()
    let skipTapped = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    
    private lazy var playPauseBtn: UIButton = createGlowButton(icon: Theme.Icons.play(), size: 90)
    private lazy var stopBtn: UIButton = createGlassButton(icon: Theme.Icons.refresh(), size: 64)
    private lazy var skipBtn: UIButton = createGlassButton(icon: Theme.Icons.skip(), size: 64)
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stopBtn, playPauseBtn, skipBtn])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.alignment = .center
        stack.spacing = 30
        return stack
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public API
    
    func setPlayingState(_ isPlaying: Bool) {
        let icon = isPlaying ? Theme.Icons.pause() : Theme.Icons.play()
        playPauseBtn.setImage(icon, for: .normal)
    }
    
    // MARK: - Internal Setup
    
    private func setupUI() {
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 90) // Height of tallest button
        ])
        
        playPauseBtn.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        stopBtn.addTarget(self, action: #selector(didTapStop), for: .touchUpInside)
        skipBtn.addTarget(self, action: #selector(didTapSkip), for: .touchUpInside)
    }
    
    @objc private func didTapPlayPause() {
        playPauseTapped.send()
    }
    
    @objc private func didTapStop() {
        stopTapped.send()
    }
    
    @objc private func didTapSkip() {
        skipTapped.send()
    }
    
    // MARK: - Factory Methods
    
    private func createGlowButton(icon: UIImage?, size: CGFloat) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(icon, for: .normal)
        btn.backgroundColor = Theme.Colors.white.withAlphaComponent(0.9)
        btn.tintColor = Theme.Colors.indigo
        btn.layer.cornerRadius = size / 2
        
        btn.layer.shadowColor = Theme.Colors.indigo.cgColor
        btn.layer.shadowOffset = .zero
        btn.layer.shadowRadius = 20
        btn.layer.shadowOpacity = 0.5
        
        btn.widthAnchor.constraint(equalToConstant: size).isActive = true
        btn.heightAnchor.constraint(equalToConstant: size).isActive = true
        return btn
    }
    
    private func createGlassButton(icon: UIImage?, size: CGFloat) -> UIButton {
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
