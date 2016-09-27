//
//  ShowImageVideoVC.swift
//  VideoRecorderTest
//
//  Created by Amrit on 9/22/16.
//  Copyright © 2016 Amrit. All rights reserved.
//

import UIKit

class ShowImageVideoVC: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var showMoreImageOutlet: UIButton!
    @IBOutlet weak var bottomViewOutlet: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var totalImage = [UIImage]()
    var totalImageToshow = [UIImage]()
    var padding:CGFloat = 20.0
    
    //MARK:-View Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = false
        print(totalImage)
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.contentInset = UIEdgeInsets(top: padding, left: padding, bottom:padding, right: padding)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            layout.minimumLineSpacing = padding
            layout.minimumInteritemSpacing = padding
            let width =  (collectionView.bounds.width - 3*padding)/2 - 1
            print(width)
            layout.itemSize = CGSizeMake(width, width)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return totalImage.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CustomCollectionViewCellForImageShow", forIndexPath: indexPath) as!CustomCollectionViewCellForImageShow
        cell.ImageFromVideo.image = totalImage[indexPath.item]
        return cell
    }
    
    
    
    @IBAction func backAction(sender: AnyObject) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.addAnimation(transition, forKey: kCATransition)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func showMorePicAction(sender: AnyObject) {
        
        
    }
}