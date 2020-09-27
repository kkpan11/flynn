import XCTest
@testable import Flynn

// The only purpose of this file is to have one of all combinations of remote
// behaviors to help ensure flynnlint generates them all correctly
class RemoteActorExhaustive: RemoteActor {
    private func _beNoArgsNoReturn() { }
    private func _beNoArgsVoidReturn() { }
    private func _beNoArgsOneReturn() -> Int { return 0 }

    private func _beOneArgNoReturn(_ arg0: Int) { }
    private func _beOneArgOneReturn(_ arg0: Int) -> Int { return arg0 }

    private func _beTwoArgsNoReturn(_ arg0: Int, _ arg1: String?) { }
    private func _beTwoArgsOptionalReturn(_ arg0: Int, _ arg1: String?) -> String? { return arg1 }

    // adding a returnCallback to your behavior signals FlynnLint that this
    // behavior you want to be able to respond to at some point in the future
    // (and not with a direct return value). Simply including this parameter
    // as the last parameter to the behavior is enough to let FlynnLint know
    // what to do.
    private func _beNoArgsDelayedReturn(_ returnCallback: (String) -> Void) { returnCallback("Hello World") }
    private func _beOneArgDelayedReturn(_ string: String, _ returnCallback: (String) -> Void) { returnCallback(string) }

}

// MARK: - Autogenerated by FlynnLint
// Contents of file after this marker will be overwritten as needed

extension RemoteActorExhaustive {

    struct BeNoArgsOneReturnCodableResponse: Codable {
        let response: Int
    }
    struct BeOneArgNoReturnCodableRequest: Codable {
        let arg0: Int
    }
    struct BeOneArgOneReturnCodableResponse: Codable {
        let response: Int
    }
    struct BeOneArgOneReturnCodableRequest: Codable {
        let arg0: Int
    }
    struct BeTwoArgsNoReturnCodableRequest: Codable {
        let arg0: Int
        let arg1: String?
    }
    struct BeTwoArgsOptionalReturnCodableResponse: Codable {
        let response: String?
    }
    struct BeTwoArgsOptionalReturnCodableRequest: Codable {
        let arg0: Int
        let arg1: String?
    }
    struct BeNoArgsDelayedReturnCodableResponse: Codable {
        let response: String
    }
    struct BeOneArgDelayedReturnCodableResponse: Codable {
        let response: String
    }
    struct BeOneArgDelayedReturnCodableRequest: Codable {
        let arg0: String
    }

    @discardableResult
    public func beNoArgsNoReturn() -> Self {
        unsafeSendToRemote("RemoteActorExhaustive", "beNoArgsNoReturn", Data(), nil, nil)
        return self
    }
    @discardableResult
    public func beNoArgsVoidReturn() -> Self {
        unsafeSendToRemote("RemoteActorExhaustive", "beNoArgsVoidReturn", Data(), nil, nil)
        return self
    }
    @discardableResult
    public func beNoArgsOneReturn(_ sender: Actor, _ callback: @escaping (Int) -> Void) -> Self {
        unsafeSendToRemote("RemoteActorExhaustive", "beNoArgsOneReturn", Data(), sender) {
            callback(
                // swiftlint:disable:next force_try
                (try! JSONDecoder().decode(BeNoArgsOneReturnCodableResponse.self, from: $0)).response
            )
        }
        return self
    }
    @discardableResult
    public func beOneArgNoReturn(_ arg0: Int ) -> Self {
        let msg = BeOneArgNoReturnCodableRequest(arg0: arg0)
        // swiftlint:disable:next force_try
        let data = try! JSONEncoder().encode(msg)
        unsafeSendToRemote("RemoteActorExhaustive", "beOneArgNoReturn", data, nil, nil)
        return self
    }
    @discardableResult
    public func beOneArgOneReturn(_ arg0: Int,
                                  _ sender: Actor,
                                  _ callback: @escaping (Int) -> Void ) -> Self {
        let msg = BeOneArgOneReturnCodableRequest(arg0: arg0)
        // swiftlint:disable:next force_try
        let data = try! JSONEncoder().encode(msg)
        unsafeSendToRemote("RemoteActorExhaustive", "beOneArgOneReturn", data, sender) {
            callback(
                // swiftlint:disable:next force_try
                (try! JSONDecoder().decode(BeOneArgOneReturnCodableResponse.self, from: $0).response)
            )
        }
        return self
    }
    @discardableResult
    public func beTwoArgsNoReturn(_ arg0: Int,
                                  _ arg1: String? ) -> Self {
        let msg = BeTwoArgsNoReturnCodableRequest(arg0: arg0, arg1: arg1)
        // swiftlint:disable:next force_try
        let data = try! JSONEncoder().encode(msg)
        unsafeSendToRemote("RemoteActorExhaustive", "beTwoArgsNoReturn", data, nil, nil)
        return self
    }
    @discardableResult
    public func beTwoArgsOptionalReturn(_ arg0: Int,
                                        _ arg1: String?,
                                        _ sender: Actor,
                                        _ callback: @escaping (String?) -> Void ) -> Self {
        let msg = BeTwoArgsOptionalReturnCodableRequest(arg0: arg0, arg1: arg1)
        // swiftlint:disable:next force_try
        let data = try! JSONEncoder().encode(msg)
        unsafeSendToRemote("RemoteActorExhaustive", "beTwoArgsOptionalReturn", data, sender) {
            callback(
                // swiftlint:disable:next force_try
                (try! JSONDecoder().decode(BeTwoArgsOptionalReturnCodableResponse.self, from: $0).response)
            )
        }
        return self
    }
    @discardableResult
    public func beNoArgsDelayedReturn(_ sender: Actor, _ callback: @escaping (String) -> Void) -> Self {
        unsafeSendToRemote("RemoteActorExhaustive", "beNoArgsDelayedReturn", Data(), sender) {
            callback(
                // swiftlint:disable:next force_try
                (try! JSONDecoder().decode(BeNoArgsDelayedReturnCodableResponse.self, from: $0)).response
            )
        }
        return self
    }
    @discardableResult
    public func beOneArgDelayedReturn(_ string: String,
                                      _ sender: Actor,
                                      _ callback: @escaping (String) -> Void ) -> Self {
        let msg = BeOneArgDelayedReturnCodableRequest(arg0: string)
        // swiftlint:disable:next force_try
        let data = try! JSONEncoder().encode(msg)
        unsafeSendToRemote("RemoteActorExhaustive", "beOneArgDelayedReturn", data, sender) {
            callback(
                // swiftlint:disable:next force_try
                (try! JSONDecoder().decode(BeOneArgDelayedReturnCodableResponse.self, from: $0).response)
            )
        }
        return self
    }

