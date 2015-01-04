//
//  UnderlinedButton.swift
//  Milk
//
//  Created by Richard Fickling on 10/8/14.
//  Copyright (c) 2014 Honey Science Corporation. All rights reserved.
//

import UIKit

@IBDesignable
class UnderlinedButton: UIButton {

    override func drawRect(rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        
        let textColor = self.titleLabel!.textColor
        
        CGContextSetStrokeColorWithColor(context, textColor.CGColor)
        
        CGContextSetLineWidth(context, 1.0)
        
        let lineY = self.titleLabel!.frame.origin.y + self.titleLabel!.frame.size.height
        let lineX = self.titleLabel!.frame.origin.x
        let lineLength = self.titleLabel!.frame.size.width
        CGContextMoveToPoint(context, lineX, lineY)
        CGContextAddLineToPoint(context, lineX + lineLength, lineY)
        CGContextStrokePath(context);
        
        super.drawRect(rect)
    }

}
