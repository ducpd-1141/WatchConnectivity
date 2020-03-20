//
//  ExtensionDelegate.swift
//  DucWatchApp2 WatchKit Extension
//
//  Created by pham.dinh.duc on 12/9/19.
//  Copyright © 2019 Watch. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    override init() {
        super.init()
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(session.isReachable, activationState.rawValue, "aaa")
    }

       
       /** Called when the installed state of the Companion app changes. */
    func sessionCompanionAppInstalledDidChange(_ session: WCSession) {
        
    }

       
       /** ------------------------- Interactive Messaging ------------------------- */
       
       /** Called when the reachable state of the counterpart app changes. The receiver should check the reachable property on receiving this delegate callback. */
    func sessionReachabilityDidChange(_ session: WCSession) {
        
    }

       
       /** Called on the delegate of the receiver. Will be called on startup if the incoming message caused the receiver to launch. */
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)
    }

       
       /** Called on the delegate of the receiver when the sender sends a message that expects a reply. Will be called on startup if the incoming message caused the receiver to launch. */
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print(message)
    }

       
       /** Called on the delegate of the receiver. Will be called on startup if the incoming message data caused the receiver to launch. */
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        
    }

       
       /** Called on the delegate of the receiver when the sender sends message data that expects a reply. Will be called on startup if the incoming message data caused the receiver to launch. */
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        
    }

       
       /** -------------------------- Background Transfers ------------------------- */
       
       /** Called on the delegate of the receiver. Will be called on startup if an applicationContext is available. */
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
    }

       
       /** Called on the sending side after the user info transfer has successfully completed or failed with an error. Will be called on next launch if the sender was not running when the user info finished. */
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        
    }

       
       /** Called on the delegate of the receiver. Will be called on startup if the user info finished transferring when the receiver was not running. */
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        
    }

       
       /** Called on the sending side after the file transfer has successfully completed or failed with an error. Will be called on next launch if the sender was not running when the transfer finished. */
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        
    }

       
       /** Called on the delegate of the receiver. Will be called on startup if the file finished transferring when the receiver was not running. The incoming file will be located in the Documents/Inbox/ folder when being delivered. The receiver must take ownership of the file by moving it to another location. The system will remove any content that has not been moved when this delegate method returns. */
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        
    }
    func applicationDidEnterBackground() {
        scheduleBackgroundRefresh()
    }
    
    func scheduleBackgroundRefresh() {
            WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date().addingTimeInterval(20), userInfo: nil, scheduledCompletion: self.scheduledCompletion)
    //        WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: Date(timeIntervalSinceNow: 20), userInfo: nil, scheduledCompletion: self.scheduledCompletion)
        }
    
    func scheduledCompletion(error: Error?) {
        if error == nil { print("successfully scheduled application background refresh") }
        else { print("error scheduling background refresh, error: \(error)") }
    }
    
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print(WCSession.default.activationState.rawValue, WCSession.default.isReachable)
    }
    
    func applicationWillEnterForeground() {
        print(WCSession.default.activationState.rawValue, WCSession.default.isReachable)
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("backgroundTasks: Set<WKRefreshBackgroundTask")
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
