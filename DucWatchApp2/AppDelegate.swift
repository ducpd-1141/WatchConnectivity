//
//  AppDelegate.swift
//  DucWatchApp2
//
//  Created by pham.dinh.duc on 12/9/19.
//  Copyright © 2019 Watch. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreMotion

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
let activityManager = CMMotionActivityManager()
    var startDate = Date()
    let     recorder  =    CMSensorRecorder()
    
var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        WCSession.default.delegate = self
        WCSession.default.activate()
        activityManager.startActivityUpdates(to: .main) { (activity) in
            print(CMSensorRecorder.authorizationStatus() == .authorized)
        }
        
        return true
    }
 

}

extension CMSensorDataList: Sequence {
    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}

extension AppDelegate: WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
                   self.window?.rootViewController?.view.backgroundColor = session.isReachable ? .green : .red
               }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    }
}



