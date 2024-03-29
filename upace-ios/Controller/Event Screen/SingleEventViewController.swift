//
//  SingleEventViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 10/03/24.
//

import UIKit

protocol SingleEventViewControllerDelegate: AnyObject {
    func tabChanged(index : Int)
}

class SingleEventViewController: UIViewController{
    
    
    
    static var delegate : SingleEventViewControllerDelegate?
    private var heightForStopPointofScrolling : CGFloat = 0
    private var currentIndex = 0
    private var minContainerViewHeight : CGFloat = 400
    private var boothListHeight :  CGFloat = 0
    
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventTagline: UILabel!
    @IBOutlet weak var currentTabViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var eventTopLabel: UILabel!
    @IBOutlet weak var staticTabView: UIView!
    @IBOutlet weak var backButtonView: CustomView!
    @IBOutlet weak var backButtonImageview: UIImageView!
    @IBOutlet weak var eventBannerImageView: UIImageView!
    @IBOutlet weak var eventLogoImageView: CustomImage!
    @IBOutlet weak var eventDescriptionView: UIView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var boothTabLabel: UILabel!
    @IBOutlet weak var overViewTabLabel: UILabel!
    @IBOutlet weak var faqTabLabel: UILabel!
    
    @IBOutlet weak var currentTabViewLeadingConstraint2: NSLayoutConstraint!
    @IBOutlet weak var boothTabLabel2: UILabel!
    @IBOutlet weak var overViewTabLabel2: UILabel!
    @IBOutlet weak var faqTabLabel2: UILabel!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LOG("\(type(of: self)) viewDidLoad")
        
        initializeView()

    }

    override func viewDidAppear(_ animated: Bool) {
        
        heightForStopPointofScrolling = eventBannerImageView.frame.size.height  + eventDescriptionView.frame.height - topView.frame.size.height
        let bottomSafeArea = view.safeAreaInsets.bottom
        minContainerViewHeight = view.frame.height - topView.frame.size.height - 40 - bottomSafeArea
        containerHeightConstraint.constant = max (minContainerViewHeight, boothListHeight)
    
    }
    
    @IBAction func tabChangeAction(_ sender: UIButton) {
        tabChange(index: sender.tag)
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func initializeView(){
        
        eventTitle.text = Singleton.shared.selectedEvent?.title
        eventTagline.text = Singleton.shared.selectedEvent?.tag_line
        eventTopLabel.text = Singleton.shared.selectedEvent?.title
        
        BoothListViewController.delegate = self
        EventPageViewController.tabDelegate = self
    
    }

    func tabChange(index : Int){
        setTabView(currentIndex: currentIndex, nextIndex: index)
        SingleEventViewController.delegate?.tabChanged(index: index)
    }
    
    
    func setTabView(currentIndex : Int, nextIndex: Int){
        currentTabViewLeadingConstraint.constant =  ( self.view.frame.width * 0.9 ) / 3  * CGFloat(nextIndex)
        currentTabViewLeadingConstraint2.constant =  ( self.view.frame.width * 0.9 ) / 3  * CGFloat(nextIndex)
        
        tabLabelAtIndex(index: currentIndex).textColor = .label
        tabLabelAtIndex(index: nextIndex).textColor = .K_BLUE
        
        tabLabelAtIndex2(index: currentIndex).textColor = .label
        tabLabelAtIndex2(index: nextIndex).textColor = .K_BLUE
        
        tabLabelAtIndex(index: currentIndex).font = UIFont(name: "Nunito-Medium", size: 16)
        tabLabelAtIndex(index: nextIndex).font = UIFont(name: "Nunito-Bold", size: 16)
        
        tabLabelAtIndex2(index: currentIndex).font = UIFont(name: "Nunito-Medium", size: 16)
        tabLabelAtIndex2(index: nextIndex).font = UIFont(name: "Nunito-Bold", size: 16)
        
        containerHeightConstraint.constant = nextIndex == 1 ? minContainerViewHeight : boothListHeight
        
        self.currentIndex = nextIndex
    }
    
    func tabLabelAtIndex(index: Int) -> UILabel {
        switch(index) {
        case 0:
            return boothTabLabel
        case 1:
            return overViewTabLabel
        default:
            return faqTabLabel
        }
    }
    
    func tabLabelAtIndex2(index: Int) -> UILabel {
        switch(index) {
        case 0:
            return boothTabLabel2
        case 1:
            return overViewTabLabel2
        default:
            return faqTabLabel2
        }
    }
}

extension SingleEventViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
   
        if scrollView.contentOffset.y  > heightForStopPointofScrolling{
            staticTabView.isHidden = false
            
            self.topView.backgroundColor = .systemBackground
            
            UIView.animate(withDuration: 0.1) {
                self.eventTopLabel.isHidden = false
                self.backButtonView.backgroundColor = .clear
                self.backButtonImageview.tintColor = Singleton.shared.currentTheme == "light" ? .black : .white
            }
        }else{
            staticTabView.isHidden = true
            UIView.animate(withDuration: 0.1) {
                self.topView.backgroundColor = .clear
                self.eventTopLabel.isHidden = true
                self.backButtonView.backgroundColor = .black.withAlphaComponent(0.1)
                self.backButtonImageview.tintColor = .white
            }
        }
    }
}

extension SingleEventViewController : ContainerViewHeightDelegate {
    func setContainerHeight(height: CGFloat) {
        boothListHeight = max (height + 50 , minContainerViewHeight)
        containerHeightConstraint.constant = boothListHeight
        print("containerHeightConstraint.constant \(containerHeightConstraint.constant)")
    }
}

extension SingleEventViewController : EventPageViewControllerDelegate{
    func tabPageViewController(didChangeTabToIndex index: Int) {
        setTabView(currentIndex: currentIndex, nextIndex: index)
    }
    
    func pageScrollViewController(didScrollToOffset offset: CGFloat) {
        // no use
    }
    
}
