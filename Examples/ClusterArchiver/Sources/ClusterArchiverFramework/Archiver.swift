// swiftlint:disable line_length

import Flynn
import Foundation

public class Archiver: Actor {

    private var files: [URL] = []
    private var maxActive: Int = 0

    private var activeLocal: Int = 0
    private var activeRemote: Int = 0
    private var completedLocal: Int = 0
    private var completedRemote: Int = 0

    private var done = false
    private let start = Date()

    @discardableResult
    public init(directory: String) {
        super.init()

        if let directoryFiles = try? FileManager.default.contentsOfDirectory(atPath: directory) {
            for filePath in directoryFiles {
                if filePath.hasPrefix(".") == false {
                    files.append(URL(fileURLWithPath: "\(directory)/\(filePath)"))
                }
            }

            print("\(files.count) files to process")

            beArchiveMore()
        }
    }

    private func checkDone() {
        if activeLocal == 0 && activeRemote == 0 && files.count == 0 && done == false {
            done = true

            print("\(completedLocal) / \(completedRemote) files in \(abs(start.timeIntervalSinceNow))s, max concurrent \(maxActive)")
        }
    }

    private func _beArchiveMore() {
        let useLocal = false
        let useRemotes = true

        checkDone()

        if useLocal {
            while activeLocal < Flynn.cores {
                guard let file = files.popLast() else { return }

                activeLocal += 1
                if (activeLocal + activeRemote) > maxActive {
                    maxActive = (activeLocal + activeRemote)
                }

                let fileArchiver = FileArchiver(file: file,
                                                local: true)
                fileArchiver.beArchive(self) { (_) in
                    self.activeLocal -= 1
                    self.completedLocal += 1

                    self.beArchiveMore()
                }
            }
        }

        if useLocal == false && useRemotes == true {
            while Flynn.remoteCores <= 0 {
                usleep(500)
            }
        }

        if useRemotes {
            while activeRemote < Flynn.remoteCores {
                guard let file = files.popLast() else { return }

                activeRemote += 1
                if (activeLocal + activeRemote) > maxActive {
                    maxActive = (activeLocal + activeRemote)
                }

                let fileArchiver = FileArchiver(file: file,
                                                local: false)
                fileArchiver.beArchive(self) { (_) in
                    self.activeRemote -= 1
                    self.completedRemote += 1

                    self.beArchiveMore()
                }
            }
        }
    }
}

// MARK: - Autogenerated by FlynnLint
// Contents of file after this marker will be overwritten as needed

extension Archiver {

    @discardableResult
    public func beArchiveMore() -> Self {
        unsafeSend(_beArchiveMore)
        return self
    }

}
