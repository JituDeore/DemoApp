//
//  ContentFilter.swift
//  DemoAPP
//
//  Created by Jitendra-Deore on 20/12/16.
//  Copyright © 2016 Jitendra-Deore. All rights reserved.
//

import UIKit

//Demo commit.
//Branch commit..

@objc class ContentFilter: NSObject {
    
    var finalString: String?
    var titleArray: [String] = []
    var linkArray: [String] = []
    
    var link: String?
    
    func filterTheMessage(str: String) {
        
        finalString = self.skipPhoneNumberFromMessage(str)
        finalString = self.replaceEmailFromMesage(finalString!)
        
        print(str)
    }
    
    func skipPhoneNumberFromMessage(str: String)-> String{

        if (str.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet()) != nil){
            
            var strPhoneNumber: String?
            strPhoneNumber = (str.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet()) as NSArray).componentsJoinedByString("****")
            
            strPhoneNumber = strPhoneNumber?.stringByReplacingOccurrencesOfString("+", withString: "")
            
            return strPhoneNumber ?? ""
        }
        
        return str
    }
    
    
    func replaceEmailFromMesage(str:String)-> String{
        
        var strEmail: String?
        
        if str.containsString("https://www.carlist.my"){
            
            // Then and then get the title from URL..
            
            let  detect = try! NSDataDetector(types: NSTextCheckingType.Link.rawValue)
            let matches = detect.matchesInString(str, options: [], range: NSMakeRange(0, str.characters.count))
            
            for match in matches {
                let url = (str as NSString).substringWithRange(match.range)
                
                let titleStr = self.getTitleFromURL(NSURL.init(string: url))
                
                titleArray.append(titleStr)
                
                return strEmail ?? ""
            }
            
            link = strEmail ?? ""

            print(titleArray)
        
        }else{
            
            let  detect = try! NSDataDetector(types: NSTextCheckingType.Link.rawValue)
            let matches = detect.matchesInString(str, options: [], range: NSMakeRange(0, str.characters.count))
            
            for match in matches {
                let url = (str as NSString).substringWithRange(match.range)
                strEmail = str
                    .stringByReplacingOccurrencesOfString(url, withString: "******")
            
                return strEmail ?? ""
            }
        }
        return ""
    }
    
    func getTitleFromURL(url: NSURL?)->String{
        
        let htmlCode = try! String(contentsOfURL: url!, encoding: NSASCIIStringEncoding)
        let start = "<title>"
        let range1 = (htmlCode as NSString).rangeOfString(start)
        let end = "</title>"
        let range2 = (htmlCode as NSString).rangeOfString(end)
        
        var str: NSString
        str = htmlCode
    
        let finalString =  str.substringWithRange(NSMakeRange(range1.location + 7, range2.location - range1.location - 7))
        
        print("substring is \(finalString)")
        //I Used +7 and -7 in NSMakeRange to eliminate the length of <title> i.e 7
        
        return finalString
        
    }
    
}
