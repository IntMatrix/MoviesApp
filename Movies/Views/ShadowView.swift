//
//  GradientView.swift
//  Movies
//
//  Created by Maria Deygin on 8/1/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    @IBInspectable var topShadow:Bool = true
    @IBInspectable var bottomShadow:Bool = true
    @IBInspectable var bottomShadowGrade:CGFloat = 0.3
    @IBInspectable var topShadowGrade:CGFloat = 0.3

    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let topStart = topShadow == true ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        let topGrade = topShadow == true ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8038622359) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        let bottomStart = bottomShadow == true ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        let bottomGrade = bottomShadow == true ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8038622359) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        let colors = [topStart.cgColor,topGrade.cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor, bottomGrade.cgColor, bottomStart.cgColor]
        let colorLocations: [CGFloat] = [0.0, topShadowGrade/2.5, topShadowGrade, 1-bottomShadowGrade, 1-bottomShadowGrade/2.5, 1.0]
        
            guard let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations) else { return }
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: [])
        
        
        

        
    }
}
