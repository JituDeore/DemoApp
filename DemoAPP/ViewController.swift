//
//  ViewController.swift
//  DemoAPP
//
//  Created by Jitendra-Deore on 20/12/16.
//  Copyright © 2016 Jitendra-Deore. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var messageTextView: UITextView!
    let contentFilter = ContentFilter()
    var titleMessage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        
        if messageTextView.text == nil || messageTextView.text.isEmpty{
            let alert = UIAlertController(title: nil, message: "Please enter the message", preferredStyle: .Alert)
            let okAction = UIAlertAction(title:"Ok", style: .Default, handler: {(action: UIAlertAction) -> Void in
            })
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: { _ in })
            
        }else{
            contentFilter.filterTheMessage(messageTextView.text)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

