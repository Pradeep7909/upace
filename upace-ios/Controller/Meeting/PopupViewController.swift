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
    var meetingData : MeetingJoinResponse?
    var navigateToMeetingCallback: (() -> Void)?
    
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
            self.meetingData = FirebaseManager.shared.currentMeeting
            aboutPopLabel.text = "Your turn is here, Join now!"
            positionLabel.text = "Join in 59s or your queue will be shifted."
            universityNameLabel.text = meetingData?.data?.university_name
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
            joinRequest()
            
        }else{
            self.dismiss(animated: false)
        }
    }
    
    
    @IBAction func notInterestedButton(_ sender: Any) {
        notInterestedToJoin()
    }
    
    
    //MARK: Functions
    @objc private func updateDynamicText() {
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
        countdownTimer?.invalidate()
        
        print("queue id \(meetingData?.data?.queue_id ?? "")")
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_QUEUE + "/\(meetingData?.data?.queue_id ?? "")" , method: .delete ,parameter: nil, objectClass: LoginResponse.self, requestCode: U_QUEUE) { response in
            guard response != nil else{
                LOG("Error in getting response")
                return
            }
            print("Successfully delete queue")
            FirebaseManager.shared.delegate?.queueUpdated()
        }
    }
    
    private func joinRequest(){
        param = [
            "counsellor_id": meetingData?.data?.counsellor_id ?? "",
            "event_id": meetingData?.data?.event_id ?? "",
            "status": "joined",
            "user_id": meetingData?.data?.user?.user_external_id ?? ""
        ]
        
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_QUEUE + "/user" , method: .patch , parameter: param, objectClass: LoginResponse.self, requestCode: U_QUEUE) { response in
            guard response != nil else{
                LOG("Error in getting response")
                return
            }
            self.countdownTimer?.invalidate()
            Singleton.shared.currentJoinMeeting = self.meetingData
            
            self.dismiss(animated: false) {
                // Move to the meeting screen after joining the request
                NotificationCenter.default.post(name: .showMeetingViewController, object: nil)
            }
        }
    }
    
}


//MARK: Enum
enum PopupType{
    case send
    case join
}
