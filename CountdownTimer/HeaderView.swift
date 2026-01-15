import UIKit

class HeaderView: UIView {
    
    // MARK: - UI Components
    
    private lazy var pillContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 15
        return view
    }()
    
    private lazy var statusDot: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 129/255, green: 140/255, blue: 248/255, alpha: 1.0) // Indigo-400
        view.layer.cornerRadius = 4
        return view
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 199/255, green: 210/255, blue: 254/255, alpha: 0.8) // Indigo-200/80
        
        let attrString = NSMutableAttributedString(string: "DEEP WORK")
        attrString.addAttribute(NSAttributedString.Key.kern, value: 2.0, range: NSRange(location: 0, length: attrString.length))
        label.attributedText = attrString
        
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "UI Design Systems"
        label.font = Theme.Fonts.title()
        label.textColor = Theme.Colors.text
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(pillContainer)
        pillContainer.addSubview(statusDot)
        pillContainer.addSubview(statusLabel)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            // Pill
            pillContainer.topAnchor.constraint(equalTo: topAnchor),
            pillContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            pillContainer.heightAnchor.constraint(equalToConstant: 30),
            
            // Dot
            statusDot.leadingAnchor.constraint(equalTo: pillContainer.leadingAnchor, constant: 12),
            statusDot.centerYAnchor.constraint(equalTo: pillContainer.centerYAnchor),
            statusDot.widthAnchor.constraint(equalToConstant: 8),
            statusDot.heightAnchor.constraint(equalToConstant: 8),
            
            // Status Text
            statusLabel.leadingAnchor.constraint(equalTo: statusDot.trailingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: pillContainer.trailingAnchor, constant: -12),
            statusLabel.centerYAnchor.constraint(equalTo: pillContainer.centerYAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: pillContainer.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
