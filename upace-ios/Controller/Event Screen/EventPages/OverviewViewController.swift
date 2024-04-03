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
        let eventTitle = eventDetail?.title ?? ""
        let eventDescriptionText = NSLocalizedString("EventDescriptionText", comment: "")
        eventDescriptionLabel.text = String(format: eventDescriptionText, eventTitle, eventTitle)
        
    }
    
}
