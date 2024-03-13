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
        
        // Do any additional setup after loading the view.
        
        
        // here first check is already in queue
        
        let booth = boothData?.data[indexPath.row]
        print("🚀booth : \(booth)")
        cell.queueView.isHidden = true
        
        cell.boothName.text = booth?.University.name
        cell.boothCIty.text = (booth?.University.city ?? "") + ", " + (booth?.University.country ?? "")
        
        if let encodedUrlString = booth?.University.bannerImage?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedUrlString) {
            cell.boothBannerImage.sd_setImage(with: url, placeholderImage: UIImage(named: "booth"))
        } else {
            print("Invalid URL string")
        }
//        cell.boothLogoImage.sd_setImage(with: URL(string: booth?.University.logo ?? "" ), placeholderImage: UIImage(named: "boothLogo"))
        
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
    
    
    @IBAction func joinButtonAction(_ sender: Any) {
        //first register for that event by calling api
        
        joinButtonView.isHidden = true
        queueView.isHidden = false

    }

}