    public func unsafeRegisterAllBehaviors() {
        safeRegisterRemoteBehavior("beNoArgsNoReturn") { [unowned self] (_) in
            self._beNoArgsNoReturn()
            return nil
        }
        safeRegisterRemoteBehavior("beNoArgsVoidReturn") { [unowned self] (_) in
            self._beNoArgsVoidReturn()
            return nil
        }
        safeRegisterRemoteBehavior("beNoArgsOneReturn") { [unowned self] (_) in
            // swiftlint:disable:next force_try
            return try! JSONEncoder().encode(
                BeNoArgsOneReturnCodableResponse(response: self._beNoArgsOneReturn()))
        }
        safeRegisterRemoteBehavior("beOneArgNoReturn") { [unowned self] (data) in
            // swiftlint:disable:next force_try
            let msg = try! JSONDecoder().decode(BeOneArgNoReturnCodableRequest.self, from: data)
            self._beOneArgNoReturn(msg.arg0)
            return nil
        }
        safeRegisterRemoteBehavior("beOneArgOneReturn") { [unowned self] (data) in
            // swiftlint:disable:next force_try
            let msg = try! JSONDecoder().decode(BeOneArgOneReturnCodableRequest.self, from: data)
            // swiftlint:disable:next force_try
            return try! JSONEncoder().encode(
                BeOneArgOneReturnCodableResponse(response: self._beOneArgOneReturn(msg.arg0)))
        }
        safeRegisterRemoteBehavior("beTwoArgsNoReturn") { [unowned self] (data) in
            // swiftlint:disable:next force_try
            let msg = try! JSONDecoder().decode(BeTwoArgsNoReturnCodableRequest.self, from: data)
            self._beTwoArgsNoReturn(msg.arg0, msg.arg1)
            return nil
        }
        safeRegisterRemoteBehavior("beTwoArgsOptionalReturn") { [unowned self] (data) in
            // swiftlint:disable:next force_try
            let msg = try! JSONDecoder().decode(BeTwoArgsOptionalReturnCodableRequest.self, from: data)
            // swiftlint:disable:next force_try
            return try! JSONEncoder().encode(
                BeTwoArgsOptionalReturnCodableResponse(response: self._beTwoArgsOptionalReturn(msg.arg0, msg.arg1)))
        }
        safeRegisterDelayedRemoteBehavior("beNoArgsDelayedReturn") { [unowned self] (_, callback) in
            self._beNoArgsDelayedReturn { (returnValue: String) in
                callback(
                    // swiftlint:disable:next force_try
                    try! JSONEncoder().encode(
                        BeNoArgsDelayedReturnCodableResponse(response: returnValue))
                )
            }
        }
        safeRegisterDelayedRemoteBehavior("beOneArgDelayedReturn") { [unowned self] (data, callback) in
            // swiftlint:disable:next force_try
            let msg = try! JSONDecoder().decode(BeOneArgDelayedReturnCodableRequest.self, from: data)
            self._beOneArgDelayedReturn(msg.arg0) { (returnValue: String) in
                callback(
                    // swiftlint:disable:next force_try
                    try! JSONEncoder().encode(
                        BeOneArgDelayedReturnCodableResponse(response: returnValue))
                )
            }
        }
    }
}
