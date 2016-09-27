//
//  VideoPlayVC.swift
//  VideoRecorderTest
//
//  Created by Amrit on 9/22/16.
//  Copyright © 2016 Amrit. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SVProgressHUD

class VideoPlayVC: UIViewController {
    
    var url : NSURL?
    
    @IBOutlet weak var showVideo: UIView!
    
    let moviePlayerController = AVPlayerViewController()
    var aPlayer = AVPlayer()
    
    
    //MARK:-View Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        playBackgroundMovie()
        showVideo.layer.cornerRadius = 8
        showVideo.layer.masksToBounds = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoPlayVC.didPlayToEndTime), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        aPlayer.play()

        super.viewWillAppear(true)
    }
    
    func playBackgroundMovie(){
        
        aPlayer = AVPlayer(URL: url!)
        let playerLayer = AVPlayerLayer(player: aPlayer)
        playerLayer.frame = self.view.bounds
        self.showVideo.layer.addSublayer(playerLayer)
        aPlayer.play()
    }
    
    func didPlayToEndTime(){
        aPlayer.seekToTime(CMTimeMakeWithSeconds(0, 1))
        aPlayer.play()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func backAction(sender: AnyObject) {
        
        let vc = UIAlertController(title: "Discard Video", message: "Discard the video and try again", preferredStyle: UIAlertControllerStyle.Alert)
        let actionDiscard = UIAlertAction(title: "Discard", style: .Default) { (action) in
            
            
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            self.view.window!.layer.addAnimation(transition, forKey: kCATransition)
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        vc.addAction(actionDiscard)
        vc.addAction(actionCancel)
        presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func forwardAction(sender: AnyObject) {
        
        if let link = url{
//            SVProgressHUD.show()
            aPlayer.pause()
            let images = videoSnapshot(link)
            let vc = storyboard?.instantiateViewControllerWithIdentifier("ShowImageVideoVC") as! ShowImageVideoVC
            vc.totalImage = images
            
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            view.window!.layer.addAnimation(transition, forKey: kCATransition)
            presentViewController(vc, animated: false){
                
//                SVProgressHUD.dismiss()
            }
            
        }
    }
    
    func videoSnapshot(url: NSURL) -> [UIImage] {
        
        let asset = AVURLAsset(URL: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        var imageArray = [UIImage]()
        
        
        for i in 0.stride(to: 4, by: 0.2) {
            let timestamp = CMTime(seconds: Double(i), preferredTimescale: 60)
            do {
                let imageRef = try generator.copyCGImageAtTime(timestamp, actualTime: nil)
                let image = UIImage(CGImage: imageRef)
                imageArray.append(image)
            }
            catch let error as NSError
            {
                print("Image generation failed with error \(error)")
            }
        }
        
        return imageArray
        
    }
    
    
}
