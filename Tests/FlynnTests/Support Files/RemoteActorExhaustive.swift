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
}

// MARK: - Autogenerated by FlynnLint
// Contents of file after this marker will be overwritten as needed

import BinaryCodable

extension RemoteActorExhaustive {

    struct BeNoArgsOneReturnCodableResponse: BinaryEncodable, BinaryDecodable {
        let response: Int

        init(response: Int) {
            self.response = response
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(response)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            response = try container.decode(Int.self)
        }
    }
    struct BeOneArgNoReturnCodableRequest: BinaryEncodable, BinaryDecodable {
        let arg0: Int

        init(arg0: Int) {
            self.arg0 = arg0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(arg0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            arg0 = try container.decode(Int.self)
        }
    }
    struct BeOneArgOneReturnCodableResponse: BinaryEncodable, BinaryDecodable {
        let response: Int

        init(response: Int) {
            self.response = response
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(response)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            response = try container.decode(Int.self)
        }
    }
    struct BeOneArgOneReturnCodableRequest: BinaryEncodable, BinaryDecodable {
        let arg0: Int

        init(arg0: Int) {
            self.arg0 = arg0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(arg0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            arg0 = try container.decode(Int.self)
        }
    }
    struct BeTwoArgsNoReturnCodableRequest: BinaryEncodable, BinaryDecodable {
        let arg0: Int
        let arg1: String?

        init(arg0: Int,
             arg1: String?) {
            self.arg0 = arg0
            self.arg1 = arg1
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(arg0)
            try container.encode(arg1 ?? "FLYNN_NULL", encoding: .utf8, terminator: 0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            arg0 = try container.decode(Int.self)
            let arg1Check = try container.decodeString(encoding: .utf8, terminator: 0)
            arg1 = arg1Check == "FLYNN_NULL" ? nil : arg1Check
        }
    }
    struct BeTwoArgsOptionalReturnCodableResponse: BinaryEncodable, BinaryDecodable {
        let response: String?

        init(response: String?) {
            self.response = response
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(response ?? "FLYNN_NULL", encoding: .utf8, terminator: 0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            let responseCheck = try container.decodeString(encoding: .utf8, terminator: 0)
            response = responseCheck == "FLYNN_NULL" ? nil : responseCheck
        }
    }
    struct BeTwoArgsOptionalReturnCodableRequest: BinaryEncodable, BinaryDecodable {
        let arg0: Int
        let arg1: String?

        init(arg0: Int,
             arg1: String?) {
            self.arg0 = arg0
            self.arg1 = arg1
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(arg0)
            try container.encode(arg1 ?? "FLYNN_NULL", encoding: .utf8, terminator: 0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            arg0 = try container.decode(Int.self)
            let arg1Check = try container.decodeString(encoding: .utf8, terminator: 0)
            arg1 = arg1Check == "FLYNN_NULL" ? nil : arg1Check
        }
    }
    struct BeOneArgTwoReturnCodableResponse: BinaryEncodable, BinaryDecodable {
        let response0: Int
        let response1: String?

        init(response0: Int,
             response1: String?) {
             self.response0 = response0
             self.response1 = response1
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(response0)
            try container.encode(response1 ?? "FLYNN_NULL", encoding: .utf8, terminator: 0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            response0 = try container.decode(Int.self)
            let response1Check = try container.decodeString(encoding: .utf8, terminator: 0)
            response1 = response1Check == "FLYNN_NULL" ? nil : response1Check
        }
    }
    struct BeOneArgTwoReturnCodableRequest: BinaryEncodable, BinaryDecodable {
        let arg0: Int

        init(arg0: Int) {
            self.arg0 = arg0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(arg0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            arg0 = try container.decode(Int.self)
        }
    }
    struct BeNoArgsDelayedReturnCodableResponse: BinaryEncodable, BinaryDecodable {
        let response0: String

        init(response0: String) {
             self.response0 = response0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(response0, encoding: .utf8, terminator: 0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            response0 = try container.decodeString(encoding: .utf8, terminator: 0)
        }
    }
    struct BeOneArgDelayedReturnCodableResponse: BinaryEncodable, BinaryDecodable {
        let response0: String

