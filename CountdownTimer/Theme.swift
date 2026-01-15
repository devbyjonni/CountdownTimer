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
        static let spotifyGreen = UIColor(red: 29/255, green: 185/255, blue: 84/255, alpha: 1.0) // #1DB954
        static let spotifyBlack = UIColor(red: 25/255, green: 20/255, blue: 20/255, alpha: 1.0) // #191414
        static let white = UIColor.white
        static let darkGray = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        static let background = UIColor.black
        static let text = UIColor.white
        static let textSecondary = UIColor.lightGray
        static let black = UIColor.black
    }
    
    struct Fonts {
        static func title(size: CGFloat = 32) -> UIFont {
            return .systemFont(ofSize: size, weight: .bold)
        }
        
        static func body(size: CGFloat = 16) -> UIFont {
            return .systemFont(ofSize: size, weight: .medium)
        }
        
        static func button(size: CGFloat = 16) -> UIFont {
            return .systemFont(ofSize: size, weight: .bold)
        }
        
        static func timer(size: CGFloat = 32) -> UIFont {
            return .monospacedDigitSystemFont(ofSize: size, weight: .light)
        }
    }
    
    struct Layout {
        static let buttonHeight: CGFloat = 50.0
        static let buttonCornerRadius: CGFloat = buttonHeight / 2.0
        
        static let playButtonSize: CGFloat = 80.0
        static let sideButtonSize: CGFloat = 40.0
    }
    
    struct Icons {
        // Using System Symbols (SF Symbols) - compatible with iOS 13+.
        // Fallback or Image Literals could be used if strictly iOS 10 support needed, but SceneDelegate implies iOS 13+.
        static func play() -> UIImage? {
            return UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .bold))
        }
        
        static func pause() -> UIImage? {
            return UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .bold))
        }
        
        static func stop() -> UIImage? {
            return UIImage(systemName: "multiply", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        }
        
        static func skip() -> UIImage? {
            return UIImage(systemName: "forward.end.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        }
    }
}
