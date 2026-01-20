//
//  SeverityView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct SeverityView: View {
    @Binding var painLevel: MigraineEvent.PainLevel?
    
    var body: some View {
        VStack(spacing: Theme.Spacing.jumbo) {
            Text("How severe were the symptoms?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.top, Theme.Spacing.huge)

            
            // Organic layered pain visual
            VStack(spacing: Theme.Spacing.large) {
                OrganicPainVisual(painLevel: painLevel ?? .mild)
                    .frame(height: 250)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            painLevel = nextLevel(current: painLevel)
                        }
                    }
                
                VStack(spacing: Theme.Spacing.small) {
                    Text((painLevel ?? .mild).label)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    Text((painLevel ?? .mild).description)
                        .font(.body)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.extraLarge)
                }
            }
            
            Spacer()
        }
    }
    
    private func nextLevel(current: MigraineEvent.PainLevel?) -> MigraineEvent.PainLevel {
        switch current {
        case .mild, nil:
            return .moderate
        case .moderate:
            return .severe
        case .severe:
            return .mild
        }
    }
}

struct OrganicPainVisual: View {
    let painLevel: MigraineEvent.PainLevel
    
    var body: some View {
        ZStack {
            // MILD: One large nested blob pair
            NestedBlob(
                outerSeed: 1,
                innerSeed: 2,
                outerSize: 250,
                innerSize: 200,
                innerOffset: CGSize(width: -15, height: -10),
                outerColor: Theme.Colors.Raw.sageMist.opacity(0.4),
                innerColor: Theme.Colors.Raw.sageMist.opacity(0.6)
            )
            
            // MODERATE: Add 2 more nested blob pairs (bigger and closer to center)
            if painLevel == .moderate || painLevel == .severe {
                NestedBlob(
                    outerSeed: 3,
                    innerSeed: 4,
                    outerSize: 200,
                    innerSize: 160,
                    innerOffset: CGSize(width: 10, height: 8),
                    outerColor: Theme.Colors.Raw.softCeladon.opacity(0.3),
                    innerColor: Theme.Colors.Raw.softCeladon.opacity(0.5)
                )
                .offset(x: -20, y: -15)
                .transition(.scale.combined(with: .opacity))
                
                NestedBlob(
                    outerSeed: 5,
                    innerSeed: 6,
                    outerSize: 170,
                    innerSize: 130,
                    innerOffset: CGSize(width: -8, height: 6),
                    outerColor: Theme.Colors.Raw.deepSage.opacity(0.35),
                    innerColor: Theme.Colors.Raw.deepSage.opacity(0.55)
                )
                .offset(x: 25, y: 20)
                .transition(.scale.combined(with: .opacity))
            }
            
            // SEVERE: Add 2 more nested blob pairs (bigger and closer to center)
            if painLevel == .severe {
                NestedBlob(
                    outerSeed: 7,
                    innerSeed: 8,
                    outerSize: 150,
                    innerSize: 110,
                    innerOffset: CGSize(width: 6, height: -5),
                    outerColor: Theme.Colors.Raw.ironGrey.opacity(0.4),
                    innerColor: Theme.Colors.Raw.ironGrey.opacity(0.7)
                )
                .offset(x: -8, y: 10)
                .transition(.scale.combined(with: .opacity))
                
                NestedBlob(
                    outerSeed: 9,
                    innerSeed: 10,
                    outerSize: 120,
                    innerSize: 85,
                    innerOffset: CGSize(width: -5, height: 4),
                    outerColor: Theme.Colors.Raw.ironGrey.opacity(0.45),
                    innerColor: Theme.Colors.Raw.ironGrey.opacity(0.75)
                )
                .offset(x: 15, y: -20)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

// New component: A blob with a nested, darker blob inside (watercolor effect)
struct NestedBlob: View {
    let outerSeed: Int
    let innerSeed: Int
    let outerSize: CGFloat
    let innerSize: CGFloat
    let innerOffset: CGSize
    let outerColor: Color
    let innerColor: Color
    
    var body: some View {
        ZStack {
            // Outer blob (lighter)
            BlobShape(seed: outerSeed)
                .fill(outerColor)
                .frame(width: outerSize, height: outerSize)
            
            // Inner blob (darker) - offset for organic feel
            BlobShape(seed: innerSeed)
                .fill(innerColor)
                .frame(width: innerSize, height: innerSize)
                .offset(innerOffset)
        }
    }
}

// Custom organic blob shape
struct BlobShape: Shape {
    let seed: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        // Create organic blob using multiple control points
        let points = 8
        var blobPoints: [CGPoint] = []
        
        for i in 0..<points {
            let angle = (CGFloat(i) / CGFloat(points)) * 2 * .pi
            
            // Add organic variation based on seed
            let variation = CGFloat((seed * i) % 3) * 0.15 + 0.85
            let r = radius * variation
            
            let x = center.x + cos(angle) * r
            let y = center.y + sin(angle) * r
            blobPoints.append(CGPoint(x: x, y: y))
        }
        
        // Create smooth curve through points
        path.move(to: blobPoints[0])
        
        for i in 0..<blobPoints.count {
            let current = blobPoints[i]
            let next = blobPoints[(i + 1) % blobPoints.count]
            let nextNext = blobPoints[(i + 2) % blobPoints.count]
            
            let controlPoint1 = CGPoint(
                x: current.x + (next.x - current.x) * 0.5,
                y: current.y + (next.y - current.y) * 0.5
            )
            
            let controlPoint2 = CGPoint(
                x: next.x - (nextNext.x - next.x) * 0.2,
                y: next.y - (nextNext.y - next.y) * 0.2
            )
            
            path.addCurve(to: next, control1: controlPoint1, control2: controlPoint2)
        }
        
        path.closeSubpath()
        return path
    }
}

#Preview {
    SeverityView(painLevel: .constant(.moderate))
}
