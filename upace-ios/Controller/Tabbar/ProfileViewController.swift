//
//  ProfileViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 07/03/24.
//

import UIKit

class ProfileViewController: UIViewController {

    
    private var userDetail : UserDetail?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var nameLabelTop: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LOG("\(type(of: self)) viewDidLoad")
        // Do any additional setup after loading the view.
        userDetail = Singleton.shared.currentUser
        initializeView()
        
    }
    
    func initializeView(){
        nameLabel.text = userDetail?.name
        emailLabel.text = userDetail?.email
        numberLabel.text = userDetail?.mobile_phone
        nameLabelTop.text = userDetail?.name
    }
    

}

