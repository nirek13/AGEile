import CoreMotion
import Combine
import UIKit // Import UIKit for haptic feedback

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    private var queue = OperationQueue()
    
    @Published var isTrippingHazardDetected = false
    @Published var isFallDetected = false

    private var fallDetectionTimer: Timer?

    func startMonitoring() {
        // Start monitoring device motion
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }
            
            // Trip hazard detection logic (simplified example)
            if abs(data.gravity.z) > 1.0 {
                DispatchQueue.main.async {
                    self.isTrippingHazardDetected = true
                }
            } else {
                DispatchQueue.main.async {
                    self.isTrippingHazardDetected = false
                }
            }
        }
        
        // Start fall detection with a timer
        fallDetectionTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForFall()
        }
    }

    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        fallDetectionTimer?.invalidate()
    }

    private func checkForFall() {
        // Check device motion data for fall detection
        if let data = motionManager.deviceMotion {
            if abs(data.userAcceleration.z) > 1 {
                DispatchQueue.main.async {
                    self.isFallDetected = true
                    // Trigger haptic feedback
                    self.triggerHapticFeedback()
                    // Prompt the user
                    self.promptUserIfOkay()
                }
                
                // Keep fall detected state on for 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.isFallDetected = false
                }
            }
        }
    }

    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    private func promptUserIfOkay() {
        // Notify the app to display an alert (this needs to be handled in the view)
        NotificationCenter.default.post(name: .fallDetectedNotification, object: nil)
    }
}

// Add an extension for notification name
extension Notification.Name {
    static let fallDetectedNotification = Notification.Name("fallDetectedNotification")
}

