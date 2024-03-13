//
//  OverviewViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 11/03/24.
//

import UIKit

class OverviewViewController: UIViewController {
    
    private var eventDetail : Event?
    
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initializeView()
    }
    
    private func initializeView(){
        eventDetail = Singleton.shared.selectedEvent!
        self.eventDateLabel.text = formatDate(self.eventDetail?.event_date ?? "")
        self.eventTimeLabel.text = (formatTime(self.eventDetail?.event_start_time ?? "") ?? "") + " - " + (formatTime(self.eventDetail?.event_end_time ?? "") ?? "")
        eventDescriptionLabel.text = "Join us at the \(eventDetail?.title ?? "Event"), a premier academic fair designed to connect students with top universities worldwide. Explore booths from leading institutions, discover exciting academic programs, and engage with university representatives. Whether you're exploring undergraduate or graduate opportunities, the \(eventDetail?.title ?? "Event") offers valuable insights and networking opportunities to kickstart your academic journey."
        
    }
    

}
