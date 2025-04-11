//
//  AMTimer.swift
//  Airmey
//
//  Created by supertext on 2020/11/23.
//  Copyright © 2020年 airmey. All rights reserved.
//

import Foundation
import UIKit

extension Thread{
    ///the Airmey inner deamon runloop use for timer etc
    ///you can not stop it
    public static let airmey:Thread = {
        let thread =  Thread(target: Airmey(), selector: #selector(Airmey.entry), object: nil)
        thread.start()
        return thread
    }()
    private class Airmey:NSObject{
        @objc func entry(){
            Thread.current.name = "com.airmey.thread.daemon"
            RunLoop.current.add(NSMachPort(), forMode: .default)
            RunLoop.current.run()
        }
    }
}

///the timer function
public protocol AMTimerDelegate:AnyObject{
    func timer(_ timer:AMTimer,repeated times:Int)
}
///wrap on NSTimer
///this is usefull for record repeat times for the timer
///in order to release itself, stop must be call after start
public class AMTimer :NSObject{
    private var impl:Timer?
    ///the timer work in Thread.main otherwise work in Thread.airmey
    public private(set) var thread:Thread
    ///the timeInterval for NSTimer default is 1
    public let interval:TimeInterval
    ///Handles background pause and foreground resume for a timer.
    public let shouldPauseOnBackground:Bool
    ///the current repate times after time runing increasing from zero
    public private(set) var times:Int = 0//reapeatTimes
    ///The current status
    public private(set) var status:Status = .stoped
    ///The enter background saving status
    private var savedStatus: Status = .stoped
    ///the AMTimer's delegate is different between NSTimer's target
    ///the NSTimer's target is AMTimer
    ///the AMTimer's delegate never retain
    public weak var delegate:AMTimerDelegate?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    ///create an AMTimer but not creat NSTimer. this is low consumed
    public init(interval:TimeInterval = 1,thread:Thread = .main,shouldPauseOnBackground:Bool = false) {
        self.thread = thread
        self.interval = interval
        self.shouldPauseOnBackground = shouldPauseOnBackground
        super.init()
        self.setupLifecycleObservers()
    }
    
    private func setupLifecycleObservers() {
        guard shouldPauseOnBackground else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func appDidEnterBackground() {
        savedStatus = status
        pause()
    }

    @objc private func appWillEnterForeground() {
        guard savedStatus == .running else { return }
        start()
    }
    ///start an timer
    ///The status does not change immediately when this method is called in an other thread
    public func start(){
        if self.thread == Thread.current{
            self.innerStart()
            return
        }
        self.perform(#selector(AMTimer.innerStart), on: thread, with: nil, waitUntilDone: false)
    }
    ///pause the timer but not be reset repate times
    ///The status does not change immediately when this method is called in an other thread
    public func pause(){
        if self.thread == Thread.current{
            self.innerPause()
            return
        }
        self.perform(#selector(AMTimer.innerPause), on: thread, with: nil, waitUntilDone: false)
    }
    ///releas NSTimer and reset repate times
    ///this method can break the retain circle between NSTimer and AMTimer
    ///this method is the only way to break retain circle
    ///The status does not change immediately when this method is called in an other thread
    public func stop(){
        if self.thread == Thread.current{
            self.innerStop()
            return
        }
        self.perform(#selector(AMTimer.innerStop), on: thread, with: nil, waitUntilDone: false)
    }
    
    @objc private func innerPause(){
        guard case .running = status else {
            return
        }
        self.impl?.fireDate = .distantFuture
        self.status = .paused
    }
    @objc private func innerStop(){
        if self.status == .stoped{
            return
        }
        self.impl?.invalidate()
        self.times = 0
        self.impl = nil
        self.status = .stoped
    }
    @objc private func innerStart(){
        if self.status == .running {
            return
        }
        if let tmer = self.impl,tmer.isValid{
            tmer.fireDate = Date()
            self.status = .running
            return
        }
        self.impl = Timer(fireAt: Date(), interval: interval, target: self, selector:  #selector(AMTimer.timerFunction(sender:)), userInfo: nil, repeats: true)
        RunLoop.current.add(self.impl!, forMode: .common)
        self.status = .running
    }
    @objc private func timerFunction(sender:Timer){
        self.times = self.times + 1
        self.delegate?.timer(self, repeated: self.times)
    }
    public enum Status{
        case stoped
        case running
        case paused
    }
}

