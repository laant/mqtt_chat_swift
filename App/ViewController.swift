//
//  ViewController.swift
//  App
//
//  Created by Laan on 2016. 6. 17..
//  Copyright © 2016년 Laan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MQTTSessionManagerDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var items = [(sender:String, msg:String)]()
    var manager: MQTTSessionManager!
    var mqttSettings:NSDictionary!
    let device_id = UIDevice.currentDevice().identifierForVendor!.UUIDString //UIDevice.currentDevice().name
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let mqttPlistUrl = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent("mqtt.plist")
        mqttSettings = NSDictionary(contentsOfURL: mqttPlistUrl)
        
        
        if manager == nil {
            manager = MQTTSessionManager()
            manager.delegate = self
            manager.subscriptions = ["\(mqttSettings["base"]!)/#": NSNumber(unsignedChar: MQTTQosLevel.ExactlyOnce.rawValue)]
            
            manager.connectTo(
                mqttSettings["host"]! as! String
                , port: Int((mqttSettings["port"])! as! NSNumber)
                , tls: (mqttSettings["tls"]?.boolValue)!
                , keepalive: 60
                , clean: true
                , auth: false
                , user: nil
                , pass: nil
                , willTopic: "\(mqttSettings["base"])/\(device_id)"
                , will: "offline".dataUsingEncoding(NSUTF8StringEncoding)
                , willQos: MQTTQosLevel.ExactlyOnce
                , willRetainFlag: false
                , withClientId: nil
            )
        
        }
        else {
            manager.connectToLast()
        }
        
        manager.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.Initial, context: nil)
        
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        switch manager.state {
        case .Closed:
            print("Closed")
        case .Closing:
            print("Closing")
        case .Connected:
            print("Connected")
            manager.sendData("joins chat".dataUsingEncoding(NSUTF8StringEncoding), topic: "\(mqttSettings["base"]!)/\(device_id)", qos: .ExactlyOnce, retain: false)
        case .Connecting:
            print("Connecting")
        case .Error:
            print("Error")
        case .Starting:
            print("Starting")
        
        }
    }
    
    func connect() {
        manager.connectToLast()
    }
    
    func disconnect() {
        manager.sendData("leaves chat".dataUsingEncoding(NSUTF8StringEncoding), topic: "\(mqttSettings["base"]!)/\(device_id)", qos: .ExactlyOnce, retain: false)
        NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 1.0))
        manager.disconnect()
    }
    
    @IBAction func pressedLongText(sender: AnyObject) {
        manager.sendData("pressedLongText pressedLongTextpressedLongText pressedLongTextpressedLongTextpressedLongText pressedLongTextpressedLongTextpressedLongTextpressedLongText pressedLongTextpressedLongTextpressedLongTextpressedLongTextpressedLongText pressedLongTextpressedLongTextpressedLongTextpressedLongTextpressedLongTextpressedLongText pressedLongTextpressedLongTextpressedLongTextpressedLongTextpressedLongTextpressedLongTextpressedLongText".dataUsingEncoding(NSUTF8StringEncoding), topic: "\(mqttSettings["base"]!)/\(device_id)", qos: .ExactlyOnce, retain: false)
    }
    
    @IBAction func pressedMiddleText(sender: AnyObject) {
        manager.sendData("pressedMiddleTextpressedMiddleText pressedMiddleTextpressedMiddleText pressedMiddleTextpressedMiddleText".dataUsingEncoding(NSUTF8StringEncoding), topic: "\(mqttSettings["base"]!)/\(device_id)", qos: .ExactlyOnce, retain: false)
    }
    
    @IBAction func pressedShortText(sender: AnyObject) {
        let htmlText: String =
            "폰트컬러 블루<font color=\"blue\">파랑</font>선택선택선택선택선택선택선택선택선택선택。<br>" +
                "폰트컬러 레드<font color=\"red\">빨강</font>선택。<br>" +
                "<hr width=\"100%\" size=\"1\" noshade>" +
                "타이드스퀘어<a href=\"http://www.tidesquare.com/\"><strong>홈페이지</strong></a><br>" +
        "CSS Style<strong style=\"color:#663399;\">#663399</strong>...。"
        
        manager.sendData("[html]\(htmlText)".dataUsingEncoding(NSUTF8StringEncoding), topic: "\(mqttSettings["base"]!)/\(device_id)", qos: .ExactlyOnce, retain: false)
    }
    
    @IBAction func pressedImageUrl(sender: AnyObject) {
        let images = [
        "http://file3.funshop.co.kr/abroad/012/6270/thumbnail_1.jpg",
        "http://file3.funshop.co.kr/abroad/012/6258/thumbnail_1.jpg",
        "http://file3.funshop.co.kr/abroad/012/6248/thumbnail_1.jpg",
        "http://file3.funshop.co.kr/abroad/012/6247/thumbnail_1.jpg",
        "http://file3.funshop.co.kr/abroad/012/6246/thumbnail_1.jpg",
        "http://file3.funshop.co.kr/abroad/012/6245/thumbnail_1.jpg",
        "http://file3.funshop.co.kr/abroad/012/6244/thumbnail_1.jpg",
        "http://file3.funshop.co.kr/abroad/012/6243/thumbnail_1.jpg",
        "http://file3.funshop.co.kr/abroad/012/6242/thumbnail_1.jpg",
        "http://file3.funshop.co.kr/abroad/012/6241/thumbnail_1.jpg"
        ]
        
        manager.sendData("[image]\(images[Utility.random(images.count)])".dataUsingEncoding(NSUTF8StringEncoding), topic: "\(mqttSettings["base"]!)/\(device_id)", qos: .ExactlyOnce, retain: false)
    }
    
    // MARK - MQTTSessionManagerDelegate
    func handleMessage(data: NSData!, onTopic topic: String!, retained: Bool) {
        // process received message
        let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        let senderString = topic.substringFromIndex("\(mqttSettings["base"]!)/".endIndex)
        
        print("\(senderString):\(dataString)")
        
        items.append((senderString, dataString as String))
        
        tableView.reloadData()
        scrollToLast()
    }
    
    // MARK: - UITableViewDatasource, UITableViewdelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        
        let cell:TextTalkCell
        
        if item.msg.containsString("[image]") {
            if item.sender == device_id {
                cell = self.tableView.dequeueReusableCellWithIdentifier("send_image")! as! TextTalkCell
            }
            else {
                cell = self.tableView.dequeueReusableCellWithIdentifier("recv_image")! as! TextTalkCell
            }
            
            cell.image_view.downloadByImageUrl(item.msg.substringFromIndex("[image]".endIndex))
        }
        else if item.msg.containsString("[html]") {
            if item.sender == device_id {
                cell = self.tableView.dequeueReusableCellWithIdentifier("send_text")! as! TextTalkCell
            }
            else {
                cell = self.tableView.dequeueReusableCellWithIdentifier("recv_text")! as! TextTalkCell
            }
            
            let htmlText = item.msg.substringFromIndex("[html]".endIndex)
            
            let encodedData = htmlText.dataUsingEncoding(NSUTF8StringEncoding)!
            
            let attributedOptions : [String : AnyObject] = [
                NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding,
                ]
            
            do {
                let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
                
                cell.textView.attributedText = attributedString
                cell.textViewWidthConstraint.constant = UIScreen.mainScreen().bounds.size.width*0.7
                cell.textView.delegate = self
            }
            catch {
                print("error")
            }
        }
        else {
            if item.sender == device_id {
                cell = self.tableView.dequeueReusableCellWithIdentifier("send_text")! as! TextTalkCell
            }
            else {
                cell = self.tableView.dequeueReusableCellWithIdentifier("recv_text")! as! TextTalkCell
            }
            
            cell.textView.text = item.msg
            cell.textViewWidthConstraint.constant = UIScreen.mainScreen().bounds.size.width*0.7
            cell.textView.delegate = self
        }
        
        return cell
    }
    
    // MARK - UITextViewDelegate
    func textViewDidChange(textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
        
        //        let currentOffset = tableView.contentOffset
        //        UIView.setAnimationsEnabled(false)
        //        tableView.beginUpdates()
        //        tableView.endUpdates()
        //        UIView.setAnimationsEnabled(true)
        //        tableView.setContentOffset(currentOffset, animated: false)
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        print("shouldInteractWithURL : \(URL)")
        return true
    }
    
    // MARK - Etc Function
    func scrollToLast() {
        let last_item_index = items.count-1
        let lastIndexPath = NSIndexPath(forItem: last_item_index, inSection: 0)
        
        tableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
    }
}

