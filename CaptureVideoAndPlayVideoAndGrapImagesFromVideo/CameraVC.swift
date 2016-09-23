//
//  ViewController.swift
//  Camera
//  Created by Amrit on 9/22/16.
//  Copyright © 2016 Amrit. All rights reserved.

import UIKit
import AVFoundation
import AVKit
import MobileCoreServices

class CameraViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var buttonCapture: UIButton!
    
    private var stillImageOutput: AVCaptureStillImageOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var videoFileOutput: AVCaptureMovieFileOutput?
    private var captureSession: AVCaptureSession!
    private var captureDevice: AVCaptureDevice?
    private var recording = false
    private var videoFilePath: NSURL!
    private var timer = NSTimer()
    private var timeCounter = 0
    private var currentPosition: AVCaptureDevicePosition = .Back
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadCamera()
        buttonCapture.setTitle("Record", forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.navigationBarHidden = true
        self.progressView.progress=0
        
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {(granted: Bool) -> Void in
            if granted {
                
            }
            else {
                
                let cameraUnavailableAlertController = UIAlertController (title: "Camera Unavailable", message: "Please check to see if it is disconnected or in use by another application", preferredStyle: .Alert)
                
                let settingsAction = UIAlertAction(title: "Settings", style: .Destructive) { (_) -> Void in
                    let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
                    if let url = settingsUrl {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
                let cancelAction = UIAlertAction(title: "Okay", style: .Default) { (_) -> Void in
                    
                    self.navigationController?.popViewControllerAnimated(true)
                }
                cameraUnavailableAlertController .addAction(settingsAction)
                cameraUnavailableAlertController .addAction(cancelAction)
                self.presentViewController(cameraUnavailableAlertController , animated: true, completion: nil)
                
                
                
            }
        })
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeAudio, completionHandler: {(granted: Bool) -> Void in
            if granted {
                
            }
            else {
                
                let cameraUnavailableAlertController = UIAlertController (title: "Mic Unavailable", message: "Please check to see if it is disconnected or in use by another application", preferredStyle: .Alert)
                
                let settingsAction = UIAlertAction(title: "Settings", style: .Destructive) { (_) -> Void in
                    let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
                    if let url = settingsUrl {
                        UIApplication.sharedApplication().openURL(url)
                        
                    }
                }
                let cancelAction = UIAlertAction(title: "Okay", style: .Default) { (_) -> Void in
                    
                    
                    self.navigationController?.popViewControllerAnimated(true)
                    
                    
                }
                cameraUnavailableAlertController .addAction(settingsAction)
                cameraUnavailableAlertController .addAction(cancelAction)
                self.presentViewController(cameraUnavailableAlertController , animated: true, completion: nil)
            }
        })
    }
    
    
    func updateLabel(){
        timeCounter += 1
        labelTime.text = "\(timeCounter)/5"
        progressView.progress = progressView.progress + 0.05
        if timeCounter == 5 {
            self.timer.invalidate()
            self.videoFileOutput?.stopRecording()
            buttonCapture.setTitle("Record", forState: .Normal)
        }
    }
    
    private func reloadCamera(){
        captureSession = AVCaptureSession()
        videoFileOutput = AVCaptureMovieFileOutput()
        stillImageOutput = AVCaptureStillImageOutput()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        captureDevice = getDevice(currentPosition)
        if let _ = captureDevice {
            beginSession()
        }
    }
    
    private func beginSession() {
        
        do {
            captureSession.addInput( try AVCaptureDeviceInput(device: captureDevice))
            
        } catch {
            print("Cant get input : \(error)")
        }
        if let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio) {
            
            do {
                captureSession.addInput(try AVCaptureDeviceInput(device: audioDevice))
            }catch {
                print("Cant add audio: \(error)")
            }
        }
        
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewView.layer.addSublayer(previewLayer!)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
    }
    
    @IBAction func takeVideoAction(sender: UIButton) {
        
        if self.recording {
            self.videoFileOutput?.stopRecording()
            sender.setTitle("Record", forState: .Normal)
            self.timer.invalidate()
        }else {
            
            self.timer.invalidate()
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
            self.timeCounter = 0
            self.progressView.progress = 0.0
            
            recording = true
            sender.setTitle("Recording", forState: .Normal)
            if captureSession.canAddOutput(videoFileOutput){
                self.captureSession.addOutput(videoFileOutput)
            }
            
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let filePath = documentsURL.URLByAppendingPathComponent("temp.mov")
            self.videoFilePath = filePath
            print(filePath)
            
            do{
                try NSFileManager.defaultManager().removeItemAtURL(filePath)
            }catch {
                print("Cant delete file: \(error)")
            }
            videoFileOutput?.startRecordingToOutputFileURL(filePath, recordingDelegate: self)
        }
    }
    
    
    @IBAction func changeCamera(sender: UIButton) {
        
        if let recording = videoFileOutput?.recording where recording {
            videoFileOutput?.stopRecording()
            self.recording = false
        }
        
        captureSession.stopRunning()
        do {
            captureSession.removeInput(try AVCaptureDeviceInput(device: self.captureDevice))
        } catch {
            captureSession.startRunning()
            
            print("cant remove capture device from session: \(error)")
            return
        }
        
        switch self.currentPosition {
        case .Back:
            currentPosition = .Front
        default:
            currentPosition = .Back
        }
        reloadCamera()
    }
    
    

    @IBAction func flashSwitch(sender: UIButton) {
        
        flashOnOFF(sender)

    }
    
    func flashOnOFF(sender: UIButton){
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            do {
                
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureTorchMode.On) {
                    device.torchMode = AVCaptureTorchMode.Off
                    sender.setTitle("Flash On", forState: .Normal)
                    
                    
                } else {
                    try device.setTorchModeOnWithLevel(1.0)
                    sender.setTitle("Flash Off", forState: .Normal)
                    
                    
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    private func getDevice(position :AVCaptureDevicePosition)-> AVCaptureDevice{
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == position) {
                    if let device = device as? AVCaptureDevice {
                        return device
                    }
                }
            }
        }
        
        return AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if !recording {
            return
        }
        recording = false
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        return
    }
    
    
    @IBAction func showVideoAction(sender: AnyObject) {
        
        if let link = videoFilePath{
            
            convertVideoWithMediumQuality(link)
            
        }
        
    }
    
    
    
    @IBAction func showImageAction(sender: AnyObject) {
        
        if let link = videoFilePath{
            let images = videoSnapshot(link)
            let vc = storyboard?.instantiateViewControllerWithIdentifier("ShowImageVideoVC") as! ShowImageVideoVC
            vc.totalImage = images
            presentViewController(vc, animated: true, completion: nil)
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
    
    
    func convertVideoWithMediumQuality(inputURL : NSURL){
        
        let VideoFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("mergeVideo\(arc4random()%1000)d").URLByAppendingPathExtension("mp4").absoluteString
        
        if NSFileManager.defaultManager().fileExistsAtPath(VideoFilePath) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(VideoFilePath)
            } catch { }
        }
        
        let savePathUrl =  NSURL(string: VideoFilePath)!
        
        let sourceAsset = AVURLAsset(URL: inputURL, options: nil)
        
        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: sourceAsset, presetName: AVAssetExportPresetMediumQuality)!
        assetExport.outputFileType = AVFileTypeQuickTimeMovie
        assetExport.outputURL = savePathUrl
        assetExport.exportAsynchronouslyWithCompletionHandler { () -> Void in
            
            switch assetExport.status {
            case AVAssetExportSessionStatus.Completed:
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyBoard.instantiateViewControllerWithIdentifier("VideoPlayVC") as! VideoPlayVC
                    vc.url = savePathUrl
                    self.presentViewController(vc, animated: true, completion: nil)
                    
                    
                })
            case  AVAssetExportSessionStatus.Failed:
                //                self.hideActivityIndicator(self.view)
                print("failed \(assetExport.error)")
            case AVAssetExportSessionStatus.Cancelled:
                //                self.hideActivityIndicator(self.view)
                print("cancelled \(assetExport.error)")
            default:
                //                self.hideActivityIndicator(self.view)
                print("complete")
            }
        }
        
    }
    
}
extension CameraViewController: AVPlayerViewControllerDelegate{
    func playerViewControllerDidStopPictureInPicture(playerViewController: AVPlayerViewController) {
        //        playerViewController.dismissViewControllerAnimated(true, completion: nil)
        
        
        
        
    }
    
}
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func compressImage(image:UIImage) -> NSData {
        // Reducing file size to a 10th
        
        var actualHeight : CGFloat = image.size.height
        var actualWidth : CGFloat = image.size.width
        let maxHeight : CGFloat = 1136.0
        let maxWidth : CGFloat = 640.0
        var imgRatio : CGFloat = actualWidth/actualHeight
        let maxRatio : CGFloat = maxWidth/maxHeight
        var compressionQuality : CGFloat = 0.5
        
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
                compressionQuality = 1;
            }
        }
        
        let rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        image.drawInRect(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(img!, compressionQuality);
        UIGraphicsEndImageContext();
        
        return imageData!;
    }
    
    
}




