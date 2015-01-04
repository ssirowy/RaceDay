//
//  RoundedButton.swift
//  Milk
//
//  Created by Dick Fickling on 7/24/14.
//  Copyright (c) 2014 Honey Science Corporation. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
        super.drawRect(rect)
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
    }
}
