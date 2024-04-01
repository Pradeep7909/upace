//
//  SignupViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 06/03/24.
//

import UIKit

class SignupViewController: UIViewController {
    
    
    //MARK: IBOutlet
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var checkedImage: UIImageView!
    @IBOutlet weak var commonTopView: CommonTopView!
    
    @IBOutlet weak var nameTextField: CustomTextfieldView!
    @IBOutlet weak var emailTextField: CustomTextfieldView!
    @IBOutlet weak var numberTextField: CustomTextfieldView!
    @IBOutlet weak var passwordTextField: CustomTextfieldView!
    @IBOutlet weak var confirmPasswordTextField: CustomTextfieldView!
    
    
    
    
    //MARK: View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        LOG("\(type(of: self)) viewDidLoad")
        commonTopView.leftButton = {
            self.navigationController?.popViewController(animated: true)
        }
        textfieldSetup()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove keyboard notification observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: IBAction
    @IBAction func signupButtonAction(_ sender: UIButton) {
        if checkValidation(){
            param = [
                "name": nameTextField.textField.text ?? "" ,
                "email": emailTextField.textField.text ?? "" ,
                "google_id": "",
                "mobile_phone": numberTextField.textField.text ?? "",
                "profile_image": "",
                "password": passwordTextField.textField.text ?? "",
                "user_type": "student"
            ]
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_SIGNUP, method: .post, parameter: param, objectClass: LoginResponse.self, requestCode: U_SIGNUP) { response in
                
                guard let response = response else{
                    LOG("Error in getting response")
                    self.commonTopView.setProgressToZero()
                    return
                }
                print(response)
                Singleton.shared.setUser((response.data?.user)!)
                UserDefaults.standard.setValue(response.data?.token ?? "", forKey: UD_TOKEN)
            }
        }
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func googleButtonAction(_ sender: UIButton) {
        ToastManager.shared.showToast(message: "Login with google is not avaiable right now", type: .warning)
    }
    
    @IBAction func recieveUpdateButtonAction(_ sender: UIButton) {
        if checkedImage.image == UIImage(named: "checked") {
            checkedImage.image = UIImage(named: "unChecked")
        } else {
            checkedImage.image = UIImage(named: "checked")
        }
    }
    
    //MARK: Functions
    func checkValidation() -> Bool{
        var isValid = true
        if nameTextField.textField.text?.isEmpty == true{
            nameTextField.textFieldLabel.text = "Please enter your name"
            setViewRed(textField: nameTextField)
            isValid = false
        }
        if emailTextField.textField.text?.isEmpty == true {
            emailTextField.textFieldLabel.text = "Please enter email address"
            setViewRed(textField: emailTextField)
            isValid = false
        } else if !(emailTextField.textField.text?.isValidEmail ?? false) {
            emailTextField.textFieldLabel.text = "Please enter a valid email address"
            setViewRed(textField: emailTextField)
            isValid = false
        }
        
        if numberTextField.textField.text?.isEmpty == true {
            numberTextField.textFieldLabel.text = "Please enter phone number"
            setViewRed(textField: numberTextField)
            isValid = false
        }else if numberTextField.textField.text!.count != 10 {
            numberTextField.textFieldLabel.text = "Please enter a valid phone number"
            setViewRed(textField: numberTextField)
            isValid = false
        }
        
        if passwordTextField.textField.text?.isEmpty == true {
            passwordTextField.textFieldLabel.text = "Please enter password"
            setViewRed(textField: passwordTextField)
            isValid = false
        }else if passwordTextField.textField.text!.count < 8 {
            passwordTextField.textFieldLabel.text = "Password should be at least 8 characters"
            setViewRed(textField: passwordTextField)
        }
        
        if confirmPasswordTextField.textField.text?.isEmpty == true {
            confirmPasswordTextField.textFieldLabel.text = "Please re-enter password"
            setViewRed(textField: confirmPasswordTextField)
            isValid = false
        }else if confirmPasswordTextField.textField.text != passwordTextField.textField.text {
            confirmPasswordTextField.textFieldLabel.text = "Passwords do not match"
            setViewRed(textField: confirmPasswordTextField)
            isValid = false
        }
        return isValid
    }
    
    func setViewRed(textField : CustomTextfieldView){
        textField.textFieldLabel.textColor = .red
        textField.textFieldView.layer.borderWidth = 1
        textField.textFieldView.layer.borderColor = UIColor.red.withAlphaComponent(0.5).cgColor
        textField.textFieldView.backgroundColor = UIColor.red.withAlphaComponent(0.02)
    }
    
}

//MARK: TextField Control
extension SignupViewController : CustomTextfieldDelegate{
    
    
    func textfieldSetup(){
        hideKeyboardTappedAround()
        emailTextField.keyBoardType(keyboardType: .emailAddress)
        numberTextField.keyBoardType(keyboardType: .phonePad)
        nameTextField.delegate = self
        emailTextField.delegate = self
        numberTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func customTextfieldShouldReturn(_ textfield: CustomTextfieldView) -> Bool {
        self.switchBasedNextTextField(textfield)
        return true
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let activeField = CustomTextfieldView.activeTextField else {
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        mainScrollView.contentInset = contentInsets
        
        let textFieldRect = activeField.convert(activeField.bounds, to: mainScrollView)
        let offsetY = max(0, textFieldRect.maxY - mainScrollView.bounds.height + keyboardSize.height + 10)
        if offsetY > 0{
            mainScrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        mainScrollView.contentInset = .zero
        mainScrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    private func switchBasedNextTextField(_ textField: CustomTextfieldView) {
        switch textField {
        case self.nameTextField:
            self.emailTextField.textField.becomeFirstResponder()
        case self.emailTextField:
            self.numberTextField.textField.becomeFirstResponder()
        case self.numberTextField:
            self.passwordTextField.textField.becomeFirstResponder()
        case self.passwordTextField:
            self.confirmPasswordTextField.textField.becomeFirstResponder()
        default:
            self.confirmPasswordTextField.textField.resignFirstResponder()
        }
    }
}
