//
//  InterfaceController.swift
//  DucWatchApp2 WatchKit Extension
//
//  Created by pham.dinh.duc on 12/9/19.
//  Copyright © 2019 Watch. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import UIKit
import WatchConnectivity
import HealthKit
import UserNotifications

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var XLabel: WKInterfaceLabel!
    @IBOutlet var YLabel: WKInterfaceLabel!
    @IBOutlet var ZLabel: WKInterfaceLabel!
    
    @IBOutlet var XLabel1: WKInterfaceLabel!
    @IBOutlet var YLabel1: WKInterfaceLabel!
    @IBOutlet var ZLabel1: WKInterfaceLabel!
    
    
    lazy var motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        manager.accelerometerUpdateInterval = 0.1
        return manager
    }()
    
    lazy var motionGyroscopeManager: CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 0.1
        manager.gyroUpdateInterval = 0.1
        return manager
    }()
    

    var startDate = Date()
    
    
    let healthStore = HKHealthStore()
    let configuration = HKWorkoutConfiguration()
    
    var session: HKWorkoutSession? = nil
    var builder: HKLiveWorkoutBuilder? = nil
    
    let     recorder  =    CMSensorRecorder()
    
    
    let activityManager = CMMotionActivityManager()
    
//    func startWorkoutWithHealthStore(){
//        //        configuration.activityType = .crossTraining
//        configuration.activityType = .walking
//
//        //        configuration.locationType = .indoor
//
//        do {
//            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
//        } catch {
//            print(error)
//            session = nil
//            return
//        }
//
//        builder = session?.associatedWorkoutBuilder()
//
//
//        //Setup session and builder
//
//        session?.delegate = self
//        builder?.delegate = self
//        //
//        //        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
//        //
//        //
//        //        //Start Session & Builder
//        //        session?.startActivity(with: Date())
//        //
//        //
//        //        builder?.beginCollection(withStart: Date()) { (success, error) in
//        //            self.setDurationTimerDate() //Start the elapsed time timer
//        //        }
//
//
//    }
//
    let queue = OperationQueue()
    func startMovementDetection(){
        guard CMSensorRecorder.isAccelerometerRecordingAvailable() else {
            print("Accelerometer data recording is not available")
            return
        }
        print(CMMotionActivityManager.isActivityAvailable())
        let operation = Operation()
        queue.addOperation(operation)
        operation.completionBlock = {
            self.record()
        }
      
        self.activityManager.startActivityUpdates(to: queue, withHandler: {(data) -> Void in
        })
    }
    
    func record() {
         
        if CMSensorRecorder.isAccelerometerRecordingAvailable() {
            print("recorder started")
           
            DispatchQueue.global(qos: .background).async {
                 self.startDate = Date()
                self.recorder.recordAccelerometer(forDuration: 5)
                
            }
            perform(#selector(self.callback), with: nil, afterDelay: 5)
        }
    }
    
    
    @objc func callback(){
        DispatchQueue.global(qos: .background).async { self.getData() }
    }
    
    func getData(){
        print(CMSensorRecorder.authorizationStatus().rawValue)
        print("getData started")
        let list = recorder.accelerometerData(from: Date(timeIntervalSinceNow: -20), to: Date())
        print(list)
        if let list2 = list {
            print("listing data")
//            for data in list{
//                if let accData = data as? CMRecordedAccelerometerData{
//                    let accX = accData.acceleration.x
//                    let timestamp = accData.startDate
//                    //Do something here.
//                    print(accX)
//                    print(timestamp)
//                }
//            }
        }
    }
    
    func getRecordedData()
    {
        print(self.startDate, Date())
        //        DispatchQueue.global(qos: .background).async {
        var accDataList = self.recorder.accelerometerData(from:Date().addingTimeInterval(-10 * 60), to: Date.distantFuture)
        print("AccDataList : \(String(describing: accDataList))")
        if let list = accDataList {
            print(list)
        }
        //        }
    }
    
    
    
    
    func configureWCSession() {
        // Don't need to check isSupport state, because session is always available on WatchOS
        // if WCSession.isSupported() {}
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    let store = HKHealthStore()
    var configurations = HKWorkoutConfiguration()
    var count = 0
    
    
    override func willActivate() {
        super.willActivate()
        UNUserNotificationCenter.current().delegate = self
        startMovementDetection()
        //       startWorkoutWithHealthStore()
        
        let workoutSession = try? HKWorkoutSession(healthStore: store, configuration: configurations)
        workoutSession?.delegate = self
        workoutSession?.startActivity(with: Date())
        
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates()
                        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
                            if let acceleration = data?.acceleration {
                                self.count += 1
//                                print(acceleration)
            
                                self.XLabel.setText(String(format: "%d", self.count))
                                self.YLabel.setText(String(format: "%.2f", acceleration.y))
                                self.ZLabel.setText(String(format: "%.2f", acceleration.z))
                            }
            
            
                        }
        } else {
            XLabel.setText("Not Available")
            YLabel.setText("Not Available")
            ZLabel.setText("Not Available")
        }
    }
    
    
    
    @IBAction func startButtonClicked() {
        
        print("Start BTN clicked")
//        startWorkoutWithHealthStore()
        
    }
    
    //Track Elapsed Time
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder){
        
        print("Collection Started")
        setDurationTimerDate()
        
    }
    
    func setDurationTimerDate(){
        guard let b = builder, let s = session else {
            return
        }
        print(", duration timer started"
        )
        //Create WKInterfaceTimer Date
        let timerDate = Date(timeInterval: -b.elapsedTime, since: Date())
        DispatchQueue.main.async {
            self.count += 1
            self.XLabel.setText(String(format: "%d", self.count))
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update2), userInfo: nil, repeats: true)
            
        }
        //Start or stop timer
        let sessionState = s.state
        //        DispatchQueue.main.async {
        //            sessionState == .running ? self.timer.start() : self.timer.stop()
        //        }
    }
    
    @objc func update2() {
        // Something cool
        print(self.count )
        print(motionManager.accelerometerData?.acceleration)
        self.count += 1
        self.XLabel.setText(String(format: "%d", self.count))
    }
    
    var timer: Timer?
    
    // MARK: HKLiveWorkoutBuilderDelegate
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>){
        
        for type in collectedTypes{
            
            guard let quantityType = type as? HKQuantityType else {
                return // Do nothing
            }
            
            
            let statistics = workoutBuilder.statistics(for: quantityType)
            //let label = labelForQuantityType(quantityType)
            
            // updateLabel(wkLabel, withStatistics: statistics)
            
            print(statistics as Any)
        }
        
        
    }
    
    // MARK: State Control
    func stopWorkout(){
        
        session?.end()
        builder?.endCollection(withEnd: Date()) { (success, error) in
            
            self.builder?.finishWorkout(completion: { (workout, error) in
                self.dismiss()
            })
            
        }
    }
    
    
    override func didDeactivate() {
        super.didDeactivate()
        
        motionManager.stopAccelerometerUpdates()
    }
}

extension InterfaceController: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
    
    
}


extension InterfaceController: WCSessionDelegate, HKLiveWorkoutBuilderDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
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
}

extension InterfaceController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}
