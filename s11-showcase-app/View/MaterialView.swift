//
//  MaterialView.swift
//  s11-showcase-app
//
//  Created by Lukasz Grela on 22.09.2016.
//  Copyright © 2016 Commelius Solutions Ltd. All rights reserved.
//

import UIKit

class MaterialView: UIView {


    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.shadowColor = SHADOW_COLOR.CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    }

}
