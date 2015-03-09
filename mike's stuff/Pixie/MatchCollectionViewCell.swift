//
//  MatchCell.swift
//  Matches
//
//  Created by Nicole on 2/16/15.
//  Copyright (c) 2015 Pixie. All rights reserved.
//

import UIKit

class MatchCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
   
   let profilePic: UIImageView!
   let userNameLabel: UILabel!
   let locationLabel: UILabel!
   let dateTimeLabel: UILabel!
   let lineImage: UIImageView!
   let messageIcon: UIButton!
   let starIcon: UIButton!
   
   override init(frame: CGRect) {
      super.init(frame: frame)
      
      self.layer.borderColor = UIColor.grayColor().CGColor
      //self.layer.borderWidth = 0.5;
      
      // Profile picture
      profilePic = UIImageView()
      profilePic.contentMode = UIViewContentMode.ScaleToFill
      profilePic.userInteractionEnabled = true
      profilePic.setTranslatesAutoresizingMaskIntoConstraints(false)
      contentView.addSubview(profilePic)
      
      // User name
      userNameLabel = UILabel()
      userNameLabel.textAlignment = .Center
      userNameLabel.adjustsFontSizeToFitWidth = true
      userNameLabel.lineBreakMode = .ByClipping
      userNameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
      contentView.addSubview(userNameLabel)
      
      // Location
      locationLabel = UILabel()
      locationLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 16)
      locationLabel.textAlignment = .Left
      locationLabel.adjustsFontSizeToFitWidth = true
      locationLabel.lineBreakMode = .ByClipping
      locationLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
      contentView.addSubview(locationLabel)
      
      // Date and time
      dateTimeLabel = UILabel()
      dateTimeLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 16)
      dateTimeLabel.textAlignment = .Left
      dateTimeLabel.adjustsFontSizeToFitWidth = true
      dateTimeLabel.lineBreakMode = .ByClipping
      dateTimeLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
      contentView.addSubview(dateTimeLabel)
      
      messageIcon = UIButton()
      messageIcon.setImage(UIImage(named: "chat-bubble32.png")!, forState: .Normal)
      messageIcon.backgroundColor = UIColor.clearColor()
      messageIcon.setTranslatesAutoresizingMaskIntoConstraints(false)
      contentView.addSubview(messageIcon)
      
      starIcon = UIButton()
      starIcon.setImage(UIImage(named: "star.png")!, forState: .Normal)
      starIcon.backgroundColor = UIColor.clearColor()
      starIcon.setTranslatesAutoresizingMaskIntoConstraints(false)
      contentView.addSubview(starIcon)
      
      // Gradient background
      let gradient = CAGradientLayer()
      gradient.frame = bounds
      gradient.colors = [UIColor.whiteColor().CGColor, UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).CGColor, UIColor(red: 0.0, green: 0.8, blue: 0.9, alpha: 1.0).CGColor]
      let bView = UIView()
      bView.layer.insertSublayer(gradient, atIndex: 0)
      backgroundView = bView
      
      // Horizontal line and arrow
      UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
      let cntx = UIGraphicsGetCurrentContext()
      CGContextSetStrokeColorWithColor(cntx, UIColor.blackColor().CGColor)
      CGContextSetLineWidth(cntx, 0.35)
      CGContextMoveToPoint(cntx, 0, 0)
      CGContextAddLineToPoint(cntx, frame.size.width, 0)
      CGContextStrokePath(cntx)
      lineImage = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 1))
      lineImage.image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      lineImage.setTranslatesAutoresizingMaskIntoConstraints(false)
      contentView.addSubview(lineImage)
      
      /* need to fix layout for iphone 4 since prof pic expands wierd when going to user bio */
      
      let viewsDict = ["profilePic":profilePic, "userName":userNameLabel, "location":locationLabel, "dateTime":dateTimeLabel, "line":lineImage, "message":messageIcon, "star":starIcon]
      contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[profilePic]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict))
      contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[userName]-10-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict))
      contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[line]-5-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict))
      contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[location]-5-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict))
      contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[dateTime]-5-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict))
      contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[message]-1-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict))
      contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[profilePic]-112-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict))
      contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[profilePic]-0-[userName]-1-[line]", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict))
      contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[userName]-5-[location]-0-[dateTime]-32-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict))
      contentView.addConstraint(NSLayoutConstraint(item: messageIcon, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: profilePic, attribute: .CenterX, multiplier: 1.0, constant: 0))
      contentView.addConstraint(NSLayoutConstraint(item: starIcon, attribute: NSLayoutAttribute.RightMargin, relatedBy: .Equal, toItem: profilePic, attribute: .RightMargin, multiplier: 1.0, constant: -1))
      contentView.addConstraint(NSLayoutConstraint(item: starIcon, attribute: NSLayoutAttribute.TopMargin, relatedBy: .Equal, toItem: profilePic, attribute: .TopMargin, multiplier: 1.0, constant: 1))
      self.layoutIfNeeded()
      
   }
   
   required init(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
   }
   
   func resizeImage(image: UIImage, newSize: CGSize) -> (UIImage) {
      //println("old image... w: \(image.size.width), h: \(image.size.height)")
      let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
      let imageRef = image.CGImage
      
      UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
      let context = UIGraphicsGetCurrentContext()
      
      // Set the quality level to use when rescaling
      CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
      let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
      
      CGContextConcatCTM(context, flipVertical)
      // Draw into the context; this scales the image
      CGContextDrawImage(context, newRect, imageRef)
      
      let newImageRef = CGBitmapContextCreateImage(context) as CGImage
      let newImage = UIImage(CGImage: newImageRef)
      
      // Get the resized image from the context and a UIImage
      UIGraphicsEndImageContext()
      
      //println("new image... w: \(newImage?.size.width), h: \(newImage?.size.height)")
      
      return newImage!
   }
   
}
