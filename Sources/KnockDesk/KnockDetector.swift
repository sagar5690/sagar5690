import AVFoundation
import Foundation

final class KnockDetector {
    var onKnock: (() -> Void)?

    private let engine = AVAudioEngine()
    private var recentPeaks: [Date] = []
    private var noiseFloor: Float = 0.01
    private var isRunning = false

    func start() {
        guard !isRunning else { return }

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)

        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.process(buffer: buffer)
        }

        do {
            try AVAudioSessionShim.shared.configureIfPossible()
            try engine.start()
            isRunning = true
        } catch {
            print("KnockDetector start error: \(error)")
        }
    }

    func stop() {
        guard isRunning else { return }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        isRunning = false
    }

    private func process(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)
        if frameCount == 0 { return }

        var peak: Float = 0
        for i in 0..<frameCount {
            peak = max(peak, abs(channelData[i]))
        }

        // Adaptive noise floor for different rooms/laptops
        noiseFloor = (noiseFloor * 0.95) + (peak * 0.05)
        let threshold = max(0.02, noiseFloor * 4.0)

        if peak > threshold {
            registerPeak()
        }
    }

    private func registerPeak() {
        let now = Date()
        recentPeaks.append(now)

        recentPeaks = recentPeaks.filter {
            now.timeIntervalSince($0) < 1.0
        }

        // Simple double-knock pattern: 2 peaks between 80ms and 450ms apart
        if recentPeaks.count >= 2,
           let last = recentPeaks.last,
           let previous = recentPeaks.dropLast().last {
            let delta = last.timeIntervalSince(previous)
            if delta > 0.08 && delta < 0.45 {
                recentPeaks.removeAll()
                DispatchQueue.main.async { [weak self] in
                    self?.onKnock?()
                }
            }
        }
    }
}

/// AVAudioSession is iOS-only, but we keep a shim so this file stays simple for shared logic.
enum AVAudioSessionShim {
    static let shared = AVAudioSessionShimImpl()

    final class AVAudioSessionShimImpl {
        func configureIfPossible() throws {
            // No-op on macOS.
        }
    }
}
