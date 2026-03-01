import Foundation
import CoreMotion

/// Wraps CMMotionManager to publish smoothed gyroscope roll and pitch values.
/// Start/stop motion updates by calling start() / stop() from view lifecycle hooks.
@MainActor
class BookMotionManager: ObservableObject {
    @Published var roll: Double = 0    // device tilt around Z → maps to Y-axis book rotation
    @Published var pitch: Double = 0   // device tilt around X → reserved for future use

    private let motionManager = CMMotionManager()

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let motion else { return }
            let newRoll = motion.attitude.roll
            let newPitch = motion.attitude.pitch
            // Jump onto the main actor to update @Published properties.
            // CoreMotion already delivers on .main, but Swift concurrency
            // requires this explicit hop to satisfy @MainActor isolation.
            Task { @MainActor [weak self] in
                guard let self else { return }
                // Low-pass filter: smooths out sensor jitter (80% old, 20% new)
                self.roll = self.roll * 0.8 + newRoll * 0.2
                self.pitch = self.pitch * 0.8 + newPitch * 0.2
            }
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
        // Reset so the next appearance starts from neutral
        roll = 0
        pitch = 0
    }
}
