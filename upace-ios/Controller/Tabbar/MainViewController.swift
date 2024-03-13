//
//  MainViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 07/03/24.
//

import UIKit

protocol MainViewControllerDelegate: AnyObject {
    func tabChanged(index : Int)
}

class MainViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    private var currentIndex = 0
    private var sideMenuWidth : CGFloat = 300
    static var delegate: MainViewControllerDelegate?
    private var isSideMenuShowing =  false
    var menuItems: [MenuCell] = [
        MenuCell(imageName: "user-square", title: "Profile information"),
        MenuCell(imageName: "clipboard", title: "Application profile"),
        MenuCell(imageName: "refer", title: "Refer & Earn"),
        MenuCell(imageName: "theme", title: "Change Theme"),
        MenuCell(imageName: "login", title: "Logout")
    ]
    
    //MARK: IBOutlet
    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var homeLineWidth: NSLayoutConstraint!
    @IBOutlet weak var homeImageHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var featuresImage: UIImageView!
    @IBOutlet weak var featuresLabel: UILabel!
    @IBOutlet weak var feauresLineWidth: NSLayoutConstraint!
    @IBOutlet weak var featuresImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var universitiesImage: UIImageView!
    @IBOutlet weak var universitiesLabel: UILabel!
    @IBOutlet weak var universitiesLineWidth: NSLayoutConstraint!
    @IBOutlet weak var universitiesImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var coursesImage: UIImageView!
    @IBOutlet weak var coursesLabel: UILabel!
    @IBOutlet weak var coursesLineWidth: NSLayoutConstraint!
    @IBOutlet weak var coursesImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var profileLineWidth: NSLayoutConstraint!
    @IBOutlet weak var profileImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var commonTopView: CommonTopView!
    @IBOutlet weak var centerLogoImage: UIImageView!

    
    @IBOutlet weak var sideMenuView: CustomView!
    @IBOutlet weak var sideMenuWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenuLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var darkScreenView: UIView!
    @IBOutlet weak var sideMenuTableView: UITableView!
    
    
    //MARK: ViewCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        LOG("\(type(of: self)) viewDidLoad")
        initialize()
    }
    
    //MARK: IBAction
    @IBAction func tabButton(_ sender: UIButton) {
        switch(sender.tag){
        case 0:
            tabChange(tag: 0, tabTitle: "")
        case 1:
            tabChange(tag: 1, tabTitle: "Features")
        case 2:
            tabChange(tag: 2, tabTitle: "Universities")
        case 3:
            tabChange(tag: 3, tabTitle: "Courses")
        default:
            tabChange(tag: 4, tabTitle: "Profile")
        }
    }
    
    //MARK: Functions
    private func initialize(){
        feauresLineWidth.constant = 0
        universitiesLineWidth.constant = 0
        coursesLineWidth.constant = 0
        profileLineWidth.constant = 0
        commonTopView.title.text = ""
        commonTopView.delegate = self
        homeImageHeightConstraint.constant = 30
        homeImage.tintColor = .K_BLUE
        homeLabel.textColor = .K_BLUE
        homeLabel.font = UIFont(name: "Nunito-Bold", size: 12)
        sideViewSetup()
        
        
        let userdetail =  Singleton.shared.currentUser
        print("🟢userdetail :\(String(describing: userdetail))")
        
    }
    
    func tabChange(tag : Int , tabTitle : String){
        changeColor(currentIndex: currentIndex, nextIndex: tag)
        currentIndex = tag
        MainViewController.delegate?.tabChanged(index: tag)
        commonTopView.title.text = tabTitle
        centerLogoImage.isHidden = tag == 0 ? false :  true
    }
    
    func changeColor(currentIndex :Int , nextIndex : Int){
        tabLabelAtIndex(index: currentIndex).textColor = .K_DARK_GREY
        tabLabelAtIndex(index: nextIndex).textColor = K_BLUE_COLOR
        
        tabImageAtIndex(index: currentIndex).tintColor = .K_DARK_GREY
        tabImageAtIndex(index: nextIndex).tintColor = K_BLUE_COLOR
        
        let currentTabLine = tabLineAtIndex(index: currentIndex)
        let nextTabLine = tabLineAtIndex(index: nextIndex)
        
        UIView.animate(withDuration: 0.2) {
            currentTabLine.constant = 0
            nextTabLine.constant = 40
            
            self.imageHeightConstraintAtIndex(index: currentIndex).constant = 25
            self.imageHeightConstraintAtIndex(index: nextIndex).constant = 30
            
            self.tabLabelAtIndex(index: currentIndex).font = UIFont(name: "Nunito-Regular", size: 12)
            self.tabLabelAtIndex(index: nextIndex).font = UIFont(name: "Nunito-Bold", size: 12)
            
            self.view.layoutIfNeeded()
        }
    }
    
    
    func tabLabelAtIndex(index: Int) -> UILabel {
        switch(index) {
        case 0:
            return homeLabel
        case 1:
            return featuresLabel
        case 2:
            return universitiesLabel
        case 3:
            return coursesLabel
        default:
            return profileLabel
        }
    }
    
    
    func tabImageAtIndex(index: Int) -> UIImageView {
        switch(index) {
        case 0:
            return homeImage
        case 1:
            return featuresImage
        case 2:
            return universitiesImage
        case 3:
            return coursesImage
        default:
            return profileImage
        }
    }
    
    
    func tabLineAtIndex(index : Int) -> NSLayoutConstraint{
        switch(index) {
        case 0:
            return homeLineWidth
        case 1:
            return feauresLineWidth
        case 2:
            return universitiesLineWidth
        case 3:
            return coursesLineWidth
        default:
            return profileLineWidth
        }
    }
    
    
    func imageHeightConstraintAtIndex(index : Int) -> NSLayoutConstraint{
        switch(index) {
        case 0:
            return homeImageHeightConstraint
        case 1:
            return featuresImageHeightConstraint
        case 2:
            return universitiesImageHeightConstraint
        case 3:
            return coursesImageHeightConstraint
        default:
            return profileImageHeightConstraint
        }
    }
    
    
}

