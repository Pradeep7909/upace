//
//  Extensions.swift
//  upace-ios
//
//  Created by Qualwebs on 06/03/24.
//

import Foundation
import UIKit

extension UIViewController{
    func hideKeyboardTappedAround(){
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}


extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}


// Extension to set the language for the main bundle
extension Bundle {
    static func setLanguage(_ languageCode: String) {
        var onceToken : Int = 0
        if(onceToken == 0){
            object_setClass(Bundle.main, PrivateBundle.self)
        }
        onceToken = 1
        objc_setAssociatedObject(Bundle.main, &asscoiatedLanguageBundle ,Bundle(path: Bundle.main.path(forResource: languageCode, ofType: "lproj") ?? "") , .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private var asscoiatedLanguageBundle:Character = "0"

class PrivateBundle : Bundle{
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle : Bundle? = objc_getAssociatedObject(self, &asscoiatedLanguageBundle) as? Bundle
        return (bundle != nil) ? (bundle!.localizedString(forKey: key, value: value, table: tableName)) : super.localizedString(forKey: key, value: value, table: tableName)
    }
}
