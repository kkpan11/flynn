import XCTest

class SwiftConcurrencyTestActor: Actor {

    private var x = 0

    internal func _beCheckFlynnTask() -> Int {
        
        // Safe: this is protected by Flynn already
        x += 1
        
        safeTask { continuation in
            if #available(macOS 12.0, *) {
                _ = try! await URLSession.shared.data(from: URL(string: "http://www.apple.com")!)
            }
            
            // Safe: the Flynn actor is "suspended" during this
            // block. While the actor is suspended it will not
            // be scheduled to run in the Flynn runtime, allowing
            // the Swift async context sole access to the thread
            // safe Actor. If is YOUR responsibility to call the
            // continuation call back EXACTLY ONCE, which will
            // resume Flynn operations on this actor. Calling it
            // more than once will result in a fatal error. Not
            // calling it at all will leave this actor suspended
            // forever.
            //
            // Note: you may not call safeTask multiple times in the
            // same behavior.
            self.x += 1
            
            continuation()
        }
        
        // Safe: this is protected because the safeTask
        // block will not run until after the Flynn
        // actor is suspended. This happens when we
        // return from this behaviour's scope
        x += 1
        
        return x
    }
}

@testable import Flynn

class SwiftConcurrencyFlynnTests: XCTestCase {

    override func setUp() {
        Flynn.startup()
    }

    override func tearDown() {
        Flynn.shutdown()
    }

    func test0() {
        let expectation = XCTestExpectation(description: "safeTask")

        let actor = SwiftConcurrencyTestActor()

        actor.beCheckFlynnTask(Flynn.any) { x in
            print("x: \(x)")
        }
        
        actor.beCheckFlynnTask(Flynn.any) { x in
            print("x: \(x)")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    static var allTests = [
        ("test0", test0)
    ]
}
