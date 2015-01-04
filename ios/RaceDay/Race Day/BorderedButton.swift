//
//  BorderedButton.swift
//  Milk
//
//  Created by Richard Fickling on 8/27/14.
//  Copyright (c) 2014 Honey Science Corporation. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedButton: RoundedButton {
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        self.layer.borderWidth = 1
        self.layer.borderColor = self.tintColor!.CGColor
    }
}
