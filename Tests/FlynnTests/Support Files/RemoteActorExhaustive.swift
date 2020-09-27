import XCTest
@testable import Flynn

// The only purpose of this file is to have one of all combinations of remote
// behaviors to help ensure flynnlint generates them all correctly
class RemoteActorExhaustive: RemoteActor {
    private func _beNoArgsNoReturn() { }
    private func _beNoArgsVoidReturn() { }

    private func _beOneArgNoReturn(_ arg0: Int) { }
    private func _beOneArgOneReturn(_ arg0: Int) -> Int { return arg0 }

    private func _beTwoArgsNoReturn(_ arg0: Int, _ arg1: String?) { }
    private func _beTwoArgsTupleReturn(_ arg0: Int, _ arg1: String?) -> String? { return arg1 }
}

// MARK: - Autogenerated by FlynnLint
// Contents of file after this marker will be overwritten as needed

extension RemoteActorExhaustive {

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
    struct BeTwoArgsTupleReturnCodableResponse: Codable {
        let response: String?
    }
    struct BeTwoArgsTupleReturnCodableRequest: Codable {
        let arg0: Int
        let arg1: String?
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
    public func beTwoArgsTupleReturn(_ arg0: Int,
                                     _ arg1: String?,
                                     _ sender: Actor,
                                     _ callback: @escaping (String?) -> Void ) -> Self {
        let msg = BeTwoArgsTupleReturnCodableRequest(arg0: arg0, arg1: arg1)
        // swiftlint:disable:next force_try
        let data = try! JSONEncoder().encode(msg)
        unsafeSendToRemote("RemoteActorExhaustive", "beTwoArgsTupleReturn", data, sender) {
            callback(
                // swiftlint:disable:next force_try
                (try! JSONDecoder().decode(BeTwoArgsTupleReturnCodableResponse.self, from: $0).response)
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
        safeRegisterRemoteBehavior("beTwoArgsTupleReturn") { [unowned self] (data) in
            // swiftlint:disable:next force_try
            let msg = try! JSONDecoder().decode(BeTwoArgsTupleReturnCodableRequest.self, from: data)
            // swiftlint:disable:next force_try
            return try! JSONEncoder().encode(
                BeTwoArgsTupleReturnCodableResponse(response: self._beTwoArgsTupleReturn(msg.arg0, msg.arg1)))
        }
    }
}
