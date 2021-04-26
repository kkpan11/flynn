// swiftlint:disable file_length

import XCTest

@testable import Flynn

// swiftlint:disable function_body_length

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

    private func _beOneArgTwoReturn(_ arg0: Int) -> (Int, String?) { return (arg0, nil) }

    // adding a returnCallback to your behavior signals FlynnLint that this
    // behavior you want to be able to respond to at some point in the future
    // (and not with a direct return value). Simply including this parameter
    // as the last parameter to the behavior is enough to let FlynnLint know
    // what to do.
    private func _beNoArgsDelayedReturn(_ returnCallback: (String) -> Void) { returnCallback("Hello World") }
    private func _beOneArgDelayedReturn(_ string: String, _ returnCallback: (String) -> Void) { returnCallback(string) }
    private func _beNoArgsDelayedReturnNoArgs(_ returnCallback: () -> Void) { returnCallback() }

    private func _beOneArgTwoDelayedReturn(_ arg0: Int,
                                           _ returnCallback: (Int, String?) -> Void) { returnCallback(arg0, nil) }

    private func _beArrayReturn(_ returnCallback: ([String]) -> Void) { returnCallback(["hello", "world"]) }

    private func _beDataReturn(_ returnCallback: (Data) -> Void) { returnCallback(Data()) }
    private func _beDataArrayReturn(_ returnCallback: ([Data]) -> Void) { returnCallback([Data(), Data()]) }

    private func _beBoolReturn(_ returnCallback: (Bool) -> Void) { returnCallback(true) }
    private func _beBoolArrayReturn(_ returnCallback: ([Bool]) -> Void) { returnCallback([false, true]) }

    private func _beFloatReturn(_ returnCallback: (Float) -> Void) { returnCallback(1.25) }
    private func _beFloatArrayReturn(_ returnCallback: ([Float]) -> Void) { returnCallback([2.5, 5.75]) }

    /*
    private func _beBinaryFloatArrayReturn(_ returnCallback: ([Float]) -> Void) {
        // flynnlint:codable binary
        returnCallback([2.5, 5.75])
    }
     */
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
    struct BeOneArgTwoReturnCodableResponse: Codable {
        let response0: Int
        let response1: String?
    }
    struct BeOneArgTwoReturnCodableRequest: Codable {
        let arg0: Int
    }
    struct BeNoArgsDelayedReturnCodableResponse: Codable {
        let response0: String
    }
    struct BeOneArgDelayedReturnCodableResponse: Codable {
        let response0: String
    }
    struct BeOneArgDelayedReturnCodableRequest: Codable {
        let arg0: String
    }
    struct BeOneArgTwoDelayedReturnCodableResponse: Codable {
        let response0: Int
        let response1: String?
    }
    struct BeOneArgTwoDelayedReturnCodableRequest: Codable {
        let arg0: Int
    }
    struct BeArrayReturnCodableResponse: Codable {
        let response0: [String]
    }
    struct BeDataReturnCodableResponse: Codable {
        let response0: Data
    }
    struct BeDataArrayReturnCodableResponse: Codable {
        let response0: [Data]
    }
    struct BeBoolReturnCodableResponse: Codable {
        let response0: Bool
    }
    struct BeBoolArrayReturnCodableResponse: Codable {
        let response0: [Bool]
    }
    struct BeFloatReturnCodableResponse: Codable {
        let response0: Float
    }
    struct BeFloatArrayReturnCodableResponse: Codable {
        let response0: [Float]
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
    public func beOneArgTwoReturn(_ arg0: Int,
                                  _ sender: Actor,
                                  _ callback: @escaping ((Int, String?)) -> Void ) -> Self {
        let msg = BeOneArgTwoReturnCodableRequest(arg0: arg0)
        // swiftlint:disable:next force_try
        let data = try! JSONEncoder().encode(msg)
        unsafeSendToRemote("RemoteActorExhaustive", "beOneArgTwoReturn", data, sender) {
            // swiftlint:disable:next force_try
            let msg = try! JSONDecoder().decode(BeOneArgTwoReturnCodableResponse.self, from: $0)
            callback((
                msg.response0,
                msg.response1
            ))
        }
        return self
    }
    @discardableResult
    public func beNoArgsDelayedReturn(_ sender: Actor, _ callback: @escaping (String) -> Void) -> Self {
        unsafeSendToRemote("RemoteActorExhaustive", "beNoArgsDelayedReturn", Data(), sender) {
            // swiftlint:disable:next force_try
            let response = (try! JSONDecoder().decode(BeNoArgsDelayedReturnCodableResponse.self, from: $0))
            callback(
                response.response0
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
            // swiftlint:disable:next force_try
            let msg = try! JSONDecoder().decode(BeOneArgDelayedReturnCodableResponse.self, from: $0)
            callback(
                msg.response0
            )
        }
        return self
    }
    @discardableResult
    public func beNoArgsDelayedReturnNoArgs() -> Self {
        unsafeSendToRemote("RemoteActorExhaustive", "beNoArgsDelayedReturnNoArgs", Data(), nil, nil)
        return self
    }
    @discardableResult
    public func beOneArgTwoDelayedReturn(_ arg0: Int,
                                         _ sender: Actor,
                                         _ callback: @escaping (Int, String?) -> Void ) -> Self {
        let msg = BeOneArgTwoDelayedReturnCodableRequest(arg0: arg0)
        // swiftlint:disable:next force_try
        let data = try! JSONEncoder().encode(msg)
        unsafeSendToRemote("RemoteActorExhaustive", "beOneArgTwoDelayedReturn", data, sender) {
            // swiftlint:disable:next force_try
            let msg = try! JSONDecoder().decode(BeOneArgTwoDelayedReturnCodableResponse.self, from: $0)
            callback(
                msg.response0,
                msg.response1
            )
        }
        return self
    }
    @discardableResult
    public func beArrayReturn(_ sender: Actor, _ callback: @escaping ([String]) -> Void) -> Self {
        unsafeSendToRemote("RemoteActorExhaustive", "beArrayReturn", Data(), sender) {
            // swiftlint:disable:next force_try
            let response = (try! JSONDecoder().decode(BeArrayReturnCodableResponse.self, from: $0))
            callback(
                response.response0
            )
        }
        return self
    }
    @discardableResult
    public func beDataReturn(_ sender: Actor, _ callback: @escaping (Data) -> Void) -> Self {
        unsafeSendToRemote("RemoteActorExhaustive", "beDataReturn", Data(), sender) {
            // swiftlint:disable:next force_try
            let response = (try! JSONDecoder().decode(BeDataReturnCodableResponse.self, from: $0))
            callback(
                response.response0
            )
        }
        return self
    }
    @discardableResult
    public func beDataArrayReturn(_ sender: Actor, _ callback: @escaping ([Data]) -> Void) -> Self {
        unsafeSendToRemote("RemoteActorExhaustive", "beDataArrayReturn", Data(), sender) {
            // swiftlint:disable:next force_try
            let response = (try! JSONDecoder().decode(BeDataArrayReturnCodableResponse.self, from: $0))
            callback(
                response.response0
            )
        }
        return self
    }
    @discardableResult
    public func beBoolReturn(_ sender: Actor, _ callback: @escaping (Bool) -> Void) -> Self {
        unsafeSendToRemote("RemoteActorExhaustive", "beBoolReturn", Data(), sender) {
            // swiftlint:disable:next force_try
            let response = (try! JSONDecoder().decode(BeBoolReturnCodableResponse.self, from: $0))
            callback(
                response.response0
            )
        }
        return self
    }
    @discardableResult
    public func beBoolArrayReturn(_ sender: Actor, _ callback: @escaping ([Bool]) -> Void) -> Self {
        unsafeSendToRemote("RemoteActorExhaustive", "beBoolArrayReturn", Data(), sender) {
            // swiftlint:disable:next force_try
            let response = (try! JSONDecoder().decode(BeBoolArrayReturnCodableResponse.self, from: $0))
            callback(
                response.response0
            )
        }
        return self
    }
    @discardableResult
    public func beFloatReturn(_ sender: Actor, _ callback: @escaping (Float) -> Void) -> Self {
        unsafeSendToRemote("RemoteActorExhaustive", "beFloatReturn", Data(), sender) {
            // swiftlint:disable:next force_try
            let response = (try! JSONDecoder().decode(BeFloatReturnCodableResponse.self, from: $0))
            callback(
                response.response0
            )
        }
        return self
    }
    @discardableResult
    public func beFloatArrayReturn(_ sender: Actor, _ callback: @escaping ([Float]) -> Void) -> Self {
        unsafeSendToRemote("RemoteActorExhaustive", "beFloatArrayReturn", Data(), sender) {
            // swiftlint:disable:next force_try
            let response = (try! JSONDecoder().decode(BeFloatArrayReturnCodableResponse.self, from: $0))
            callback(
                response.response0
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
            let response = self._beOneArgOneReturn(msg.arg0)
            let boxedResponse = BeOneArgOneReturnCodableResponse(response: response)
            // swiftlint:disable:next force_try
            return try! JSONEncoder().encode(boxedResponse)
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
            let response = self._beTwoArgsOptionalReturn(msg.arg0, msg.arg1)
            let boxedResponse = BeTwoArgsOptionalReturnCodableResponse(response: response)
            // swiftlint:disable:next force_try
            return try! JSONEncoder().encode(boxedResponse)
        }
        safeRegisterRemoteBehavior("beOneArgTwoReturn") { [unowned self] (data) in
            // swiftlint:disable:next force_try
            let msg = try! JSONDecoder().decode(BeOneArgTwoReturnCodableRequest.self, from: data)
            let response = self._beOneArgTwoReturn(msg.arg0)
            let boxedResponse = BeOneArgTwoReturnCodableResponse(
                response0: response.0,
                response1: response.1
            )
            // swiftlint:disable:next force_try
            return try! JSONEncoder().encode(boxedResponse)
        }
        safeRegisterDelayedRemoteBehavior("beNoArgsDelayedReturn") { [unowned self] (_, callback) in
            self._beNoArgsDelayedReturn {
                callback(
                    // swiftlint:disable:next force_try
                    try! JSONEncoder().encode(
                        BeNoArgsDelayedReturnCodableResponse(
                            response0: $0
                        )
                    )
                )
            }
        }
        safeRegisterDelayedRemoteBehavior("beOneArgDelayedReturn") { [unowned self] (data, callback) in
            // swiftlint:disable:next force_try
            let msg = try! JSONDecoder().decode(BeOneArgDelayedReturnCodableRequest.self, from: data)
            self._beOneArgDelayedReturn(msg.arg0) {
                callback(
                    // swiftlint:disable:next force_try
                    try! JSONEncoder().encode(
                        BeOneArgDelayedReturnCodableResponse(
                            response0: $0
                        )
                    )
                )
            }
        }
        safeRegisterDelayedRemoteBehavior("beNoArgsDelayedReturnNoArgs") { [unowned self] (_, callback) in
            self._beNoArgsDelayedReturnNoArgs {
                callback(Data())
            }
        }
        safeRegisterDelayedRemoteBehavior("beOneArgTwoDelayedReturn") { [unowned self] (data, callback) in
            // swiftlint:disable:next force_try
            let msg = try! JSONDecoder().decode(BeOneArgTwoDelayedReturnCodableRequest.self, from: data)
            self._beOneArgTwoDelayedReturn(msg.arg0) {
                callback(
                    // swiftlint:disable:next force_try
                    try! JSONEncoder().encode(
                        BeOneArgTwoDelayedReturnCodableResponse(
                            response0: $0,
                            response1: $1
                        )
                    )
                )
            }
        }
        safeRegisterDelayedRemoteBehavior("beArrayReturn") { [unowned self] (_, callback) in
            self._beArrayReturn {
                callback(
                    // swiftlint:disable:next force_try
                    try! JSONEncoder().encode(
                        BeArrayReturnCodableResponse(
                            response0: $0
                        )
                    )
                )
            }
        }
        safeRegisterDelayedRemoteBehavior("beDataReturn") { [unowned self] (_, callback) in
            self._beDataReturn {
                callback(
                    // swiftlint:disable:next force_try
                    try! JSONEncoder().encode(
                        BeDataReturnCodableResponse(
                            response0: $0
                        )
                    )
                )
            }
        }
        safeRegisterDelayedRemoteBehavior("beDataArrayReturn") { [unowned self] (_, callback) in
            self._beDataArrayReturn {
                callback(
                    // swiftlint:disable:next force_try
                    try! JSONEncoder().encode(
                        BeDataArrayReturnCodableResponse(
                            response0: $0
                        )
                    )
                )
            }
        }
        safeRegisterDelayedRemoteBehavior("beBoolReturn") { [unowned self] (_, callback) in
            self._beBoolReturn {
                callback(
                    // swiftlint:disable:next force_try
                    try! JSONEncoder().encode(
                        BeBoolReturnCodableResponse(
                            response0: $0
                        )
                    )
                )
            }
        }
        safeRegisterDelayedRemoteBehavior("beBoolArrayReturn") { [unowned self] (_, callback) in
            self._beBoolArrayReturn {
                callback(
                    // swiftlint:disable:next force_try
                    try! JSONEncoder().encode(
                        BeBoolArrayReturnCodableResponse(
                            response0: $0
                        )
                    )
                )
            }
        }
        safeRegisterDelayedRemoteBehavior("beFloatReturn") { [unowned self] (_, callback) in
            self._beFloatReturn {
                callback(
                    // swiftlint:disable:next force_try
                    try! JSONEncoder().encode(
                        BeFloatReturnCodableResponse(
                            response0: $0
                        )
                    )
                )
            }
        }
        safeRegisterDelayedRemoteBehavior("beFloatArrayReturn") { [unowned self] (_, callback) in
            self._beFloatArrayReturn {
                callback(
                    // swiftlint:disable:next force_try
                    try! JSONEncoder().encode(
                        BeFloatArrayReturnCodableResponse(
                            response0: $0
                        )
                    )
                )
            }
        }
    }
}
