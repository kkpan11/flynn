import Flynn
import Foundation
import LzSwift

public class RemoteCompressor: RemoteActor {

    private let compressor = Lzip.Compress(level: .lvl6)
    private var compressed = Data()

    private func _beArchive(_ data: Data) -> Bool {
        do {
            try compressor.compress(input: data, output: &compressed)
        } catch {
            return false
        }
        return true
    }

    private func _beFinish() -> Data {
        compressor.finish(output: &compressed)
        return compressed
    }
}

public class RemoteDecompressor: RemoteActor {

    private let decompressor = Lzip.Decompress()
    private var decompressed = Data()

    private func _beArchive(_ data: Data) -> Bool {
        do {
            try decompressor.decompress(input: data, output: &decompressed)
        } catch {
            return false
        }
        return true
    }

    private func _beFinish() -> Data {
        decompressor.finish(output: &decompressed)
        return decompressed
    }
}

// MARK: - Autogenerated by FlynnLint
// Contents of file after this marker will be overwritten as needed

import BinaryCodable

extension RemoteDecompressor {

    struct BeArchiveCodableResponse: BinaryEncodable, BinaryDecodable {
        let response: Bool

        init(response: Bool) {
            self.response = response
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(UInt8(response ? 1 : 0))
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            response = try container.decode(UInt8.self) == 0 ? false : true
        }
    }
    struct BeArchiveCodableRequest: BinaryEncodable, BinaryDecodable {
        let arg0: Data

        init(arg0: Data) {
            self.arg0 = arg0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(UInt32(arg0.count))
            try container.encode(sequence: arg0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            let arg0Count = Int(try container.decode(UInt32.self))
            arg0 = try container.decode(length: arg0Count)
        }
    }
    struct BeFinishCodableResponse: BinaryEncodable, BinaryDecodable {
        let response: Data

        init(response: Data) {
            self.response = response
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(UInt32(response.count))
            try container.encode(sequence: response)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            let responseCount = Int(try container.decode(UInt32.self))
            response = try container.decode(length: responseCount)
        }
    }

    @discardableResult
    public func beArchive(_ data: Data,
                          _ sender: Actor,
                          _ callback: @escaping (Bool) -> Void ) -> Self {
        let msg = BeArchiveCodableRequest(arg0: data)
        // swiftlint:disable:next force_try
        let data = try! BinaryDataEncoder().encode(msg)
        unsafeSendToRemote("RemoteDecompressor", "beArchive", data, sender) {
            callback(
                // swiftlint:disable:next force_try
                (try! BinaryDataDecoder().decode(BeArchiveCodableResponse.self, from: $0).response)
            )
        }
        return self
    }
    @discardableResult
    public func beFinish(_ sender: Actor, _ callback: @escaping (Data) -> Void) -> Self {
        unsafeSendToRemote("RemoteDecompressor", "beFinish", Data(), sender) {
            callback(
                // swiftlint:disable:next force_try
                (try! BinaryDataDecoder().decode(BeFinishCodableResponse.self, from: $0)).response
            )
        }
        return self
    }

    public func unsafeRegisterAllBehaviors() {
        safeRegisterRemoteBehavior("beArchive") { [unowned self] (data) in
            // swiftlint:disable:next force_try
            let msg = try! BinaryDataDecoder().decode(BeArchiveCodableRequest.self, from: data)
            let response = self._beArchive(msg.arg0)
            let boxedResponse = BeArchiveCodableResponse(response: response)
            // swiftlint:disable:next force_try
            return try! BinaryDataEncoder().encode(boxedResponse)
        }
        safeRegisterRemoteBehavior("beFinish") { [unowned self] (_) in
            // swiftlint:disable:next force_try
            return try! BinaryDataEncoder().encode(
                BeFinishCodableResponse(response: self._beFinish()))
        }
    }
}

extension RemoteCompressor {

    struct BeArchiveCodableResponse: BinaryEncodable, BinaryDecodable {
        let response: Bool

        init(response: Bool) {
            self.response = response
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(UInt8(response ? 1 : 0))
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            response = try container.decode(UInt8.self) == 0 ? false : true
        }
    }
    struct BeArchiveCodableRequest: BinaryEncodable, BinaryDecodable {
        let arg0: Data

        init(arg0: Data) {
            self.arg0 = arg0
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(UInt32(arg0.count))
            try container.encode(sequence: arg0)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            let arg0Count = Int(try container.decode(UInt32.self))
            arg0 = try container.decode(length: arg0Count)
        }
    }
    struct BeFinishCodableResponse: BinaryEncodable, BinaryDecodable {
        let response: Data

        init(response: Data) {
            self.response = response
        }

        func encode(to encoder: BinaryEncoder) throws {
            var container = encoder.container()
            try container.encode(UInt32(response.count))
            try container.encode(sequence: response)
        }

        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            let responseCount = Int(try container.decode(UInt32.self))
            response = try container.decode(length: responseCount)
        }
    }

    @discardableResult
    public func beArchive(_ data: Data,
                          _ sender: Actor,
                          _ callback: @escaping (Bool) -> Void ) -> Self {
        let msg = BeArchiveCodableRequest(arg0: data)
        // swiftlint:disable:next force_try
        let data = try! BinaryDataEncoder().encode(msg)
        unsafeSendToRemote("RemoteCompressor", "beArchive", data, sender) {
            callback(
                // swiftlint:disable:next force_try
                (try! BinaryDataDecoder().decode(BeArchiveCodableResponse.self, from: $0).response)
            )
        }
        return self
    }
    @discardableResult
    public func beFinish(_ sender: Actor, _ callback: @escaping (Data) -> Void) -> Self {
        unsafeSendToRemote("RemoteCompressor", "beFinish", Data(), sender) {
            callback(
                // swiftlint:disable:next force_try
                (try! BinaryDataDecoder().decode(BeFinishCodableResponse.self, from: $0)).response
            )
        }
        return self
    }

    public func unsafeRegisterAllBehaviors() {
        safeRegisterRemoteBehavior("beArchive") { [unowned self] (data) in
            // swiftlint:disable:next force_try
            let msg = try! BinaryDataDecoder().decode(BeArchiveCodableRequest.self, from: data)
            let response = self._beArchive(msg.arg0)
            let boxedResponse = BeArchiveCodableResponse(response: response)
            // swiftlint:disable:next force_try
            return try! BinaryDataEncoder().encode(boxedResponse)
        }
        safeRegisterRemoteBehavior("beFinish") { [unowned self] (_) in
            // swiftlint:disable:next force_try
            return try! BinaryDataEncoder().encode(
                BeFinishCodableResponse(response: self._beFinish()))
        }
    }
}