        init(response0: String) {
             self.response0 = response0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(response0, encoding: .utf8, terminator: 0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            response0 = try container.decodeString(encoding: .utf8, terminator: 0)
        }
    }
    struct BeOneArgDelayedReturnCodableRequest: BinaryEncodable, BinaryDecodable {
        let arg0: String

        init(arg0: String) {
            self.arg0 = arg0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(arg0, encoding: .utf8, terminator: 0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            arg0 = try container.decodeString(encoding: .utf8, terminator: 0)
        }
    }
    struct BeOneArgTwoDelayedReturnCodableResponse: BinaryEncodable, BinaryDecodable {
        let response0: Int
        let response1: String?

        init(response0: Int,
             response1: String?) {
             self.response0 = response0
             self.response1 = response1
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(response0)
            try container.encode(response1 ?? "FLYNN_NULL", encoding: .utf8, terminator: 0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            response0 = try container.decode(Int.self)
            let response1Check = try container.decodeString(encoding: .utf8, terminator: 0)
            response1 = response1Check == "FLYNN_NULL" ? nil : response1Check
        }
    }
    struct BeOneArgTwoDelayedReturnCodableRequest: BinaryEncodable, BinaryDecodable {
        let arg0: Int

        init(arg0: Int) {
            self.arg0 = arg0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(arg0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            arg0 = try container.decode(Int.self)
        }
    }
    struct BeArrayReturnCodableResponse: BinaryEncodable, BinaryDecodable {
        let response0: [String]

        init(response0: [String]) {
             self.response0 = response0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(UInt32(response0.count))
            for item in response0 {
                try container.encode(item, encoding: .utf8, terminator: 0)
            }
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            let response0Count: Int = Int(try container.decode(UInt32.self))
            var response0Array: [String] = []
            for _ in 0..<response0Count {
                response0Array.append(try container.decodeString(encoding: .utf8, terminator: 0))
            }
            response0 = response0Array
        }
    }
    struct BeDataReturnCodableResponse: BinaryEncodable, BinaryDecodable {
        let response0: Data

        init(response0: Data) {
             self.response0 = response0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(UInt32(response0.count))
            try container.encode(sequence: response0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            let response0Count = Int(try container.decode(UInt32.self))
            response0 = try container.decode(length: response0Count)
        }
    }
    struct BeDataArrayReturnCodableResponse: BinaryEncodable, BinaryDecodable {
        let response0: [Data]

        init(response0: [Data]) {
             self.response0 = response0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(UInt32(response0.count))
            for item in response0 {
                try container.encode(UInt32(item.count))
                try container.encode(sequence: item)
            }
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            let response0Count: Int = Int(try container.decode(UInt32.self))
            var response0Array: [Data] = []
            for _ in 0..<response0Count {
                let response0Count = Int(try container.decode(UInt32.self))
                response0Array.append(try container.decode(length: response0Count))
            }
            response0 = response0Array
        }
    }
    struct BeBoolReturnCodableResponse: BinaryEncodable, BinaryDecodable {
        let response0: Bool

        init(response0: Bool) {
             self.response0 = response0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(UInt8(response0 ? 1 : 0))
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            response0 = try container.decode(UInt8.self) == 0 ? false : true
        }
    }
    struct BeBoolArrayReturnCodableResponse: BinaryEncodable, BinaryDecodable {
        let response0: [Bool]

        init(response0: [Bool]) {
             self.response0 = response0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(UInt32(response0.count))
            for item in response0 {
                try container.encode(UInt8(item ? 1 : 0))
            }
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            let response0Count: Int = Int(try container.decode(UInt32.self))
            var response0Array: [Bool] = []
            for _ in 0..<response0Count {
                response0Array.append(try container.decode(UInt8.self) == 0 ? false : true)
            }
            response0 = response0Array
        }
    }
    struct BeFloatReturnCodableResponse: BinaryEncodable, BinaryDecodable {
        let response0: Float

        init(response0: Float) {
             self.response0 = response0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(response0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            response0 = try container.decode(Float.self)
        }
    }
    struct BeFloatArrayReturnCodableResponse: BinaryEncodable, BinaryDecodable {
        let response0: [Float]

