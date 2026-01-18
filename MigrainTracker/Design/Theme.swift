//
//  Theme.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 18.01.26.
//

import SwiftUI

struct Theme {
    struct Colors {
        // Base colors from Assets
        struct Raw {
            static let aliceBlue = Color("AliceBlue")
            static let powderBlue = Color("PowderBlue")  // Reserved for future use
            static let lavenderGrey = Color("LavenderGrey")
            static let ironGrey = Color("IronGrey")
            static let charcoal = Color("Charcoal")
            static let sageGreen = Color("SageGreen")
            static let softMint = Color("SoftMint")
            static let adobeRed = Color("AdobeRed")
        }
        
        // Semantic UI colors
        static let primaryAction = Raw.sageGreen
        static let primaryActionPressed = Raw.sageGreen.opacity(0.8)
        static let disabledAction = Raw.lavenderGrey.opacity(0.5)
        
        static let primaryBackground = Raw.aliceBlue
        static let cardBackground = Color(.systemBackground)
        static let secondaryBackground = Color(.systemGray6)
        
        static let primaryText = Raw.ironGrey
        static let secondaryText = Raw.lavenderGrey
        static let inverseText = Color.white
        
        static let separator = Raw.lavenderGrey.opacity(0.3)
        static let shadow = Color.black.opacity(0.2)
        
        // Status colors
        static let success = Raw.softMint
        static let error = Raw.adobeRed
        static let warning = Color.orange
        
        // Pain level helper
        static func painLevel(_ level: MigraineEvent.PainLevel) -> Color {
            switch level {
            case .mild: return Raw.lavenderGrey
            case .moderate: return Raw.charcoal
            case .severe: return Raw.ironGrey
            }
        }
    }
    
    struct Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let regular: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
        static let huge: CGFloat = 40
        static let jumbo: CGFloat = 50
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
    }
    
    struct Size {
        // Dots and indicators
        static let dotTiny: CGFloat = 4
        static let dotSmall: CGFloat = 8
        static let indicator: CGFloat = 12
        
        // Standard iOS touch target
        static let touchTarget: CGFloat = 44
    }
    
    struct Shadow {
        static let color = Color.black.opacity(0.2)
        
        struct Radius {
            static let small: CGFloat = 4
            static let medium: CGFloat = 8
            static let large: CGFloat = 20
        }
        
        struct Opacity {
            static let subtle: Double = 0.1
            static let regular: Double = 0.2
            static let strong: Double = 0.3
        }
    }
}
