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

class VideoPlayVC: UIViewController {

    var url : NSURL?
    
    @IBOutlet weak var showVideo: UIView!
    
    let moviePlayerController = AVPlayerViewController()
    var aPlayer = AVPlayer()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        playBackgroundMovie()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoPlayVC.didPlayToEndTime), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
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
        self.dismissViewControllerAnimated(true, completion: nil)
//        aPlayer.play()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
