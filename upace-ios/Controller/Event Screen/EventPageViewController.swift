//
//  EventPageViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 11/03/24.
//

import UIKit

//protocol which is used to tell about page changed
protocol EventPageViewControllerDelegate: AnyObject {
    func tabPageViewController(didChangeTabToIndex index: Int)
    func pageScrollViewController(didScrollToOffset offset: CGFloat)
}


class EventPageViewController: UIPageViewController {

    private var pageViewControllerList = [UIViewController]()
    private var currentIndex: Int = 0
    static var tabDelegate : EventPageViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SingleEventViewController.delegate = self
        self.dataSource = self
        self.delegate = self
        
        pageViewControllerList = [
            self.storyboard!.instantiateViewController(withIdentifier: "BoothListViewController"),
            self.storyboard!.instantiateViewController(withIdentifier: "OverviewViewController"),
            self.storyboard!.instantiateViewController(withIdentifier: "FAQViewController"),
        ]
        setViewControllers([pageViewControllerList[0]], direction: .forward, animated: true, completion: nil)
    }
}

//for swiping in pages
extension EventPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pageViewControllerList.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = currentIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        return pageViewControllerList[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pageViewControllerList.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = currentIndex + 1
        guard nextIndex < pageViewControllerList.count else {
            return nil
        }
        return pageViewControllerList[nextIndex]
    }
}


//MARK: PageView Delegate
// for change as per tab is tapped in main view controller
extension EventPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let currentViewController = pageViewController.viewControllers?.first else {
            return
        }
        if let currentIndex = pageViewControllerList.firstIndex(of: currentViewController) {
            EventPageViewController.tabDelegate?.tabPageViewController(didChangeTabToIndex: currentIndex)
            self.currentIndex = currentIndex
        }
    }
}


// delegate to change current tab in page view controller
extension EventPageViewController : SingleEventViewControllerDelegate{
    func tabChanged(index: Int) {
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        setViewControllers([pageViewControllerList[index]], direction: direction, animated: true, completion: nil)
        currentIndex = index
    }
}


