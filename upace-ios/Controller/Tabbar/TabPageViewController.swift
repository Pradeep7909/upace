//
//  TabPageViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 07/03/24.
//

import UIKit

class TabPageViewController: UIPageViewController {

    private var pageViewControllerList = [UIViewController]()
    private var currentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        MainViewController.delegate = self
        
        pageViewControllerList = [
            self.storyboard!.instantiateViewController(withIdentifier: "HomeViewController"),
            self.storyboard!.instantiateViewController(withIdentifier: "FeaturesViewController"),
            self.storyboard!.instantiateViewController(withIdentifier: "UniversitiesViewController"),
            self.storyboard!.instantiateViewController(withIdentifier: "CoursesViewController"),
            self.storyboard!.instantiateViewController(withIdentifier: "ProfileViewController"),
        ]
        setViewControllers([pageViewControllerList[0]], direction: .forward, animated: true, completion: nil)
    }

}

// delegate to change current tab in page view controller
extension TabPageViewController : MainViewControllerDelegate{
    func tabChanged(index: Int) {
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        setViewControllers([pageViewControllerList[index]], direction: direction, animated: true, completion: nil)
        currentIndex = index
    }
}



