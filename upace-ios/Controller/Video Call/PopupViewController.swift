//
//  PopupViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 19/03/24.
//

import UIKit

class PopupViewController: UIViewController {
    
    //MARK: Variables
    var popupType : PopupType = .join
    var tokenNumber : Int = 1
    var countdownTimer: Timer?
    var secondsRemaining = 60
    
    @IBOutlet weak var greetUserLabel: UILabel!
    @IBOutlet weak var aboutPopLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var universityNameLabel: UILabel!
    @IBOutlet weak var joinButtonLabel: UILabel!
    @IBOutlet weak var waitingLabel: UILabel!
    @IBOutlet weak var centerColorView: CustomView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var notInterestedView: UIView!
    @IBOutlet weak var queueNumberLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeView()
    }
    
    
    func initializeView(){
        greetUserLabel.text = "Hii \(Singleton.shared.currentUser?.name ?? "")"
        if popupType == .join{
            aboutPopLabel.text = "Your turn is here, Join now!"
            positionLabel.text = "Join in 50s or your queue will be shifted."
            universityNameLabel.text = "University Name"
            queueNumberLabel.isHidden = true
            updateDynamicText()
            countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDynamicText), userInfo: nil, repeats: true)
            
        }else{
            aboutPopLabel.text = "Thank you for applying"
            positionLabel.text = "Your Positon in queue"
            queueNumberLabel.text = "\(tokenNumber)"
            universityNameLabel.isHidden = true
            joinButtonLabel.text = "Thank you"
            waitingLabel.text = "The average session duration is 5 min. We will notify you as soon as its your turn to participate."
            imageView.isHidden = true
            centerColorView.backgroundColor = .systemOrange
            notInterestedView.isHidden = true
            
        }
    }
    
    
    
    //MARK: IBActions
    @IBAction func joinButtonAction(_ sender: UIButton) {
        
        if popupType == .join{
            // join the request and move to meeting screen
        }else{
            self.dismiss(animated: false)
        }
        
    }
    
    
    @IBAction func notInterestedButton(_ sender: Any) {
        
        notInterestedToJoin()
        
    }
    
    
    //MARK: Functions
    @objc func updateDynamicText() {
        let dynamicText = "Join in \(secondsRemaining)s or your queue will be shifted."
        
        let attributedString = NSMutableAttributedString(string: dynamicText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: attributedString.length))
        
        // Add custom attribute for dynamic text color
        let dynamicTextColor = UIColor.orange
        let dynamicTextRange = (dynamicText as NSString).range(of: "\(secondsRemaining)s")
        attributedString.addAttribute(.foregroundColor, value: dynamicTextColor, range: dynamicTextRange)
        positionLabel.attributedText = attributedString
        
        // Decrease the seconds remaining
        secondsRemaining -= 1
        
        // Check if the countdown is complete
        if secondsRemaining < 0 {
            countdownTimer?.invalidate()
            notInterestedToJoin()
        }
    }
    
    private func notInterestedToJoin(){
        self.dismiss(animated: false)
    }

}


//MARK: Enum
enum PopupType{
    case send
    case join
}
