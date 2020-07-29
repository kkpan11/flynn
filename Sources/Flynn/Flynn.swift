//
//  Actor.swift
//  Flynn
//
//  Created by Rocco Bowling on 5/10/20.
//  Copyright © 2020 Rocco Bowling. All rights reserved.
//

import Foundation

open class Flynn {

    // MARK: - User Configurable Settings
#if DEBUG
    public static var defaultCheckForUnsafeArguments: Bool = true
#else
    public static var defaultCheckForUnsafeArguments: Bool = false
#endif

#if os(iOS)
    public static var defaultActorAffinity: CoreAffinity = .preferEfficiency
#else
    public static var defaultActorAffinity: CoreAffinity = .none
#endif
    
    private static var schedulers: [Scheduler] = []
    private static var schedulerIdx: Int = 0
    private static var running = AtomicContidion()
    private static var device = Device()

    private static var timeStart: TimeInterval = 0
    private static var registeredActorsCheckRunning = false

    public class func startup() {
        running.checkInactive {

            timeStart = ProcessInfo.processInfo.systemUptime

            for _ in 0..<device.eCores {
                schedulers.append(Scheduler(schedulers.count, .onlyEfficiency))
            }
            for _ in 0..<device.pCores {
                schedulers.append(Scheduler(schedulers.count, .onlyPerformance))
            }
            
        }
    }

    public class func shutdown() {
        running.checkActive {
            // wait until all work is completed
            var runningActors: Int = 1
            while runningActors > 0 {
                runningActors = 0
                for scheduler in schedulers {
                    runningActors += scheduler.count
                }
                usleep(5000)
            }

            // join all of the scheduler threads
            for scheduler in schedulers {
                scheduler.join()
            }
            
            // wait until the registered actors thread ends
            registeredActorsQueue.clear()

            // print all runtime stats
#if DEBUG
            let timeActive = ProcessInfo.processInfo.systemUptime - timeStart
            print("Total runtime: \(Int(timeActive * 1000)) ms")
            for scheduler in schedulers {
                let index = scheduler.index
                let timeActive = Int(scheduler.timeActive * 1000)
                let timeIdle = Int(scheduler.timeIdle * 1000)
                let actorsRun = scheduler.actorsRun
                print("  #\(index): \(actorsRun) actors, active \(timeActive) ms, idle \(timeIdle) ms")
            }
#endif

            // clear all of the schedulers
            schedulers.removeAll()
        }
    }

    public static var cores: Int {
        return device.cores
    }
    
    public static var eCores: Int {
        return device.eCores
    }
    
    public static var pCores: Int {
        return device.pCores
    }
    
    private static var registeredActorsQueue = Queue<Actor>(1024, true, true, true)
    public static func register(_ actor: Actor) {
        // register is responsible for ensuring the actor is retained for a minimum amount of time. this is because
        // actors with chainable behaviors doing this ( Image().beDoSomething() ) Swift will dealloc the actor before
        // the behavior is called. So actors now register themselves when they are init'd, and Flynn ensures it is
        // retained for at least one second before it is allowed to deallocate naturally.
#if os(Linux)
            registeredActorsQueue.enqueue(actor)
#else
            _ = Unmanaged.passRetained(actor).autorelease()
#endif
    }
    
    public static func checkRegisteredActors() {
#if os(Linux)
        // Schedulers call this periodically to ensure registered actors get unregistered after their time is up
        while let actor = registeredActorsQueue.peek() {
            if actor.unsafeUptime < 1.0 {
                break
            }
            registeredActorsQueue.dequeue()
        }
#endif
    }
    
    private static var lastSchedulerIdx: Int = 0
    @inline(__always)
    public static func schedule(_ actor: Actor, _ coreAffinity: CoreAffinity) {
        lastSchedulerIdx = (lastSchedulerIdx + 1) % schedulers.count
        schedulers[lastSchedulerIdx].schedule(actor)
    }

    @inline(__always)
    public static func scheduleOtherThan(_ notThisOne: Scheduler, _ actor: Actor, _ coreAffinity: CoreAffinity) {
        while true {
            lastSchedulerIdx = (lastSchedulerIdx + 1) % schedulers.count
            if lastSchedulerIdx != notThisOne.index {
                schedulers[lastSchedulerIdx].schedule(actor)
                return
            }
        }
    }

    @inline(__always)
    @discardableResult
    public static func scheduleIfIdle(_ actor: Actor, _ coreAffinity: CoreAffinity) -> Bool {
        var matchAffinity: CoreAffinity = .onlyEfficiency
        if actor.unsafeCoreAffinity == .onlyPerformance || actor.unsafeCoreAffinity == .preferPerformance {
            matchAffinity = .onlyPerformance
        }

        // we want to find an idle scheduler which matches our core affinity.
        // If one doesn't exist, then we should return false and not schedule the actor
        for scheduler in schedulers {
            if scheduler.idle && scheduler.affinity == matchAffinity {
                scheduler.schedule(actor)
                return true
            }
        }
        return false
    }
}
