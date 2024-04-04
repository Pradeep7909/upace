//
//  HomeViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 07/03/24.
//

import UIKit
import RealmSwift

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
        print("Realm file path:", Realm.Configuration.defaultConfiguration.fileURL ?? "Not found")
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
        
    }
    
    
    //MARK: Functions
    func initializeView(){
        eventTypeView.isHidden = true
        eventTimeView.isHidden = true
    }
    
    
    func getEvents(){
        
        RealmManager.shared.fetchCachedEvent { [weak self] response in
            if let cachedResponse = response {
                let isEventActive = RealmManager.shared.compareEventTime(cachedResponse: cachedResponse)
                if isEventActive {
                    self?.handleEventResponse(response: cachedResponse)
                }
            }
        }

        // right now fetching on latest event if want all event then remove U_LATEST endpoint
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_EVENT +  U_LATEST , method: .get, parameter: nil, objectClass: EventResponse.self, requestCode: U_EVENT) { response in
            guard let response = response else{
                LOG("Error in getting response")
                return
            }
            
            // Save fetched data into Realm using RealmManager
            RealmManager.shared.saveEventData(response: response) { realmResponse in                self.handleEventResponse(response: realmResponse)
            }
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
    
    func handleEventResponse(response: RealmEventResponse) {
        if response.total == 0 {
            return
        }
        
        self.eventDetail = EventResponse(data: response.data.map { event in
            Event(id: event.id,
                  title: event.title,
                  type: event.type,
                  tag_line: event.tag_line,
                  event_date: event.event_date,
                  event_start_time: event.event_start_time,
                  event_end_time: event.event_end_time)
        }, total: response.total, totalPage: response.totalPage)
        
        // Update UI with the event details
        self.eventTypeView.isHidden = false
        self.eventTimeView.isHidden = false
        self.eventButtonLabel.text = "Join now"
        self.eventNameLabel.text = self.eventDetail?.data.first?.title
        self.staticLabel.text = self.eventDetail?.data.first?.tag_line
        self.eventDayLabel.text = formatDate(self.eventDetail?.data.first?.event_date ?? "")
        self.eventTimeLabel.text = (formatTime(self.eventDetail?.data.first?.event_start_time ?? "") ?? "") + " - " + (formatTime(self.eventDetail?.data.first?.event_end_time ?? "") ?? "")
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
