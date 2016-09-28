//
//  MaterialTextField.swift
//  s11-showcase-app
//
//  Created by Lukasz Grela on 22.09.2016.
//  Copyright © 2016 Commelius Solutions Ltd. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {

    private var _topInset = CGFloat(0.0)
    private var _bottomInset = CGFloat(0.0)
    private var _leftInset = CGFloat(10.0)
    private var _rightInset = CGFloat(10.0)
    
    
    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        let color = SHADOW_COLOR.colorWithAlphaComponent(0.1)
        layer.borderColor = color.CGColor
        layer.borderWidth = 1.0
        
    }
    
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        
        var _bounds:CGRect = bounds
        
        _bounds.origin.x += self._leftInset;
        _bounds.origin.y += self._topInset;
        _bounds.size.width -= (self._leftInset+self._rightInset);
        _bounds.size.height -= (self._topInset+self._bottomInset);
        
        //print("textRectForBounds \(_bounds)")
        return _bounds;
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        var _bounds:CGRect = bounds
        
        
        _bounds.origin.x += self._leftInset;
        _bounds.origin.y += self._topInset;
        _bounds.size.width -= (self._leftInset+self._rightInset);
        _bounds.size.height -= (self._topInset+self._bottomInset);
        
        //print("editingRectForBounds \(_bounds)")
        
        return _bounds;
    }
    
    
    
    
    
    var topInset:CGFloat {
        get {
            return _topInset
        }
        set {
            
            _topInset = newValue
            
            self.setNeedsLayout()
        }
    }
    var bottomInset:CGFloat {
        get {
            return _bottomInset
        }
        set {
            
            _bottomInset = newValue
            
            self.setNeedsLayout()
        }
    }
    var leftInset:CGFloat {
        get {
            return _leftInset
        }
        set {
            
            _leftInset = newValue
            
            self.setNeedsLayout()
        }
    }
    var rightInset:CGFloat {
        get {
            return _rightInset
        }
        set {
            
            _rightInset = newValue
            
            self.setNeedsLayout()
        }
    }

}
