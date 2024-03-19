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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LOG("\(type(of: self)) viewDidLoad")
        tableView.contentInset.top = 10
        getBooths()
    }
    
    func getBooths(){
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_EVENT + U_BOOTH_UNIVERSITIES + (Singleton.shared.selectedEvent?.id ?? "") , method: .get, parameter: nil, objectClass: BoothResponse.self, requestCode: U_BOOTH_UNIVERSITIES) { response in
            guard let response = response else{
                LOG("Error in getting response")
                return
            }
            self.boothData =  response
            self.noBoothLabel.isHidden = self.boothData?.data.count ?? 0 > 0
            self.tableView.reloadData()
            let totalHeight = calculateTableViewHeight(for: self.tableView)
            print("Total height of table view: \(totalHeight)")
            BoothListViewController.delegate?.setContainerHeight(height: totalHeight)
        }
    }
}

extension BoothListViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        boothData?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoothCell") as! BoothCell
        
        // here first check is already in queue
        
        let booth = boothData?.data[indexPath.row]
        print("🚀booth : \(String(describing: booth))")
        cell.queueView.isHidden = true
        
        cell.boothName.text = booth?.University.name
        cell.boothCIty.text = (booth?.University.city ?? "") + ", " + (booth?.University.country ?? "")
        
        if let encodedUrlString = booth?.University.bannerImage?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedUrlString) {
            cell.boothBannerImage.sd_setImage(with: url, placeholderImage: UIImage(named: "booth"))
        } else {
            print("Invalid URL string")
        }
        
        cell.joinButtonClick = {
            
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
                
                
            }
            
            
        }
      
        return cell
    }
    
}

class BoothCell : UITableViewCell{
    
    @IBOutlet weak var boothBannerImage: UIImageView!
    @IBOutlet weak var boothLogoImage: CustomImage!
    @IBOutlet weak var boothName: UILabel!
    @IBOutlet weak var boothCIty: UILabel!
    @IBOutlet weak var joinButtonView: CustomView!
    @IBOutlet weak var queueView: UIView!
    @IBOutlet weak var positionLabel: UILabel!
    
    var joinButtonClick: (()-> Void)? = nil
    
    @IBAction func joinButtonAction(_ sender: Any) {
        if let joinButtonClick = self.joinButtonClick {
            joinButtonClick()
        }
    }

}
