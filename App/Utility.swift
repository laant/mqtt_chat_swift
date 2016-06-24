//
//  Utility.swift
//  App
//
//  Created by Laan on 2016. 1. 19..
//  Copyright © 2016년 Laan. All rights reserved.
//

import UIKit

class Utility {
    
    // MARK : Screen Size
    static func getScreenSize() -> CGSize {
        let windowRect = UIScreen.mainScreen().bounds
        return windowRect.size
    }
    
    // MARK : check exist image
    static func getFilePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    static func isExistImageFile(imageUrl:String) -> (is_exist:Bool, full_path:String) {
        let arr = imageUrl.componentsSeparatedByString("/")
        var fileName:NSString = ""
        if arr.count > 1 {
            fileName = arr[arr.count - 2] + arr[arr.count - 1]
        }
        else {
            fileName = arr[arr.count - 1]
        }
        
        let filePath = Utility.getFilePath()
        let fileManager = NSFileManager.defaultManager()
        let fullPath = filePath.stringByAppendingString(fileName as String)

        let isExist = fileManager.fileExistsAtPath(fullPath)
        
        return (is_exist:isExist, full_path:fullPath)
        
    }
    
    // MARK: 현재 화면에 존재하는 object들(arr)과 추가하려는 view와 겹치는지 여부(Bool) 리턴
    static func checkIntersectsRect(view:UIView, arr:NSArray) -> Bool {
        
        for compareView in arr {
            if CGRectIntersectsRect(view.frame, compareView.frame) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: block 내부를 delay 후 실행
    static func runAfterDelay(delay: NSTimeInterval, block: dispatch_block_t) {
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(time, dispatch_get_main_queue(), block)
    }
    
    // MARK: 주어진 max값 내에서 임의의 수를 리턴(Int)
    static func random(max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }
    
    // MARK: Alert
    static func alert(text:String, obj:AnyObject) {
        let alertController = UIAlertController(title: "", message: text, preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "확인", style: UIAlertActionStyle.Cancel) { (action: UIAlertAction) -> Void in
            obj.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertController.addAction(cancel)
        
        obj.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: NSUserDefault
    static func saveStorage(key key:String, object:AnyObject) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(object, forKey: key)
        userDefault.synchronize()
    }
    
    static func loadStorage(key:String) -> AnyObject {
        let userDefault = NSUserDefaults.standardUserDefaults()
        return userDefault.objectForKey(key)!
    }
    
//    static func applicationFirstAction() -> Bool {
//        let userDefault = NSUserDefaults.standardUserDefaults()
//        guard let data = userDefault.objectForKey(Constants.SETTING_INIT) else {
//            userDefault.setObject(true, forKey: Constants.SETTING_INIT)
//            return true
//        }
//        
//        let rtn = data as! NSNumber
//        return !rtn.boolValue
//        
//    }
    
}
