//
//  CustomTextfieldView.swift
//  upace-ios
//
//  Created by Qualwebs on 09/03/24.
//

import UIKit

protocol CustomTextfieldDelegate: AnyObject {
    func customTextfieldShouldReturn(_ textfield: CustomTextfieldView) -> Bool
}

@IBDesignable
class CustomTextfieldView: UIView {
    
    weak var delegate: CustomTextfieldDelegate?
    static var activeTextField: UITextField?
    private var titleLeadingConstraint : CGFloat?
    private var hasUpdatedConstraints = false
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var eyeImage: UIImageView!
    @IBOutlet weak var textFieldLabel: UILabel!
    @IBOutlet weak var textFieldView: CustomView!
    
    @IBOutlet weak var mobileNumberView: UIView!
    @IBOutlet weak var eyeView: UIView!
    
    @IBOutlet weak var textFieldLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldLabelVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    
    @IBInspectable var hideEyeView: Bool = true {
        didSet {
            eyeView.isHidden = hideEyeView
            textField.isSecureTextEntry = !hideEyeView
        }
    }
    
    @IBInspectable var hideNumberView: Bool = true {
        didSet {
            mobileNumberView.isHidden = hideNumberView
        }
    }
    
    @IBInspectable var textFieldLabelText: String = "Text field" {
        didSet {
            textFieldLabel.text = textFieldLabelText
        }
    }
    
    @IBAction func eyeButtonAction(_ sender: UIButton) {
        textField.isSecureTextEntry = !textField.isSecureTextEntry
        eyeImage.image = UIImage(named: textField.isSecureTextEntry ? "eyeSlash" : "eye" )
        
    }
    
    
    //MARK: Initial setup
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomTextfieldView", bundle: bundle)
        if let contentView = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            addSubview(contentView)
            contentView.frame = bounds
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        textField.delegate = self
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !hasUpdatedConstraints {
            textFieldLabelLeadingConstraint.constant = mobileNumberView.isHidden ? 10  : 55
            titleLeadingConstraint = textFieldLabelLeadingConstraint.constant
            hasUpdatedConstraints = true
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    func keyBoardType(keyboardType : UIKeyboardType){
        textField.keyboardType = keyboardType
    }

}


extension CustomTextfieldView : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textFieldLabel.text == textFieldLabelText { return true }
        textFieldLabel.text = textFieldLabelText
        textFieldLabel.textColor = .K_DARK_GREY
        textFieldView.layer.borderWidth = 0
        textFieldView.backgroundColor = .systemGray6
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.customTextfieldShouldReturn(self) ?? true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        CustomTextfieldView.activeTextField = textField
        if textField.text == "" {
            UIView.animate(withDuration: 0.2) {
                self.textFieldLabelLeadingConstraint.constant = 10
                self.textFieldLabelVerticalConstraint.constant = -32.5 // 45/2 + 20/2 for showing above
                self.heightConstraint.constant = 65
                self.layoutIfNeeded()
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        CustomTextfieldView.activeTextField = nil
        if textField.text == "" {
            UIView.animate(withDuration: 0.2) {
                self.textFieldLabelLeadingConstraint.constant = self.titleLeadingConstraint ?? 20
                self.textFieldLabelVerticalConstraint.constant = 0
                self.heightConstraint.constant = 45
                self.layoutIfNeeded()
            }
        }
    }
}
