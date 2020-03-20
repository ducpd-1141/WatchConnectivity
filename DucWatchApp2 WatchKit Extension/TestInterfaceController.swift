import WatchKit
import Foundation
import CoreMotion
import Darwin
import WatchConnectivity

extension Date {
    func later(_ otherDate: Date) -> Date {
        return (self as NSDate).laterDate(otherDate)
    }
}

extension CMSensorDataList: Sequence {
    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}


class TestInterfaceController: WKInterfaceController, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    static let MAX_PAYLOAD_COUNT = 200
    static let FAST_POLL_DELAY_SEC = 0.01
    static let SLOW_POLL_DELAY_SEC = 4.0
    static let MAX_EARLIEST_TIME_SEC = -24.0 * 60.0 * 60.0 // a day ago
    
    let wcsession = WCSession.default
    let sr = CMSensorRecorder()
    let summaryDateFormatter = DateFormatter()
    
    var durationValue = 5.0
    var lastStart = Date()
    var timer = Timer()
    var dequeuerState = false
    
    var cmdCount : UInt64 = 0
    var batchNum : UInt64 = 0
    var itemCount = 0
    var latestDate = Date.distantPast
    var errors = 0
    
    var payloadBatch : [NSDictionary] = []
    var newItems = 0
    var newLatestDate : Date!
    var newBatchNum : UInt64!
    
    var haveAccelerometer : Bool!
    var fakeData : Bool = false
    
    @IBOutlet var durationVal: WKInterfaceLabel!
    @IBOutlet var startVal: WKInterfaceButton!
    @IBOutlet var lastStartVal: WKInterfaceLabel!
    @IBOutlet var cmdCountVal: WKInterfaceLabel!
    @IBOutlet var batchNumVal: WKInterfaceLabel!
    @IBOutlet var itemCountVal: WKInterfaceLabel!
    @IBOutlet var latestVal: WKInterfaceLabel!
    @IBOutlet var errorsVal: WKInterfaceLabel!
    @IBOutlet var lastVal: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        summaryDateFormatter.dateFormat = "HH:mm:ss.SSS"
        
        // can we record?
        haveAccelerometer = CMSensorRecorder.isAccelerometerRecordingAvailable()
        startVal.setEnabled(haveAccelerometer)
        lastStartVal.setText(summaryDateFormatter.string(from: lastStart))
        
        // wake up session to phone
        wcsession.delegate = self
        wcsession.activate()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // UI stuff
    @IBAction func fakeDataAction(value: Bool) {
        fakeData = value
    }
    
    @IBAction func durationAction(value: Float) {
        durationValue = Double(value)
        self.durationVal.setText(value.description)
    }
    
    @IBAction func startRecorderAction() {
        lastStart = Date()
        self.lastStartVal.setText(summaryDateFormatter.string(from: lastStart))
        DispatchQueue.global(qos: .background).async {
            self.sr.recordAccelerometer(forDuration: self.durationValue * 60.0)
        }
       
    }
    
    @IBAction func dequeuerAction(value: Bool) {
        dequeuerState = value
        
        if (dequeuerState) {
            latestDate = lastStart
        }
        manageDequeuerTimer(slow: true)
    }
    
    func manageDequeuerTimer(slow : Bool) {
        if (dequeuerState) {
            timer = Timer.scheduledTimer(timeInterval: slow ? TestInterfaceController.SLOW_POLL_DELAY_SEC : TestInterfaceController.FAST_POLL_DELAY_SEC,
                target: self,
                selector: #selector(timerHandler(timer:)),
                userInfo: nil,
                repeats: false)
        } else {
            timer.invalidate()
        }
    }
    
    @objc func timerHandler(timer : Timer) {
        cmdCount += 1
        NSLog("timerHander(\(cmdCount))")
        
        // create a pending update state (only committed if the data gets to phone)
        payloadBatch = []
        newItems = itemCount
        newBatchNum = batchNum
        
        // within a certain time of now
        let earliest = Date().addingTimeInterval(TestInterfaceController.MAX_EARLIEST_TIME_SEC)
        newLatestDate = latestDate.later(earliest)

        
        // real or faking it?
        if (haveAccelerometer! && !fakeData) {
            DispatchQueue.global(qos: .background).async {
                let data = self.sr.accelerometerData(from: self.newLatestDate, to: Date())
                print(data)
            }
//            if (data != nil) {
//
//                for element in data! {
//
//                    let lastElement = element as! CMRecordedAccelerometerData
//
//                    // skip repeated element from prior batch
//                    if (!(lastElement.startDate.compare(newLatestDate) == NSComparisonResult.OrderedDescending)) {
//                        continue;
//                    }
//
//                    // note that we really received an element
//                    newItems++;
//
//                    // this tracks the query date for the next round...
//                    newLatestDate = newLatestDate.laterDate(lastElement.startDate)
//
//                    newBatchNum = lastElement.identifier
//
//                    // next item, here we enqueue it
//                    if (lastElement.startDate.compare(Date.distantPast()) == NSComparisonResult.OrderedAscending) {
//                        NSLog("odd date: " + lastElement.description)
//                    }
//
//                    payloadBatch.append(AccelerometerData(data: lastElement).element)
//
//                    if (payloadBatch.count >= InterfaceController.MAX_PAYLOAD_COUNT) {
//                        break
//                    }
//                }
//            }
        } else {
            newBatchNum = batchNum + 1
            while (payloadBatch.count < TestInterfaceController.MAX_PAYLOAD_COUNT && newLatestDate.compare(Date()) == ComparisonResult.orderedAscending) {
//
//                let data = AccelerometerData(id: cmdCount, date: newLatestDate, x: random(), y: random(), z: random())
                
                newItems += 1
                newLatestDate = newLatestDate.addingTimeInterval(0.02)
                
//                payloadBatch.append(data.element as NSDictionary)
            }
        }
        
        // flush any data
        if (!payloadBatch.isEmpty) {
            
            let output = try! JSONSerialization.data(withJSONObject: payloadBatch,
                                                     options: JSONSerialization.WritingOptions.prettyPrinted)
            
//            self.wcsession.sendMessage([
//                AppGlobals.PHONE_DATA_KEY : output,
//                AppGlobals.PHONE_DATA_BATCH_ID : newBatchNum.description
//                ],
//                                       replyHandler: sendSuccess as? ([String : Any]) -> Void,
//                                       errorHandler: sendError as? (Error) -> Void)
        } else {
            // no data, do a slow poll
            updateUI(slow: true)
        }
    }
    
    func random() -> Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    func sendSuccess(reply : [String : AnyObject]) {
        // commit the updates on success
        batchNum = newBatchNum
        latestDate = newLatestDate
        itemCount = newItems
        
        // reset UI and try again
        updateUI(slow: payloadBatch.count < TestInterfaceController.MAX_PAYLOAD_COUNT)
    }
    
    
    func sendError(error : NSError) {
        errors += 1
        NSLog("sendError[\(errors)](\(error))")
        
        OperationQueue.main.addOperation() {
            self.errorsVal.setText(self.errors.description)
            self.lastVal.setText(error.description)
        }
        
        updateUI(slow: true)
    }
    
    func updateUI(slow : Bool) {
        OperationQueue.main.addOperation() {
            self.cmdCountVal.setText(self.cmdCount.description)
            self.batchNumVal.setText(self.batchNum.description)
            self.itemCountVal.setText(self.itemCount.description)
            self.latestVal.setText(self.summaryDateFormatter.string(from: self.latestDate))
            
            // reset the timer -- slow poll if not full buffer
            self.manageDequeuerTimer(slow: slow)
        }
    }
}
