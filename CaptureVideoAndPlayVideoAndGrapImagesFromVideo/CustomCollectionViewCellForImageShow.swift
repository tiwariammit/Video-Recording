//
//  CustomCollectionViewCellForImageShow.swift
//  CaptureVideoAndPlayVideoAndGrapImagesFromVideo
//
//  Created by Amrit on 9/23/16.
//  Copyright © 2016 Amrit. All rights reserved.
//

import UIKit

class CustomCollectionViewCellForImageShow: UICollectionViewCell {
    
    @IBOutlet weak var ImageFromVideo: UIImageView!
    override func awakeFromNib() {
        
        super.awakeFromNib()
//
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.ImageFromVideo.layer.cornerRadius = (self.ImageFromVideo.frame.width - 40) / 2
        self.ImageFromVideo.layer.masksToBounds = true

//        self.makeItCircle()
    }
    
    func makeItCircle() {
        
        self.ImageFromVideo.layer.cornerRadius  = CGFloat(roundf(Float(self.ImageFromVideo.frame.size.width/2.0)))
        self.ImageFromVideo.layer.masksToBounds = true
    }
}
