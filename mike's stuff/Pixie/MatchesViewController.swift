//
//  MatchesViewController
//  Matches
//
//  Created by Nicole on 2/16/15.
//  Copyright (c) 2015 Pixie. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"
var viewSize = CGSizeMake(0, 0)
var scrollOffset = CGPointMake(0, 0)
var startPoint = CGPointMake(0, 0)
var movedPoint = CGPointMake(0, 0)
var endPoint = CGPointMake(0, 0)

class MatchesViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate {
   
   var collectionView: UICollectionView!
   var currentCell: MatchCollectionViewCell?
   var noMatchesLabel: UILabel!
   var currentMatch: Match!
   var transitionManager = MatchesToBioTransitionOperator()
   var navTransitionOperator = NavigationTransitionOperator()
   var viewInsets: UIEdgeInsets!
   var itemSize: CGSize!
   var topMargin: CGFloat!
   var userId: Int! = -1
   var fullName: String = "Error"
   var startLat: Double!
   var startLon: Double!
   var endLat: Double!
   var endLon: Double!
   var searchDate: String!
   var searchTime: String!
   let user = PFUser.currentUser()
   let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
   
   private var matches = [Match]()
   private var posts = [Post]()
   private var users = [Int: User]()
   
   override func loadView() {
      super.loadView()
      view.backgroundColor = self.uicolorFromHex(0xFAFAFA)
      var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
      itemSize = CGSize(width: view.frame.width/7.0*6.0, height: view.frame.width/7.0*6.0+114.0)
      layout.itemSize = itemSize
      layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
      viewInsets = UIEdgeInsets(top: 0, left: view.frame.width/14.0, bottom: 0, right: view.frame.width/14.0 )
      layout.headerReferenceSize = CGSizeZero
      layout.footerReferenceSize = CGSizeZero
      layout.sectionInset = viewInsets
      
      topMargin = (view.frame.height - itemSize.height - 64.0)/2.0
      
      collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
      collectionView.dataSource = self
      collectionView.delegate = self
      collectionView.registerClass(MatchCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
      collectionView.backgroundColor = UIColor.clearColor()
      collectionView.pagingEnabled = true
      collectionView.scrollEnabled = true
      collectionView.showsHorizontalScrollIndicator = false
      collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
      self.view.addSubview(collectionView)
      
      noMatchesLabel = UILabel()
      noMatchesLabel.text = "No MaTcHes 😳"
      noMatchesLabel.textAlignment = .Center
      noMatchesLabel.font = UIFont(name: "Syncopate-Regular", size: 24.0)
      noMatchesLabel.textColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
      noMatchesLabel.hidden = true
      noMatchesLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
      self.view.addSubview(noMatchesLabel)
      
      let viewsDict = ["collectionView":collectionView, "noMatches":noMatchesLabel]
      self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-64-[collectionView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict))
      self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict))
      self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[noMatches]-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: viewsDict))
      self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[noMatches]-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: viewsDict))
      
      loadPostsFromAPI()
      if posts.count > 0 {
         loadUsersFromAPI()
         collectionView.reloadData()
      } else {
         noMatchesLabel.hidden = false
      }
   }
   
   func uicolorFromHex(rgbValue:UInt32) -> UIColor {
      let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
      let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
      let blue = CGFloat(rgbValue & 0xFF)/256.0
      
      return UIColor(red:red, green:green, blue:blue, alpha:1.0)
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      spinner.center = CGPointMake(self.view.frame.midX, self.view.frame.midY)
      self.view.addSubview(spinner)
      
      var swipeToSearchView = UISwipeGestureRecognizer(target: self, action: "handleSwipes:")
      swipeToSearchView.direction = .Down
      self.view.addGestureRecognizer(swipeToSearchView)
      
      var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
      rightSwipe.direction = .Right
      view.addGestureRecognizer(rightSwipe)
      
      /* Where "userId" is set */
      let defaults = NSUserDefaults.standardUserDefaults()
      if let savedId = defaults.stringForKey("PixieUserId") {
         userId = savedId.toInt()
      }
      if let savedFirstName = defaults.stringForKey("PixieUserFirstName") {
         fullName = savedFirstName
         if let savedLastName = defaults.stringForKey("PixieUserLastName") {
            fullName += " \(savedLastName)"
         }
      }
   }
   
   func loadPostsFromAPI() {
      var urlString = "http://ec2-54-69-253-12.us-west-2.compute.amazonaws.com/pixie/posts?startLat=\(startLat)&startLon=\(startLon)&endLat=\(endLat)&endLon=\(endLon)&day=\(searchDate)&time=\(searchTime)&driverEnum=RIDER"
      let url = NSURL(string: urlString)
      var request = NSURLRequest(URL: url!)
      var response: NSURLResponse?
      var error: NSErrorPointer = nil
      var data =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:nil)! as NSData
      
      if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
         //         println("loadPostsFromAPI json...\n\(json)")
         if let items = json["results"] as? NSArray {
            for item in items {
               if let start = item["start"] as? String {
                  if let end = item["end"] as? String {
                     if let day = item["day"] as? String {
                        if let time = item["time"] as? String {
                           if let postId = item["postId"] as? Int {
                              if let userIdStr = item["userId"] as? String {
                                 let userId = userIdStr.toInt()!
                                 if let driverEnum = item["driverEnum"] as? String {
                                    let isDriver = driverEnum == "DRIVER" ? true : false
                                    self.posts.append(Post(isDriver: isDriver, start: Location(name: start, lat: 0, long: 0), end: Location(name: end, lat: 0, long: 0), day: day, time: time, postId: postId, userId: userId))
                                    posts[posts.count-1].toString()
                                 } else {
                                    println("error: driver_enum")
                                 }
                              } else {
                                 println("error: userId")
                              }
                           } else {
                              println("error: postId")
                           }
                        } else {
                           println("error: time")
                        }
                     } else {
                        println("error: day")
                     }
                  } else {
                     println("error: end")
                  }
               } else {
                  println("error: start")
               }
            }
         } else {
            println("error: posts")
         }
      } else {
         println("error json: \(error)") // print the error!
      }
   }
   
   func loadUsersFromAPI() {
      for p in posts {
         if let currUser = users[p.userId] {
            self.matches.append(Match(author: currUser, post: p))
         } else {
            var user = User()
            var urlString = "http://ec2-54-69-253-12.us-west-2.compute.amazonaws.com/pixie/users/\(p.userId)"
            let url = NSURL(string: urlString)
            var request = NSURLRequest(URL: url!)
            var response: NSURLResponse?
            var error: NSErrorPointer = nil
            var data =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:nil)! as NSData
            
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
               //               println("loadUsersFromAPI json...\n\(json)\n")
               if let userIdStr = json["userId"] as? String {
                  let userId = userIdStr.toInt()!
                  if userId == p.userId {
                     user.userId = userId
                     if let first_name = json["first_name"] as? String {
                        if let last_name = json["last_name"] as? String {
                           user.setName(first_name, lastName: last_name)
                           if let ageStr = json["age"] as? String {
                              if let age = ageStr.toInt() {
                                 user.age = age
                              }
                           }
                           if let bio = json["bio"] as? String {
                              if bio != "NULL" && count(bio) > 0 {
                                 user.bio = bio
                              }
                           }
                           if let photoURL = json["photoURL"] as? String {
                              if count(photoURL) > 0 {
                                 user.setProfPic(photoURL)
                              }
                           }
                           self.matches.append(Match(author: user, post: p))
                           users[p.userId] = user
                        } else {
                           println("error: last_name")
                        }
                     } else {
                        println("error: first_name")
                     }
                  } else {
                     println("error: post.userId != user.userId")
                  }
               } else {
                  println("error: userId")
               }
            } else {
               println("error: json object with userId: \(p.userId)")
            }
         }
      }
   }
	
	func loadUserPicFromAPI(userId: Int) -> NSData {
		var urlString = "http://ec2-54-69-253-12.us-west-2.compute.amazonaws.com/pixie/userPic/\(userId)"
		let url = NSURL(string: urlString)
		var request = NSURLRequest(URL: url!)
		var response: NSURLResponse?
		var error: NSErrorPointer = nil
		var data =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:nil)! as NSData
		
		return data
	}
	
   func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
      return matches.count
   }
   
   func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return 1
   }
   
   func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! MatchCollectionViewCell
      currentMatch = matches[indexPath.indexAtPosition(0)]
      
      var tap = UITapGestureRecognizer(target: self, action: "tappedImage:")
      tap.numberOfTapsRequired = 1;
      tap.numberOfTouchesRequired = 1;
      tap.delegate = self
      
      cell.messageIcon.addTarget(self, action: "sendMessage:", forControlEvents: UIControlEvents.TouchUpInside)
      
      cell.profilePic.addGestureRecognizer(tap)
      //cell.profilePic.image = currentMatch.author.useDefaultImage ? currentMatch.author.defaultImage : UIImage(data: currentMatch.author.profilePicData)
	  cell.profilePic.image = UIImage(data: loadUserPicFromAPI(currentMatch.author.userId))
      if currentMatch.author.age > 0 {
         cell.userNameLabel.attributedText = createAttributedNameString(currentMatch.author.fullName, age: currentMatch.author.age)
      } else {
         cell.userNameLabel.attributedText = createAttributedNameStringNoAge(currentMatch.author.fullName)
      }
      cell.seekOfferLabel.text = currentMatch.post.isDriver ? "😎 Offering" : "😊 Seeking"
      cell.locationLabel.text = "\(currentMatch.post.start.name) \u{2192} \(currentMatch.post.end.name)"
      cell.dateTimeLabel.text = "\(currentMatch.post.day), \(currentMatch.post.time)"
      
      currentCell = cell
      return cell
   }
   
   func createAttributedNameString(name: String, age: Int) -> NSMutableAttributedString {
      var nameString = NSMutableAttributedString(string: name + ", \(age)")
      nameString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Thin", size: 20)!, range: NSMakeRange(0, count(name)+1))
      nameString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-UltraLight", size: 20)!, range: NSMakeRange(count(name)+2, count("\(age)")))
      return nameString
      
   }
   
   func createAttributedNameStringNoAge(name: String) -> NSMutableAttributedString {
      var nameString = NSMutableAttributedString(string: name)
      nameString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Thin", size: 20)!, range: NSMakeRange(0, count(name)))
      return nameString
      
   }
   
   func tappedImage(recognizer: UITapGestureRecognizer) {
      self.performSegueWithIdentifier("showUserBio", sender: self)
   }
   
   func handleSwipes(sender: UISwipeGestureRecognizer) {
      if sender.direction == .Down {
         self.performSegueWithIdentifier("unwindToSearchView", sender: self)
      }
   }

   func sendMessage(sender: SenderButton!) {
      var newConvo = PFObject(className: "Conversation")
      
      newConvo["user1Name"] = self.user!["name"] as? String
      newConvo["user1Id"] = self.user!["userId"] as? String
      newConvo["user2Name"] = currentMatch.author.fullName
      newConvo["user2Id"] = "\(currentMatch.author.userId)"
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
         dispatch_async(dispatch_get_main_queue(), {
            self.spinner.startAnimating()
         })
         
         newConvo.save()
         sender.parseConvo = newConvo
         
         dispatch_async(dispatch_get_main_queue(), {
            self.spinner.stopAnimating()
            self.performSegueWithIdentifier("presentConvo", sender: sender)
         })
      })
   }
   
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      if segue.identifier == "showUserBio" {
         if let destinationVC = segue.destinationViewController as? BioViewController {
            destinationVC.transitioningDelegate = self.transitionManager
            destinationVC.modalPresentationStyle = UIModalPresentationStyle.Custom
            
            var idxPath = self.collectionView.indexPathsForVisibleItems().first as! NSIndexPath
            var current = matches[idxPath.indexAtPosition(0)].author
            
            if current.age > 0 {
               destinationVC.userNameLabel.attributedText = createAttributedNameString(current.fullName, age: current.age)
            } else {
               destinationVC.userNameLabel.attributedText = createAttributedNameStringNoAge(current.fullName)
            }
            destinationVC.userBio.text = current.bio
            destinationVC.profilePic.image = currentCell?.profilePic.image
         }
      }
      else if segue.identifier == "presentNav" {
         let toViewController = segue.destinationViewController as! NavigationViewController
         self.modalPresentationStyle = UIModalPresentationStyle.Custom
         toViewController.transitioningDelegate = self.navTransitionOperator
         toViewController.presentingView = self
      }
      else if segue.identifier == "presentConvo" {
         if let navVC = segue.destinationViewController as? UINavigationController {
            if let destVC = navVC.topViewController as? ConversationViewController {
               let btn = sender as! SenderButton
               
               destVC.fromMatches = true
               destVC.recipientName = btn.recipientName
               destVC.recipientId = btn.recipientId
               destVC.convoId = btn.convoId
               destVC.convo = btn.parseConvo!
            }
         }
      }
   }
   
   @IBAction func unwindToMatches(segue:UIStoryboardSegue) {}
}

// wrapper class to send parse conversation via segue
class SenderButton: UIButton {
   var recipientName = ""
   var recipientId = ""
   var convoId = ""
   var parseConvo: PFObject? {
      didSet {
         if let convo = parseConvo {
            recipientName = convo["user2Name"] as! String
            recipientId = convo["user2Id"] as! String
            convoId = convo.objectId!
         }
      }
   }
}