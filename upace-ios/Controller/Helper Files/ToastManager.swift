//
//  ToastManager.swift
//  upace-ios
//
//  Created by Qualwebs on 07/03/24.
//

import Foundation
import UIKit
import UIKit

enum Type {
    case success
    case warning
    case error
}

class ToastManager {
    static let shared = ToastManager() // Singleton instance
    
    private var currentToastView: UIView? // Keep track of the current toast view
    
    private init() {} // Ensure singleton
    
    
    func showToast(message: String, type: Type) {
        guard let topViewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        let backgroundColor : UIColor = type == .error ? .systemRed : ( type == .success ? .systemGreen : .systemYellow )
        let iconImage: UIImage? = UIImage(named: type == .success ? "success" : "error" )
        // Remove the current toast view if it exists
        currentToastView?.removeFromSuperview()
        
        // Calculate initial and final positions
        let initialY: CGFloat =  -100
        var finalY: CGFloat = 20
        if let safeAreaTop = UIApplication.shared.windows.first?.safeAreaInsets.top {
            finalY = safeAreaTop + 20 // Move up 50 units from the safe area top
        }
        
        // Create toast view
        let screenWidth = topViewController.view.frame.width
        let toastViewWidth = screenWidth * 0.8
        var toastViewHeight: CGFloat = 50 // Default height
        let toastViewX = (topViewController.view.frame.size.width - toastViewWidth) / 2
        let toastView = UIView(frame: CGRect(x: toastViewX, y: initialY, width: toastViewWidth, height: toastViewHeight))
        
        // Set toast background color to systemBackground
        toastView.backgroundColor = backgroundColor
        
        toastView.layer.cornerRadius = 10
        toastView.clipsToBounds = false // Allow the shadow to be visible
        
        // Add shadow
        toastView.layer.shadowColor = UIColor.black.cgColor
        toastView.layer.shadowOpacity = 0.5
        toastView.layer.shadowOffset = CGSize(width: 0, height: 0)
        toastView.layer.shadowRadius = 5
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        toastView.addGestureRecognizer(tapGesture)
        
        topViewController.view.addSubview(toastView)
       
        // Create toast label
        let toastLabelPadding: CGFloat = 10
        let toastLabelWidth = toastViewWidth - (2 * toastLabelPadding)
        let toastLabel = UILabel(frame: CGRect(x: toastLabelPadding, y: (toastViewHeight - 20) / 2, width: toastLabelWidth, height: 20))
        toastLabel.backgroundColor = .clear
        toastLabel.textColor = .white
        toastLabel.textAlignment = .left
        toastLabel.font = UIFont(name: "Nunito", size: 16.0)
        toastLabel.numberOfLines = 0  // Allow multiline text
        toastLabel.text = message
        toastView.addSubview(toastLabel)
        
        
        
        // Calculate label height based on the message content
        let labelSize = toastLabel.sizeThatFits(CGSize(width: toastLabelWidth - 40 , height: CGFloat.greatestFiniteMagnitude))
        let toastLabelHeight = labelSize.height
        toastLabel.frame.size.height = toastLabelHeight
        
        // Update toast view height based on label height
        toastViewHeight = max(toastViewHeight, toastLabelHeight + (2 * toastLabelPadding))
        toastView.frame.size.height = toastViewHeight
        
        // Center the label vertically within the toast view
        toastLabel.frame.origin.y = (toastViewHeight - toastLabelHeight) / 2
        
        // Add icon image
        if let iconImage = iconImage {
            let iconImageView = UIImageView(image: iconImage)
            iconImageView.frame = CGRect(x: toastLabelPadding, y: (toastViewHeight - 30) / 2, width: 30, height: 30)
            toastView.addSubview(iconImageView)
            
            // Adjust label origin x to make space for the icon
            toastLabel.frame.origin.x += 40
            toastLabel.frame.size.width -= 40
        }
        
        // Animate toast view
        UIView.animate(withDuration: 0.5, animations: {
            toastView.frame.origin.y = finalY // Move
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIView.animate(withDuration: 0.5, animations: {
                    toastView.frame.origin.y = initialY // Move
                }, completion: { _ in
                    toastView.removeFromSuperview()
                })
            }
        }
        
        // Set the current toast view
        currentToastView = toastView
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let toastView = sender.view else { return }
        
        // Remove all pending animations
        toastView.layer.removeAllAnimations()
        
        // Calculate the initial and final positions for the toast view
        let initialY = toastView.frame.origin.y
        let finalY = -100 - toastView.frame.size.height // Move above the screen
        
        // Animate the toast view moving up
        UIView.animate(withDuration: 0.5, animations: {
            toastView.frame.origin.y = finalY
        }) { _ in
            // Remove the toast view from the superview after the animation completes
            toastView.removeFromSuperview()
        }
    }

}