//MARK: TopView Delegate
extension MainViewController : CommonTopViewDelegate{
    func leftTopButtonTapped() {
        showSideMenu(duration: 0.3)
    }
    
    func rightTopButtonTapped() {
        LOG("Right button Tapped")
    }
}



//MARK: Side Menu View
extension  MainViewController {
    
    private func sideViewSetup(){
        sideMenuWidth = self.view.frame.width * 0.8
        sideMenuWidthConstraint.constant = sideMenuWidth
        setupSwipeAndTapGestureRecognizers()
        hideSideMenu(duration: 0)
        sideMenuTableView.contentInset.top = 20
        sideMenuView.shadowOpacity = 0
    }
    
    func hideSideMenu(duration : TimeInterval){
        self.isSideMenuShowing = false
        UIView.animate(withDuration: duration,animations: {
            self.sideMenuLeadingConstraint.constant = -self.sideMenuWidth
            self.darkScreenView.alpha = 0
            self.sideMenuView.shadowOpacity = 0
           
            self.view.layoutIfNeeded()
        }){_ in
            self.darkScreenView.isHidden = true
        }
    }

    
    func showSideMenu(duration : TimeInterval){
        self.isSideMenuShowing = true
        UIView.animate(withDuration: duration) {
            self.sideMenuLeadingConstraint.constant = 0
            self.darkScreenView.alpha = 0.8
            self.sideMenuView.shadowOpacity = 0.8
            self.darkScreenView.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    func setupSwipeAndTapGestureRecognizers() {
        // Swipe Gesture Recognizer
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        swipeGesture.delegate = self
        self.view.addGestureRecognizer(swipeGesture)

        // Tap Gesture Recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGesture.delegate = self
        self.darkScreenView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Gesture Handling
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        if !isSideMenuShowing {return}
        let translationX = gesture.translation(in: self.view).x
        
        switch gesture.state {
        case .changed:
            let totalWidth = view.bounds.width
            let leadingConstant = min(max(CGFloat(-sideMenuWidth), sideMenuLeadingConstraint.constant + translationX), 0)
            sideMenuLeadingConstraint.constant = leadingConstant
            let percentage = (totalWidth - (leadingConstant + sideMenuWidth)) / totalWidth
            darkScreenView.alpha = ( 1 - percentage)
            self.sideMenuView.shadowOpacity = Float(( 1 - percentage))
            gesture.setTranslation(.zero, in: self.view)
        case .ended:
            let velocityX = gesture.velocity(in: self.view).x
            if velocityX < 0 {
                hideSideMenu(duration: 0.1)
            } else {
                showSideMenu(duration: 0.1)
            }
        default:
            break
        }
    }
    
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        hideSideMenu(duration: 0.3)
    }
}

extension MainViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menu = menuItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleMenuCell", for: indexPath) as! SingleMenuCell
        cell.menuTitle.text = menu.title
        cell.menuImage.image = UIImage(named: menu.imageName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            if currentIndex == 4{
                hideSideMenu(duration: 0.3)
            } else{
                hideSideMenu(duration: 0.1)
                tabChange(tag: 4, tabTitle: "Profile")
            }
           
            
        }else if indexPath.row == 3{
            Singleton.shared.currentTheme = Singleton.shared.currentTheme == "light" ? "dark" : "light"
        }else if indexPath.row == 4{
            Singleton.shared.handleLogout()
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = scene.windows.first,
                   let rootViewController = window.rootViewController as? UINavigationController {
                    rootViewController.popToRootViewController(animated: true)
                }
            }
        }
    }
}

class SingleMenuCell : UITableViewCell{
    
    @IBOutlet weak var menuTitle: UILabel!
    @IBOutlet weak var menuImage: UIImageView!
    
}
