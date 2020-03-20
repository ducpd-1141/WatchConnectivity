//
//  ViewController.swift
//  DucWatchApp2
//
//  Created by pham.dinh.duc on 12/9/19.
//  Copyright © 2019 Watch. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController  {
    @IBOutlet weak var accelerometerXLabel: UILabel!
    @IBOutlet weak var accelerometerYLabel: UILabel!
    @IBOutlet weak var accelerometerZLabel: UILabel!
    
    @IBOutlet weak var gyroscopeXLabel: UILabel!
    @IBOutlet weak var gyroscopeYLabel: UILabel!
    
    @IBOutlet weak var gyroscopeZLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    
    @IBAction func sendMessage() {
        sendMessegeToWatch(message: "aaaaa")
    }
    
    func sendMessegeToWatch(message: String) {
        
        if #available(iOS 9.0, *) {
            if !WCSession.default.isReachable {
                let alert = UIAlertController(title: "Failed", message: "Apple Watch is not reachable.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
            } else {
                // The counterpart is not available for living messageing
            }
            
            let message = ["title": "iPhone send a message to Apple Watch", "iPhoneMessage": message]
            WCSession.default.sendMessage(message, replyHandler: { (replyMessage) in
                print(replyMessage)
                DispatchQueue.main.sync {
                    self.messageLabel.text = replyMessage.description
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
}

extension ViewController: WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.sync {
            self.gyroscopeXLabel.text = message["x"] as? String
            self.gyroscopeYLabel.text = message["y"] as? String
            self.gyroscopeZLabel.text = message["z"] as? String
        }
    }
}

