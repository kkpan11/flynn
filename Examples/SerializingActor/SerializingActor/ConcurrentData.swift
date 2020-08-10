// An example of how one might create a data storage Actor using Flynn. Changes
// to the actor can happen concurrently, and updates are passed on to SwiftUI
// on the main thread.

import SwiftUI
import Flynn

class ConcurrentData: Actor, Timerable, ObservableObject {

    // Our internal data storage. We make sure this is private, so it can only be set
    // by behavior calls (which will ensure safe concurrency)
    private var count: Int = 0 {
        willSet { objectWillChange() }
    }

    // For the data we want to expose to SwiftUI, we provide an unsafe equivalent.
    // The "unsafe" just means that we need to take responsibility for it being
    // concurrency safe, as someone calling model.unsafeUsername this will execute
    // on their thread, possibly at the same time the actor is executing on a
    // different thread.
    public var unsafeCount: String {
        set {
            if let value = Int(newValue) {
                beSetCount(value)
            }
        }
        get { return "\(count)" }
    }

    // Our data is garaunteed to change on a background thread, so we need to ensure
    // that when we tell SwiftUI that our data has changed that it does so on the
    // main thread.
    private func objectWillChange() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

    // Here we define our behaviors. Only behaviors are allowed to write to our
    // private storage, ensuring that we will never have data races.
    private func _beSetCount(_ value: Int) {
        count = value
    }

    // We want this data to serialize and deserialize on demand. For this example
    // we are just going to save the state to user defaults
    private func _beSaveState() {
        UserDefaults.standard.set(count, forKey: "count")
    }

    private func _beLoadState() {
        if let value = UserDefaults.standard.value(forKey: "count") as? Int {
            count = value
        }
    }

    // To make this interesting, we are going to change the value periodically. The
    // user can still freely edit the text field while the count is incrementing
    private func _beTimerFired(_ timer: Flynn.Timer, _ args: TimerArgs) {
        count += 1
    }

    override init() {
        super.init()

        Flynn.Timer(timeInterval: 0.5, repeats: true, self)
    }
}

// MARK: - Autogenerated by FlynnLint
// Contents of file after this marker will be overwritten as needed

extension ConcurrentData {

    @discardableResult
    public func beSetCount(_ value: Int) -> Self {
        unsafeSend { self._beSetCount(value) }
        return self
    }
    @discardableResult
    public func beSaveState() -> Self {
        unsafeSend(_beSaveState)
        return self
    }
    @discardableResult
    public func beLoadState() -> Self {
        unsafeSend(_beLoadState)
        return self
    }
    @discardableResult
    public func beTimerFired(_ timer: Flynn.Timer, _ args: TimerArgs) -> Self {
        unsafeSend { self._beTimerFired(timer, args) }
        return self
    }

}
