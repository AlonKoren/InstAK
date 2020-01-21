//
//  WalkthroughViewController.swift
//  InstAK
//
//  Created by alon koren on 21/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var pageContent = ["InstAK is an IOS application, which was built as part of a final project of the Mobile Operating Systems course.",
                       "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nIt all started here ...",
                       "\nSo after many moments of crisis.\nYou are welcome to use and enjoy \nInstAK."]
    
    var pageImage = ["my_pool.jpeg", "InstAK_BW.jpeg", "me_study_BW.jpeg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        if let startingViewController = viewControllerAtIndex(index: 0) {
            setViewControllers([startingViewController], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1
        return viewControllerAtIndex(index: index)
    }
    
    func viewControllerAtIndex(index: Int) -> WalkthroughContentViewController? {
        if index < 0 || index >= pageContent.count {
            return nil
        }
        if let pageContentViewController = storyboard?.instantiateViewController(withIdentifier: "WalkthroughContentViewController") as? WalkthroughContentViewController {
            pageContentViewController.content = pageContent[index]
            pageContentViewController.index = index
            pageContentViewController.imageFileName = pageImage[index]
            return pageContentViewController
        }
        return nil
    }
    
    func forward(index: Int) {
        if let nextViewController = viewControllerAtIndex(index: index + 1) {
            setViewControllers([nextViewController], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
        }
    }
    
    
}
