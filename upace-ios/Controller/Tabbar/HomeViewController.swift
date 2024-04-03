//
//  HomeViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 07/03/24.
//

import UIKit

class HomeViewController: UIViewController {

    private var eventDetail : EventResponse?
    

    //MARK: IBOutlets
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var staticLabel: UILabel!
    @IBOutlet weak var eventTypeView: UIView!
    @IBOutlet weak var eventTimeView: UIView!
    
    @IBOutlet weak var eventDayLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventButtonLabel: UILabel!
    
    //MARK: ViewCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        LOG("\(type(of: self)) viewDidLoad")
        // Do any additional setup after loading the view.
        initializeView()
        getEvents()
    }
    
    
    //MARK: IBActions
    @IBAction func eventButtonAction(_ sender: Any) {
        print("🌟eventDetail?.total \(eventDetail?.total ?? 0)" )
        
        if eventDetail?.total == nil || eventDetail?.total == 0{
            emailSubscribe()
        }else{
            Singleton.shared.selectedEvent =  eventDetail?.data[0]
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SingleEventViewController") as! SingleEventViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func viewAllArticlesButton(_ sender: Any) {
        
        let popupVC = self.storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.popupType = .send
        present(popupVC, animated: false, completion: nil)
    }
    
    
    //MARK: Functions
    func initializeView(){
        eventTypeView.isHidden = true
        eventTimeView.isHidden = true
    }
    
    
    func getEvents(){
        
        // right now fetching on latest event if want all event then remove U_LATEST endpoint
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_EVENT /*+ U_LATEST*/ , method: .get, parameter: nil, objectClass: EventResponse.self, requestCode: U_EVENT) { response in
            guard let response = response else{
                LOG("Error in getting response")
                return
            }
            if response.total == 0 {
                return
            }
            self.eventDetail = response
            self.eventTypeView.isHidden = false
            self.eventTimeView.isHidden = false
            
            self.eventButtonLabel.text = "Join now"
            self.eventNameLabel.text = self.eventDetail?.data[0].title
            self.staticLabel.text = self.eventDetail?.data[0].tag_line
            self.eventDayLabel.text = formatDate(self.eventDetail?.data[0].event_date ?? "")
            self.eventTimeLabel.text = (formatTime(self.eventDetail?.data[0].event_start_time ?? "") ?? "") + " - " + (formatTime(self.eventDetail?.data[0].event_end_time ?? "") ?? "")
        
        }
    }
    
    func emailSubscribe(){
        param = [
            "email" : Singleton.shared.currentUser?.email ?? "",
            "name" : Singleton.shared.currentUser?.name ?? ""
        ]
        
        SessionManager.shared.methodForApiCalling(url: U_BASE_MAIN + U_EMAIL_SUBSCRIBE, method: .post, parameter: param, objectClass: SubscriptionResponse.self, requestCode: U_EVENT) { response in
            guard response != nil else{
                LOG("Error in getting response")
                return
            }
            ToastManager.shared.showToast(message: "Subscribed Successfully", type: .success)
        }
    }
}

//MARK: Collection View
extension HomeViewController:  UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        cell.articleImageWidth.constant = view.frame.width * 0.9 - 50
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 50) , height: 275 )
    }
}


//MARK: Article Cell
class ArticleCell: UICollectionViewCell {

    @IBOutlet weak var articleImageWidth: NSLayoutConstraint!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var ArticleTitleLabel: UILabel!
    @IBOutlet weak var articleTimeLabel: UILabel!
    
}
