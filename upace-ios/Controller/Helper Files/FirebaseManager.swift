//
//  FirebaseManager.swift
//  upace-ios
//
//  Created by Qualwebs on 27/03/24.
//

import FirebaseCore
import FirebaseDatabase


protocol FirebaseManagerDelegate: AnyObject {
    func queueUpdated()
}

class FirebaseManager{
    
    static let shared = FirebaseManager()
    
    private var databaseRef: DatabaseReference!
    
    var currentMeeting : MeetingJoinResponse?
    
    var meetingActionCallback: ((MeetingJoinResponse) -> Void)?
    
    weak var delegate: FirebaseManagerDelegate?
    
    init() {
        // Listen for the notification to navigate to MeetingViewController
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToMeeting), name: .showMeetingViewController, object: nil)
    }
    
    deinit {
        // Remove observer when the FirebaseManager is deallocated
        NotificationCenter.default.removeObserver(self, name: .showMeetingViewController, object: nil)
    }
    
    func setupFirebaseObserver() {
        // Configure Firebase app
        LOG("Observer Set")
        guard FirebaseApp.app() != nil else {
            print("Firebase app is not configured.")
            return
        }
        
        // Reference the "actions" child node
        databaseRef = Database.database().reference().child("actions").child(Singleton.shared.currentUser?.user_external_id ?? "nil")
        
        // Observer for new child nodes added
        databaseRef.observe(.childAdded) { snapshot in
            if let key = snapshot.key as? String{
                print("Child Added- \(key)")
                self.handleFirebaseSnapshot(snapshot: snapshot)
                self.removeDatafromDatabase(key: key)
            } else {
                print("No data or key found for the new child.")
            }
        }
        
        // Observer for updated nodes
        databaseRef.observe(.childChanged) { snapshot in
            if let key = snapshot.key as? String{
                print("Child Changed- \(key)")
                self.handleFirebaseSnapshot(snapshot: snapshot)
                self.removeDatafromDatabase(key: key)
            } else {
                print("No data or key found for the updated node.")
            }
        }
    }
    
    func removeObservers() {
        databaseRef.removeAllObservers()
        print("Observers removed.")
    }
    
    func removeDatafromDatabase(key : String){
        databaseRef = Database.database().reference().child("actions").child(Singleton.shared.currentUser?.user_external_id ?? "nil").child(key)
        
        databaseRef.removeValue(){ error, _ in
            if let error = error {
                print("Error deleting child node: \(error.localizedDescription)")
            } else {
                print("Child node deleted successfully.")
            }
        }
    }
    
    func handleFirebaseSnapshot(snapshot: DataSnapshot) {
        guard let data = snapshot.value as? [String: Any] else {
            print("No data found in snapshot.")
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let decoder = JSONDecoder()
            
            // Decode the JSON data into your model
            let meetingJoinFirebaseResponse = try decoder.decode(MeetingJoinFirebaseResponse.self, from: jsonData)
            
            // Create a MeetingJoinResponse instance
            let meetingJoinResponse = MeetingJoinResponse(
                data: parseFirebaseMeetingData(data: meetingJoinFirebaseResponse.data ?? ""),
                title: meetingJoinFirebaseResponse.title,
                user_external_id: meetingJoinFirebaseResponse.user_external_id
            )
            print("original Data : \(data)")
            
            print("meetingJoinResponse : \(meetingJoinResponse)")
            
            if meetingJoinResponse.title == "joinAttendee"{
                currentMeeting = meetingJoinResponse
                showJoinPopup()
            }else if meetingJoinResponse.title == "muteAttendee"{
                meetingActionCallback?(meetingJoinResponse)
            }else if meetingJoinResponse.title == "stopVideoAttendee"{
                meetingActionCallback?(meetingJoinResponse)
            }else if meetingJoinResponse.title == "removeAttendee"{
                meetingActionCallback?(meetingJoinResponse)
            }else if meetingJoinResponse.title == "queue updated"{
                delegate?.queueUpdated()
            }
            
        } catch {
            print("Error decoding JSON: \(error.localizedDescription)")
        }
    }
    
    
    private func parseFirebaseMeetingData(data : String) -> MeetingJoinData?{
        
        let jsonString = """
    \(data)
    """
        // Convert JSON string to Data
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                // Decode JSON data into your model
                let decoder = JSONDecoder()
                let meetingJoinData = try decoder.decode(MeetingJoinData.self, from: jsonData)
                
                return meetingJoinData
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        } else {
            print("Failed to convert JSON string to Data.")
        }
        return nil
        
    }
    
    func showJoinPopup(){
        // Assuming your current view controller is a UIViewController subclass
        if let currentViewController = UIApplication.shared.keyWindow?.rootViewController {
            let popupVC = currentViewController.storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
            popupVC.modalPresentationStyle = .overFullScreen
            popupVC.popupType = .join
            
            if let existingPopupVC = currentViewController.presentedViewController as? PopupViewController {
                existingPopupVC.dismiss(animated: false) {
                    currentViewController.present(popupVC, animated: false, completion: nil)
                }
            } else {
                currentViewController.present(popupVC, animated: false, completion: nil)
            }
            
        } else {
            print("Failed to get current view controller.")
        }
    }
    
    @objc private func navigateToMeeting() {
        // Navigate to the MeetingViewController
        if let currentViewController = UIApplication.shared.keyWindow?.rootViewController {
            let meetingVC = currentViewController.storyboard?.instantiateViewController(withIdentifier: "MeetingViewController") as! MeetingViewController
            meetingVC.modalPresentationStyle = .overFullScreen
            currentViewController.present(meetingVC, animated: false)
        } else {
            print("Failed to get current view controller.")
        }
    }
    
    
    
    
    func sendNotification(type: String, queueData: QueueData?, meetingData : MeetingJoinData?) {
        
        if type == "deleteQueue"{
            param = [
                "type": type,
                "user_external_ids": [meetingData?.counsellor_id ?? "" ],
                "data": [
                    "university_id":  meetingData?.university_id ?? "",
                    "event_id": meetingData?.event_id ?? "",
                    "queue_id": meetingData?.queue_id ?? ""
                ]
            ]
        }else{
            let user : [String: Any] = [
                "id": Singleton.shared.currentUser?.id ?? "",
                "name": Singleton.shared.currentUser?.name ?? "",
                "fcm_token": Singleton.shared.currentUser?.fcm_token ?? "",
                "user_external_id": Singleton.shared.currentUser?.user_external_id ?? "",
                "email": Singleton.shared.currentUser?.email ?? "",
                "google_id": Singleton.shared.currentUser?.google_id ?? "",
                "mobile_phone": Singleton.shared.currentUser?.mobile_phone ?? "",
                "profile_image": Singleton.shared.currentUser?.profile_image ?? "",
                "email_verified_at": Singleton.shared.currentUser?.email_verified_at ?? "",
                "phone_verified_at": Singleton.shared.currentUser?.phone_verified_at ?? "",
                "status": Singleton.shared.currentUser?.status ?? "",
                "user_type": Singleton.shared.currentUser?.user_type ?? "",
                "password_generated": Singleton.shared.currentUser?.password_generated ?? false,
                "referral_code": Singleton.shared.currentUser?.referral_code ?? "",
                "referred_by_user_id": Singleton.shared.currentUser?.referred_by_user_id ?? "",
                "createdAt": Singleton.shared.currentUser?.createdAt ?? "",
                "updatedAt": Singleton.shared.currentUser?.updatedAt ?? ""
            ]
            
            let newData : [String : Any] =
            [
                "id": queueData?.id ?? "",
                "university_id": queueData?.university_id ?? "",
                "user_id": queueData?.user_id ?? "",
                "token_number": queueData?.token_number ?? 0,
                "event_id": queueData?.event_id ?? "",
                "counsellor_id": queueData?.counsellor_id ?? "",
                "invigilator_id": queueData?.invigilator_id ?? "",
                "status": queueData?.status ?? "",
                "updatedAt": queueData?.updatedAt ?? "",
                "createdAt": queueData?.createdAt ?? "",
                "User": user
            ]
            
            
            // Create the data dictionary
            let data: [String: Any] = [
                "university_id": queueData?.university_id ?? "",
                "event_id": queueData?.event_id ?? "",
                "appendData": newData
            ]
            
            
            let counsellorId = queueData?.counsellor_id ?? ""
            
            param = [
                "type": type,
                "user_external_ids": [counsellorId],
                "data": data
            ]
        }
        
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_SEND_NOTIFICATION , method: .post, parameter: param, objectClass: SuccessResponse.self, requestCode: U_SEND_NOTIFICATION) { response in
            guard let response = response else{
                LOG("Error in getting response")
                return
            }
            
            LOG("Notifaction send successfully to counsellor to update queue")
            
        }
    }
    
}


extension Notification.Name {
    static let showMeetingViewController = Notification.Name("ShowMeetingViewController")
}
