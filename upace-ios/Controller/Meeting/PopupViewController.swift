//
//  PopupViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 19/03/24.
//

import UIKit
import AudioToolbox
import AVFoundation

class PopupViewController: UIViewController {
    
    //MARK: Variables
    var popupType : PopupType = .join
    var tokenNumber : Int = 1
    private var countdownTimer: Timer?
    private var secondsRemaining = 60
    private var meetingData : MeetingJoinResponse?
    var navigateToMeetingCallback: (() -> Void)?
    var audioPlayer: AVAudioPlayer?
    var generator: UIImpactFeedbackGenerator?
    var vibrationTimer: Timer?
    
    
    
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
    
    
    
    
    //MARK: IBActions
    @IBAction func joinButtonAction(_ sender: UIButton) {
        
        if popupType == .join{
            // join the request and move to meeting screen
            joinRequest()
            stopEffects()
            
        }else{
            self.dismiss(animated: false)
        }
        
    }
    
    
    @IBAction func notInterestedButton(_ sender: Any) {
        notInterestedToJoin()
    }
    
    
    //MARK: Functions
    
    
    private func initializeView(){
        // Localized greeting text
        let greetingText = NSLocalizedString("GreetUserLabel", comment: "")
        greetUserLabel.text = String(format: greetingText, Singleton.shared.currentUser?.name ?? "")
        
        if popupType == .join{
            self.meetingData = FirebaseManager.shared.currentMeeting
            aboutPopLabel.text = NSLocalizedString("AboutPopLabelJoin", comment: "")
            positionLabel.text = NSLocalizedString("PositionLabelJoin", comment: "")
            universityNameLabel.text = meetingData?.data?.university_name
            queueNumberLabel.isHidden = true
            updateDynamicText()
            countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDynamicText), userInfo: nil, repeats: true)
            playJoinSoundAndVibrate()
            
        }else{
            
            
            
            aboutPopLabel.text = NSLocalizedString("AboutPopLabelApply", comment: "")
            positionLabel.text = NSLocalizedString("PositionLabelApply", comment: "")
            queueNumberLabel.text = "\(tokenNumber)"
            universityNameLabel.isHidden = true
            joinButtonLabel.text = NSLocalizedString("JoinButtonLabel", comment: "")
            waitingLabel.text = NSLocalizedString("WaitingLabel", comment: "")
            imageView.isHidden = true
            centerColorView.backgroundColor = .systemOrange
            notInterestedView.isHidden = true
            vibrateDeviceOneTime()
        }
    }
    
    
    private func playJoinSoundAndVibrate() {
        guard let soundURL = Bundle.main.url(forResource: "call", withExtension: "mp3") else {
            print("Failed to load join sound.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            // Start vibration
            generator = UIImpactFeedbackGenerator(style: .heavy)
            generator?.prepare()
            startVibration()
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
        }
    }
    
    private func startVibration() {
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.generator?.impactOccurred()
        }
    }
    
    // for stop vibrate and sound
    private func stopEffects() {
        generator = nil
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
    
    
    
    
    private func vibrateDeviceOneTime() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    
    
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
            notInterestedToJoin()
        }
    }
    
    
    private func notInterestedToJoin(){
        self.dismiss(animated: false)
        countdownTimer?.invalidate()
        stopEffects()
        
        print("queue id \(meetingData?.data?.queue_id ?? "")")
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_QUEUE + "/\(meetingData?.data?.queue_id ?? "")" , method: .delete ,parameter: nil, objectClass: LoginResponse.self, requestCode: U_QUEUE) { response in
            guard response != nil else{
                LOG("Error in getting response")
                return
            }
            print("Successfully delete queue")
            FirebaseManager.shared.sendNotification(type: "deleteQueue", queueData: nil, meetingData: self.meetingData?.data)
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
