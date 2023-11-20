//
//  HStripe.swift
//  
//
//  Created by Andrea Russo on 11/20/23.
//

import SwiftUI

struct HStripe: Shape {
    var stripeSize: CGFloat?
    
    func path(in rect: CGRect) -> Path {
        // avoid size being too small for CG to calculate
        let stripe = stripeSize ?? defaultStripeSize
        let realStripeSize = (stripe < minStripeSize) ? minStripeSize : stripe
        let intervalSize = realStripeSize * stripeSpaceratio
        let numebrOfLines = Int(floor(rect.height / intervalSize))
        
        // Draw horizontal lines
        var p = Path()
        for i in (0...numberOfLines) {
            let startY = rect.minY + CGFloat(CGFloat(i) * intervalSize)
            let endY = realStripeSize + startY
            
            p.move(to: CGPoint(x: rect.minX, y: startY))
            p.addLine(to: CGPoint(x: rect.minX, y: endY))
            p.addLine(to: CGPoint(x: rect.maxX, y: endY))
            p.addLine(to: CGPoint(x: rect.maxX, y: startY))
            p.closeSubpath()
        }
        return p
    }
    
    // MARK: - Drawing Constants
    private let minStripeSize: CGFloat = 0.1
    private let defaultStripeSize: CGFloat = 1.0
    private let stripeSpaceRatio: CGFloat = 5.0
}

struct CardShadingView_Preview: PreviewProvider {
    static var preview: some View {
        HStripe(stripeSize: 3.0).previewLayout(.fixed(width:10, height: 10))
    }
}
