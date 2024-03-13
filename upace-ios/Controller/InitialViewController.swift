//
//  InitialViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 08/03/24.
//

import UIKit

class InitialViewController: UIViewController {

    private var viewdidLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setScreen()
    }
    
    func setScreen() {
        if Singleton.shared.currentUser != nil {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
}
