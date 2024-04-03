//
//  NotificationViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 28/03/24.
//

import UIKit

class NotificationViewController: UIViewController {
    
    @IBOutlet weak var commonTopView: CommonTopView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonTopView.titleText = NSLocalizedString("Notifications", comment: "")
        commonTopView.leftButton = {
            self.navigationController?.popViewController(animated: true)
        }

        // Do any additional setup after loading the view.
    }
    
}
