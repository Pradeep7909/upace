//
//  FAQViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 11/03/24.
//

import UIKit

class FAQViewController: UIViewController {

    let faqList: [FAQ] = [
        FAQ(question: NSLocalizedString("Which universities are participating?", comment: ""),
            answer: NSLocalizedString("A wide range of universities from around the world will be present, offering diverse academic programs and insights into their campuses.", comment: "")),
        
        FAQ(question: NSLocalizedString("Is there a registration fee?", comment: ""),
            answer: NSLocalizedString("Registration is free for all attendees, making it accessible to anyone interested in exploring educational opportunities.", comment: "")),
        
        FAQ(question: NSLocalizedString("How can I interact with university representatives?", comment: ""),
            answer: NSLocalizedString("You can chat live with representatives, schedule video calls, and explore virtual booths.", comment: "")),
        
        FAQ(question: NSLocalizedString("Are there informational sessions?", comment: ""),
            answer: NSLocalizedString("Yes, we offer sessions on admissions, careers, and more. Check the schedule for details.", comment: ""))
    ]

    
    var visibleFAQCell: FAQCell?
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
}


extension FAQViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        faqList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQCell") as! FAQCell
        let faq = faqList[indexPath.row]
        cell.answerLabel.isHidden = true
        cell.questionLabel.text = faq.question
        cell.answerLabel.text = faq.answer
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? FAQCell {
            
            if cell == visibleFAQCell{
                cell.answerLabel.isHidden = !cell.answerLabel.isHidden
                cell.chevronImage.image = UIImage(systemName: cell.answerLabel.isHidden ? "chevron.down" : "chevron.up")
                cell.contentView.layoutIfNeeded()
                tableView.beginUpdates()
                tableView.endUpdates()
                
                return
            }
            
            if let currentVisibleCell = visibleFAQCell {
                currentVisibleCell.answerLabel.isHidden = true
                currentVisibleCell.chevronImage.image = UIImage(systemName: "chevron.down" )
                currentVisibleCell.contentView.layoutIfNeeded()
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            
            
            visibleFAQCell = cell
            cell.answerLabel.isHidden = false
            cell.chevronImage.image = UIImage(systemName: "chevron.up")
            cell.contentView.layoutIfNeeded()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}

class FAQCell : UITableViewCell{
    
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var chevronImage: UIImageView!
    
}
