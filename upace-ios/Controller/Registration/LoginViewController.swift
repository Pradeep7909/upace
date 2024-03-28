//
//  LoginViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 06/03/24.
//

import UIKit

class LoginViewController: UIViewController {

    
    //MARK: IBOutlet

    @IBOutlet weak var commonTopView: CommonTopView!
    @IBOutlet weak var loginButtonView: CustomView!
    @IBOutlet weak var emailTextField: CustomTextfieldView!
    @IBOutlet weak var passwordTextField: CustomTextfieldView!
    
    //MARK: View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        LOG("\(type(of: self)) viewDidLoad")
        intitializeView()
        textfieldSetup()
    }
    
    //MARK: IBAction
    @IBAction func forgetPasswordAction(_ sender: UIButton) {
       //not in use right now
        
    }
    

    @IBAction func loginButtonAction(_ sender: UIButton) {
        if checkValidation(){
            commonTopView.setProgress(0.95, duration: 3)
            loginButtonView.backgroundColor = K_BLUE_COLOR.withAlphaComponent(0.5)
            loginButtonView.isUserInteractionEnabled = false
            
            param = [
                "email": emailTextField.textField.text ?? "" ,
                "password": passwordTextField.textField.text ?? "",
                "google_id": ""
            ]
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_LOGIN, method: .post, parameter: param, objectClass: LoginResponse.self, requestCode: U_LOGIN) { response in
                guard let response = response else{
                    LOG("Error in getting response")
                    self.commonTopView.setProgressToZero()
                    self.loginButtonView.backgroundColor = K_BLUE_COLOR
                    self.loginButtonView.isUserInteractionEnabled = true
                    return
                }
                Singleton.shared.setUser((response.data?.user)!)
                UserDefaults.standard.setValue(response.data?.token ?? "", forKey: UD_TOKEN)
                self.loginButtonView.backgroundColor = K_BLUE_COLOR
                self.loginButtonView.isUserInteractionEnabled = true
                let vc = self.storyboard?.instantiateViewController(identifier: "MainViewController") as! MainViewController
                self.navigationController?.pushViewController(vc, animated: false)
                self.commonTopView.setProgressToZero()
            }
        }
    }
    
    
    @IBAction func signupButtonAction(_ sender: UIButton) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func googleButtonAction(_ sender: UIButton) {
        
        ToastManager.shared.showToast(message: "Login with google is not avaiable right now", type: .success)
    }
    
    
    //MARK: Fucntions
    private func intitializeView(){
        
    }
    
    func checkValidation() -> Bool{
        var isValid = true
        if emailTextField.textField.text?.isEmpty == true {
            emailTextField.textFieldLabel.text = "Please enter email address"
            setViewRed(textField: emailTextField)
            isValid = false
        } else if !(emailTextField.textField.text?.isValidEmail ?? false) {
            emailTextField.textFieldLabel.text = "Please enter a valid email address"
            setViewRed(textField: emailTextField)
            isValid = false
        }
        
        if passwordTextField.textField.text?.isEmpty == true {
            passwordTextField.textFieldLabel.text = "Please enter password"
            setViewRed(textField: passwordTextField)
            isValid = false
        }else if passwordTextField.textField.text!.count < 8 {
            passwordTextField.textFieldLabel.text = "Password should be at least 8 characters"
            setViewRed(textField: passwordTextField)
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
extension LoginViewController : CustomTextfieldDelegate{
    
    func textfieldSetup(){
        hideKeyboardTappedAround()
        emailTextField.keyBoardType(keyboardType: .emailAddress)
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func customTextfieldShouldReturn(_ textfield: CustomTextfieldView) -> Bool {
        self.switchBasedNextTextField(textfield)
        return true
    }

    private func switchBasedNextTextField(_ textField: CustomTextfieldView) {
        switch textField {
        case self.emailTextField:
            self.passwordTextField.textField.becomeFirstResponder()
        default:
            self.passwordTextField.textField.resignFirstResponder()
        }
    }
}
