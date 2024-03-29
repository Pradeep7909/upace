//
//  BoothListViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 11/03/24.
//

import UIKit
import SDWebImage

protocol ContainerViewHeightDelegate: AnyObject {
    func setContainerHeight(height : CGFloat)
}



class BoothListViewController: UIViewController {
    
    static var delegate : ContainerViewHeightDelegate?
    private var boothData : BoothResponse?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noBoothLabel: UILabel!
    
    
    //MARK: View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LOG("\(type(of: self)) viewDidLoad")
        tableView.contentInset.top = 10
        FirebaseManager.shared.delegate = self
        initializeView()
        getBooths()
    }
    
    //MARK: Functions
    
    private func initializeView(){
        //these is used for fetching booth data if it's already fetched one time for better user expereience
        if Singleton.shared.savedBoothList != nil{
            self.boothData = Singleton.shared.savedBoothList
            self.noBoothLabel.isHidden = self.boothData?.data.count ?? 0 > 0
            self.tableView.reloadData()
            let totalHeight = calculateTableViewHeight(for: self.tableView)
            BoothListViewController.delegate?.setContainerHeight(height: totalHeight)
        }
    }
    
    
    func getBooths(){
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_EVENT + U_BOOTH_UNIVERSITIES + (Singleton.shared.selectedEvent?.id ?? "") , method: .get, parameter: nil, objectClass: BoothResponse.self, requestCode: U_BOOTH_UNIVERSITIES) { response in
            guard let response = response else{
                LOG("Error in getting response")
                return
            }
            self.boothData =  response
            self.getQueueDetail()
        }
    }
    
    
    func getQueueDetail(){
        let url = U_BASE + U_QUEUE + "?event_id=\(Singleton.shared.selectedEvent?.id ?? "")" + "&user_id=\(Singleton.shared.currentUser?.id ?? "")"
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: QueueDetailResponse.self, requestCode: U_QUEUE) { response in
            guard let response = response else{
                LOG("Error in getting response")
                return
            }
            
            let queueData : QueueDetailResponse = response
            
            // Iterate through boothData using indices
            for i in 0..<(self.boothData?.data.count ?? 0) {
                if let foundIndex = queueData.data.firstIndex(where: { $0.university_id == self.boothData?.data[i].university_external_id }) {
                    // Use the index to update the status in boothData
                    self.boothData?.data[i].status = queueData.data[foundIndex].status
                    self.boothData?.data[i].token_number = queueData.data[foundIndex].token_number
                    self.boothData?.data[i].counsellor_id = queueData.data[foundIndex].counsellor_id
                    self.boothData?.data[i].queue_id = queueData.data[foundIndex].id
                }else{
                    self.boothData?.data[i].status = nil
                }
            }
            
            self.noBoothLabel.isHidden = self.boothData?.data.count ?? 0 > 0
            self.tableView.reloadData()
            let totalHeight = calculateTableViewHeight(for: self.tableView)
            print("Total height of table view: \(totalHeight)")
            Singleton.shared.savedBoothList = self.boothData
            BoothListViewController.delegate?.setContainerHeight(height: totalHeight)
        }
    }
}

extension BoothListViewController : FirebaseManagerDelegate{
    func queueUpdated() {
        getQueueDetail()
    }
}

//MARK: Table View
extension BoothListViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        boothData?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoothCell") as! BoothCell
        
        // here first check is already in queue
        
        let booth = boothData?.data[indexPath.row]
        cell.queueView.isHidden = true
        cell.completedView.isHidden = true
        cell.joinButtonView.isHidden = false
        
        cell.boothName.text = booth?.University.name
        cell.boothCIty.text = (booth?.University.city ?? "") + ", " + (booth?.University.country ?? "")
        
        if let encodedUrlString = booth?.University.bannerImage?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedUrlString) {
            cell.boothBannerImage.sd_setImage(with: url, placeholderImage: UIImage(named: "booth"))
        } else {
            print("Invalid URL string")
        }
        
        if booth?.status == "requested"{
            cell.joinButtonView.isHidden = true
            cell.queueView.isHidden = false
            cell.positionLabel.text = "\(booth?.token_number ?? 0)"
        }else if booth?.status == "completed"{
            cell.joinButtonView.isHidden = true
            cell.completedView.isHidden = false
        }else if booth?.status == "joined"{
            cell.joinButtonView.isHidden = false
            cell.joinButtonLabel.text = "Join Meeting Again"
        }
        
        cell.joinButtonClick = {
            
            if booth?.status == "joined"{
                
                
                let meetingJoinData : MeetingJoinData = MeetingJoinData(user: Singleton.shared.currentUser, event_id: booth?.event_id, university_id: booth?.university_external_id, counsellor_id: booth?.counsellor_id , queue_id: booth?.queue_id , university_name: booth?.University.name)
                
                let meetingData : MeetingJoinResponse = MeetingJoinResponse(data: meetingJoinData, title: "join", user_external_id: Singleton.shared.currentUser?.user_external_id)
                
                FirebaseManager.shared.currentMeeting = meetingData
                Singleton.shared.currentJoinMeeting = meetingData
                // Move to the meeting screen after joining the request
                NotificationCenter.default.post(name: .showMeetingViewController, object: nil)
                    
            }else{
                param = [
                    "event_id" : booth?.event_id ?? "" ,
                    "university_id" : booth?.university_external_id ?? "" ,
                ]
                
                SessionManager.shared.methodForApiCalling(url: U_BASE + U_QUEUE, method: .post, parameter: param, objectClass: QueueResponse.self, requestCode: U_QUEUE) { response in
                    guard let response = response else{
                        LOG("Error in getting response")
                        return
                    }
                    let popupVC = self.storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
                    popupVC.modalPresentationStyle = .overFullScreen
                    popupVC.popupType = .send
                    popupVC.tokenNumber = response.data?.token_number ?? 0
                    self.present(popupVC, animated: false, completion: nil)
                    
                    cell.joinButtonView.isHidden = true
                    cell.queueView.isHidden = false
                    cell.positionLabel.text = "\(response.data?.token_number ?? 0)"
                    
                    FirebaseManager.shared.sendNotification(type: "fetchQueue", queueData: response.data , meetingData: nil)
                }
            }
            
        }
        
        return cell
    }
}

//MARK: Tabel Cell
class BoothCell : UITableViewCell{
    
    @IBOutlet weak var boothBannerImage: UIImageView!
    @IBOutlet weak var boothLogoImage: CustomImage!
    @IBOutlet weak var boothName: UILabel!
    @IBOutlet weak var boothCIty: UILabel!
    @IBOutlet weak var joinButtonView: CustomView!
    @IBOutlet weak var queueView: UIView!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var completedView : UIView!
    @IBOutlet weak var joinButtonLabel: UILabel!
    
    var joinButtonClick: (()-> Void)? = nil
    
    @IBAction func joinButtonAction(_ sender: Any) {
        if let joinButtonClick = self.joinButtonClick {
            joinButtonClick()
        }
    }
    
}
