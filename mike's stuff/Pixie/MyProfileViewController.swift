//
//  MyProfileViewController.swift
//  Pixie
//
//  Created by Nicole on 4/27/15.
//  Copyright (c) 2015 Mike Sevilla. All rights reserved.
//

import UIKit
import GPUImage

class MyProfileViewController: UIViewController {
   
   var blurView: UIVisualEffectView!
   var profilePicBlurred: UIImageView!
   var profilePic: UIImageView!
   var nameLabel: UILabel!
   var bioLabel: UILabel!
   
   
   override func loadView() {
      super.loadView()
      
      let url = NSURL(string: "http://upload.wikimedia.org/wikipedia/commons/3/31/SlothDWA.jpg")
      let profilePicData = NSData(contentsOfURL: url!)
      let croppedImage = cropToSquare(image: UIImage(data: profilePicData!)!)
      
      var gaussianFilter = GPUImageGaussianBlurFilter()
      gaussianFilter.blurRadiusInPixels = 5
      gaussianFilter.blurPasses = 2
      let blurredImage = gaussianFilter.imageByFilteringImage(croppedImage)
      
      profilePicBlurred = UIImageView(image: blurredImage)
      profilePicBlurred.setTranslatesAutoresizingMaskIntoConstraints(false)
      blurView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
      blurView.setTranslatesAutoresizingMaskIntoConstraints(false)
      view.addSubview(profilePicBlurred)
      
      profilePic = UIImageView(image: croppedImage)
      profilePic.setTranslatesAutoresizingMaskIntoConstraints(false)
      view.addSubview(profilePic)
      
      nameLabel = UILabel()
      nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 24)!
      nameLabel.textAlignment = .Center
      nameLabel.textColor = UIColor.whiteColor()
      nameLabel.numberOfLines = 1
      nameLabel.adjustsFontSizeToFitWidth = true
      nameLabel.lineBreakMode = .ByClipping
      nameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
      view.addSubview(nameLabel)
      
      bioLabel = UILabel()
      bioLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 16)!
      bioLabel.textAlignment = .Left
      bioLabel.numberOfLines = 0
      bioLabel.lineBreakMode = .ByWordWrapping
      bioLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
      view.addSubview(bioLabel)
      
      setConstraints()
   }
   
   required init(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
   }
   
   func setConstraints() {
      let viewsDict = ["profilePic":profilePic, "profilePicBlurred":profilePicBlurred, "nameLabel":nameLabel, "bioLabel":bioLabel]
      let metrics = ["blurHeight":self.view.frame.width, "profPicSize":self.view.frame.width*(3.0/5.0)]
      
      self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-64-[profilePicBlurred(blurHeight)]-10-[bioLabel]", options: NSLayoutFormatOptions(0), metrics: metrics, views: viewsDict))
      self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[profilePic(profPicSize)]-5-[nameLabel]", options: NSLayoutFormatOptions(0), metrics: metrics, views: viewsDict))
      
      self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[profilePicBlurred]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict))
      self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[profilePic(profPicSize)]", options: NSLayoutFormatOptions(0), metrics: metrics, views: viewsDict))
      self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[bioLabel]-5-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict))
      
      self.view.addConstraint(NSLayoutConstraint(item: profilePic, attribute: .CenterX, relatedBy: .Equal, toItem: profilePicBlurred, attribute: .CenterX, multiplier: 1, constant: 0))
      self.view.addConstraint(NSLayoutConstraint(item: profilePic, attribute: .CenterY, relatedBy: .Equal, toItem: profilePicBlurred, attribute: .CenterY, multiplier: 1, constant: 0))
      self.view.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .CenterX, relatedBy: .Equal, toItem: profilePic, attribute: .CenterX, multiplier: 1, constant: 0))
      
      self.view.layoutIfNeeded()
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2;
      profilePic.clipsToBounds = true
      
      nameLabel.text = "Coolio Julio"
      bioLabel.text = "Ayeeee wassup girl! How you doinnnnn?????"
      
      println("profilePicBlurred... w:\(profilePicBlurred.frame.width), h:\(profilePicBlurred.frame.height)")
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   func cropToSquare(image originalImage: UIImage) -> UIImage {
      // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
      let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage)!
      
      // Get the size of the contextImage
      let contextSize: CGSize = contextImage.size
      
      let posX: CGFloat
      let posY: CGFloat
      let width: CGFloat
      let height: CGFloat
      
      // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
      if contextSize.width > contextSize.height {
         posX = ((contextSize.width - contextSize.height) / 2)
         posY = 0
         width = contextSize.height
         height = contextSize.height
      } else {
         posX = 0
         posY = ((contextSize.height - contextSize.width) / 2)
         width = contextSize.width
         height = contextSize.width
      }
      
      let rect: CGRect = CGRectMake(posX, posY, width, height)
      
      // Create bitmap image from context using the rect
      let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)
      
      // Create a new image based on the imageRef and rotate back to the original orientation
      let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)!
      
      return image
   }
   
}
