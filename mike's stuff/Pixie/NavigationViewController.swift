//
//  NavigationViewController.swift
//  Pixie
//
//  Created by Mike Sevilla on 2/22/15.
//  Copyright (c) 2015 Mike Sevilla. All rights reserved.
//

import Foundation
import UIKit

class NavigationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var dimmerView: UIView!
    
    var items: [NavigationModel]!
    var presentingView: UIViewController!
//    let user = PFUser.currentUser()!
    var defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        bgImageView.image = UIImage(named: "nav-bg")
        dimmerView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        
        let id = defaults.stringForKey("PixieUserId")
        var fullName = ""
        if let savedFirstName = defaults.stringForKey("PixieUserFirstName") {
            fullName = savedFirstName
            if let savedLastName = defaults.stringForKey("PixieUserLastName") {
                fullName += " \(savedLastName)"
            }
        }
        
        let search = NavigationModel(title: "Search", icon: "location")
        let myProfile = NavigationModel(title: "My Profile", icon: "user")
        let messages = NavigationModel(title: "Messages", icon: "icon-chat", count: "3")
        let myRides = NavigationModel(title: "My Rides", icon: "car")
        let about = NavigationModel(title: "About", icon: "icon-info")
        let signOut = NavigationModel(title: "Sign Out", icon: "door")
        
        items = [search, myProfile, messages, myRides, about, signOut]
        
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        leftSwipe.direction = .Left
        view.addGestureRecognizer(leftSwipe)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NavigationCell") as! NavigationCell
        let item = items[indexPath.row]
        
        cell.titleLabel.text = item.title
        cell.countLabel.text = item.count
        cell.iconImageView.image = UIImage(named: item.icon)
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        if sender.direction == .Left {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
        case 0:
            if let pView = presentingView as? SearchViewController {
                dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                self.performSegueWithIdentifier("presentSearch", sender: self)
            }
        case 1:
            if let pView = presentingView as? ProfileViewController {
                dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                self.performSegueWithIdentifier("presentProfile", sender: self)
            }
        case 2:
            if let pView = presentingView as? MessagesViewContoller {
                dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                self.performSegueWithIdentifier("presentMessages", sender: self)
            }
        case 3:
            if let pView = presentingView as? MyPostsViewController {
                dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                self.performSegueWithIdentifier("presentMyPosts", sender: self)
            }
        case 4:
            if let pView = presentingView as? AboutViewController {
                dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                self.performSegueWithIdentifier("presentAbout", sender: self)
            }
        case 5:
            NSUserDefaults.standardUserDefaults().removeObjectForKey("PixieUserId")
            self.performSegueWithIdentifier("unwindInitial", sender: self)
            PFUser.logOut()
        default:
            print("uhhh...hai <(._.<)")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "presentMessages" {
            if let navVC = segue.destinationViewController as? UINavigationController {
                if let destVC = navVC.topViewController as? MessagesViewContoller {
//                    destVC.userID = user?.id
//                    destVC.userName = user?.name
                }
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

class NavigationModel {
    
    var title : String!
    var icon : String!
    var count : String?
    
    init(title: String, icon : String) {
        self.title = title
        self.icon = icon
    }
    
    init(title: String, icon : String, count: String) {
        
        self.title = title
        self.icon = icon
        self.count = count
    }
}
