//
//  Designable.swift
//  upace-ios
//
//  Created by Qualwebs on 06/03/24.
//

import Foundation
import UIKit

@IBDesignable
class CustomView: CustomViewShadow{
    @IBInspectable  var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var topCornerRound: CGFloat = 0 {
        didSet{
            self.clipsToBounds = false
            self.layer.masksToBounds = false
            self.layer.cornerRadius = topCornerRound
            self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    @IBInspectable var isCircularRadius : Bool =  false{
        didSet{
            self.layer.cornerRadius = isCircularRadius ?  self.frame.height / 2  : 0
        }
    }
    
    @IBInspectable  var borderColor: UIColor = .black{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable  var borderWidth: CGFloat = 0 {
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
}

class CustomViewShadow : UIView{
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
            updateShadowPath()
        }
    }

    @IBInspectable var shadowColor: UIColor = .clear {
        didSet {
            self.layer.shadowColor = shadowColor.cgColor
            updateShadowPath()
        }
    }

    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            self.layer.shadowRadius = shadowRadius
            updateShadowPath()
        }
    }

    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            self.layer.shadowOffset = shadowOffset
            updateShadowPath()
        }
    }
    
    @IBInspectable var hideTopShadow: Bool = false {
           didSet {
               updateShadowPath()
           }
       }
    @IBInspectable var hideBottomShadow: Bool = false {
           didSet {
               updateShadowPath()
           }
       }
       
       override func layoutSubviews() {
           super.layoutSubviews()
           updateShadowPath()
       }
       
    private func updateShadowPath() {
        let path: UIBezierPath
        if hideTopShadow {
                path = UIBezierPath(roundedRect: bounds.insetBy(dx: shadowRadius, dy: shadowRadius), cornerRadius: layer.cornerRadius)
            } else if hideBottomShadow {
                path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - shadowRadius), cornerRadius: layer.cornerRadius)
            } else {
                path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
            }
        layer.shadowPath = path.cgPath
    }
}

@IBDesignable
class CustomImage: UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var topCornerRound: CGFloat = 0 {
        didSet{
            self.clipsToBounds = true
            self.layer.masksToBounds = true
            self.layer.cornerRadius = topCornerRound
            self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    
    @IBInspectable var circular: Bool = false {
        didSet {
            layer.cornerRadius = circular ? bounds.height / 2 : cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
}