        init(response0: [Float]) {
             self.response0 = response0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(UInt32(response0.count))
            for item in response0 {
                try container.encode(item)
            }
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            let response0Count: Int = Int(try container.decode(UInt32.self))
            var response0Array: [Float] = []
            for _ in 0..<response0Count {
                response0Array.append(try container.decode(Float.self))
            }
            response0 = response0Array
        }
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
                (try! BinaryDataDecoder().decode(BeNoArgsOneReturnCodableResponse.self, from: $0)).response
            )
        }
        return self
    }
    @discardableResult
    public func beOneArgNoReturn(_ arg0: Int ) -> Self {
        let msg = BeOneArgNoReturnCodableRequest(arg0: arg0)
        // swiftlint:disable:next force_try
        let data = try! BinaryDataEncoder().encode(msg)
        unsafeSendToRemote("RemoteActorExhaustive", "beOneArgNoReturn", data, nil, nil)
        return self
    }
    @discardableResult
    public func beOneArgOneReturn(_ arg0: Int,
                                  _ sender: Actor,
                                  _ callback: @escaping (Int) -> Void ) -> Self {
        let msg = BeOneArgOneReturnCodableRequest(arg0: arg0)
        // swiftlint:disable:next force_try
        let data = try! BinaryDataEncoder().encode(msg)
        unsafeSendToRemote("RemoteActorExhaustive", "beOneArgOneReturn", data, sender) {
            callback(
                // swiftlint:disable:next force_try
                (try! BinaryDataDecoder().decode(BeOneArgOneReturnCodableResponse.self, from: $0).response)
            )
        }
        return self
    }
    @discardableResult
    public func beTwoArgsNoReturn(_ arg0: Int,
                                  _ arg1: String? ) -> Self {
        let msg = BeTwoArgsNoReturnCodableRequest(arg0: arg0, arg1: arg1)
        // swiftlint:disable:next force_try
        let data = try! BinaryDataEncoder().encode(msg)
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
        let data = try! BinaryDataEncoder().encode(msg)
        unsafeSendToRemote("RemoteActorExhaustive", "beTwoArgsOptionalReturn", data, sender) {
            callback(
                // swiftlint:disable:next force_try
                (try! BinaryDataDecoder().decode(BeTwoArgsOptionalReturnCodableResponse.self, from: $0).response)
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
        let data = try! BinaryDataEncoder().encode(msg)
        unsafeSendToRemote("RemoteActorExhaustive", "beOneArgTwoReturn", data, sender) {
            // swiftlint:disable:next force_try
            let msg = try! BinaryDataDecoder().decode(BeOneArgTwoReturnCodableResponse.self, from: $0)
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
            let response = (try! BinaryDataDecoder().decode(BeNoArgsDelayedReturnCodableResponse.self, from: $0))
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
        let data = try! BinaryDataEncoder().encode(msg)
        unsafeSendToRemote("RemoteActorExhaustive", "beOneArgDelayedReturn", data, sender) {
            // swiftlint:disable:next force_try
            let msg = try! BinaryDataDecoder().decode(BeOneArgDelayedReturnCodableResponse.self, from: $0)
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
        let data = try! BinaryDataEncoder().encode(msg)
        unsafeSendToRemote("RemoteActorExhaustive", "beOneArgTwoDelayedReturn", data, sender) {
            // swiftlint:disable:next force_try
            let msg = try! BinaryDataDecoder().decode(BeOneArgTwoDelayedReturnCodableResponse.self, from: $0)
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
            let response = (try! BinaryDataDecoder().decode(BeArrayReturnCodableResponse.self, from: $0))
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
            let response = (try! BinaryDataDecoder().decode(BeDataReturnCodableResponse.self, from: $0))
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
            let response = (try! BinaryDataDecoder().decode(BeDataArrayReturnCodableResponse.self, from: $0))
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
            let response = (try! BinaryDataDecoder().decode(BeBoolReturnCodableResponse.self, from: $0))
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
            let response = (try! BinaryDataDecoder().decode(BeBoolArrayReturnCodableResponse.self, from: $0))
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
            let response = (try! BinaryDataDecoder().decode(BeFloatReturnCodableResponse.self, from: $0))
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
            let response = (try! BinaryDataDecoder().decode(BeFloatArrayReturnCodableResponse.self, from: $0))
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
            return try! BinaryDataEncoder().encode(
                BeNoArgsOneReturnCodableResponse(response: self._beNoArgsOneReturn()))
        }
        safeRegisterRemoteBehavior("beOneArgNoReturn") { [unowned self] (data) in
            // swiftlint:disable:next force_try
            let msg = try! BinaryDataDecoder().decode(BeOneArgNoReturnCodableRequest.self, from: data)
            self._beOneArgNoReturn(msg.arg0)
            return nil
        }
        safeRegisterRemoteBehavior("beOneArgOneReturn") { [unowned self] (data) in
            // swiftlint:disable:next force_try
            let msg = try! BinaryDataDecoder().decode(BeOneArgOneReturnCodableRequest.self, from: data)
            let response = self._beOneArgOneReturn(msg.arg0)
            let boxedResponse = BeOneArgOneReturnCodableResponse(response: response)
            // swiftlint:disable:next force_try
            return try! BinaryDataEncoder().encode(boxedResponse)
        }
        safeRegisterRemoteBehavior("beTwoArgsNoReturn") { [unowned self] (data) in
            // swiftlint:disable:next force_try
            let msg = try! BinaryDataDecoder().decode(BeTwoArgsNoReturnCodableRequest.self, from: data)
            self._beTwoArgsNoReturn(msg.arg0, msg.arg1)
            return nil
        }
        safeRegisterRemoteBehavior("beTwoArgsOptionalReturn") { [unowned self] (data) in
            // swiftlint:disable:next force_try
            let msg = try! BinaryDataDecoder().decode(BeTwoArgsOptionalReturnCodableRequest.self, from: data)
            let response = self._beTwoArgsOptionalReturn(msg.arg0, msg.arg1)
            let boxedResponse = BeTwoArgsOptionalReturnCodableResponse(response: response)
            // swiftlint:disable:next force_try
            return try! BinaryDataEncoder().encode(boxedResponse)
        }
        safeRegisterRemoteBehavior("beOneArgTwoReturn") { [unowned self] (data) in
            // swiftlint:disable:next force_try
            let msg = try! BinaryDataDecoder().decode(BeOneArgTwoReturnCodableRequest.self, from: data)
            let response = self._beOneArgTwoReturn(msg.arg0)
            let boxedResponse = BeOneArgTwoReturnCodableResponse(
                response0: response.0,
                response1: response.1
            )
            // swiftlint:disable:next force_try
            return try! BinaryDataEncoder().encode(boxedResponse)
        }
        safeRegisterDelayedRemoteBehavior("beNoArgsDelayedReturn") { [unowned self] (_, callback) in
            self._beNoArgsDelayedReturn {
                callback(
                    // swiftlint:disable:next force_try
                    try! BinaryDataEncoder().encode(
                        BeNoArgsDelayedReturnCodableResponse(
                            response0: $0
                        )
                    )
                )
            }
        }
        safeRegisterDelayedRemoteBehavior("beOneArgDelayedReturn") { [unowned self] (data, callback) in
            // swiftlint:disable:next force_try
            let msg = try! BinaryDataDecoder().decode(BeOneArgDelayedReturnCodableRequest.self, from: data)
            self._beOneArgDelayedReturn(msg.arg0) {
                callback(
                    // swiftlint:disable:next force_try
                    try! BinaryDataEncoder().encode(
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
            let msg = try! BinaryDataDecoder().decode(BeOneArgTwoDelayedReturnCodableRequest.self, from: data)
            self._beOneArgTwoDelayedReturn(msg.arg0) {
                callback(
                    // swiftlint:disable:next force_try
                    try! BinaryDataEncoder().encode(
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
                    try! BinaryDataEncoder().encode(
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
                    try! BinaryDataEncoder().encode(
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
                    try! BinaryDataEncoder().encode(
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
                    try! BinaryDataEncoder().encode(
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
                    try! BinaryDataEncoder().encode(
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
                    try! BinaryDataEncoder().encode(
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
                    try! BinaryDataEncoder().encode(
                        BeFloatArrayReturnCodableResponse(
                            response0: $0
                        )
                    )
                )
            }
        }
    }
}
