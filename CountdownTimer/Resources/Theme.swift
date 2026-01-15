//
//  Theme.swift
//  CountdownTimer
//
//  Created by Jonni Akesson on 2026-01-15.
//  Copyright © 2026 Jonni Akesson. All rights reserved.
//

import UIKit

struct Theme {
    
    struct Colors {
        // Modern Glow Zen Palette
        
        // Background Gradient: #2d1b69 -> #0f0c29
        static let zenBackgroundStart = UIColor(red: 45/255, green: 27/255, blue: 105/255, alpha: 1.0)
        static let zenBackgroundEnd = UIColor(red: 15/255, green: 12/255, blue: 41/255, alpha: 1.0)
        
        // Accent Ring Gradient: #818cf8 -> #3b82f6
        static let zenAccentStart = UIColor(red: 129/255, green: 140/255, blue: 248/255, alpha: 1.0)
        static let zenAccentEnd = UIColor(red: 59/255, green: 130/255, blue: 246/255, alpha: 1.0)
        
        // UI Elements
        static let indigo = UIColor(red: 99/255, green: 102/255, blue: 241/255, alpha: 1.0) // #6366f1
        static let background = UIColor(red: 15/255, green: 12/255, blue: 41/255, alpha: 1.0) // Fallback solid
        
        static let text = UIColor.white.withAlphaComponent(0.9)
        static let textSecondary = UIColor(red: 0.7, green: 0.7, blue: 1.0, alpha: 0.4) // Indigo-ish gray
        static let white = UIColor.white
        static let black = UIColor.black
    }
    
    struct Fonts {
        static func title(size: CGFloat = 20) -> UIFont {
            return .systemFont(ofSize: size, weight: .medium)
        }
        
        static func body(size: CGFloat = 16) -> UIFont {
            return .systemFont(ofSize: size, weight: .regular)
        }
        
        static func tinyLabel() -> UIFont {
            return .systemFont(ofSize: 10, weight: .bold)
        }
        
        static func timer(size: CGFloat = 48) -> UIFont {
            // Monospaced to prevent jitter
            return .monospacedDigitSystemFont(ofSize: size, weight: .black)
        }
        
        static func pillLabel() -> UIFont {
            return .systemFont(ofSize: 11, weight: .bold)
        }
    }
    
    struct Layout {
        static let buttonHeight: CGFloat = 50.0
        static let buttonCornerRadius: CGFloat = buttonHeight / 2.0
        
        static let playButtonSize: CGFloat = 80.0
        static let sideButtonSize: CGFloat = 40.0
    }
    
    struct Icons {
        static func refresh() -> UIImage? {
            return UIImage(systemName: "arrow.clockwise", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .light))
        }
        
        static func play() -> UIImage? {
            return UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .black))
        }
        
        static func pause() -> UIImage? {
            return UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .black))
        }
        
        static func skip() -> UIImage? {
            return UIImage(systemName: "forward.end.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .light))
        }
    }
}
