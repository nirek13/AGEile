import SwiftUI

struct MotionManagerView: View {
    @ObservedObject var motionManager: MotionManager
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 10) {
            // Camera view at the top, with less height
            CameraView()
                .frame(height: 200) // Reduced height for the camera view

            VStack(spacing: 10) {
                // Tripping hazard detection
                if motionManager.isTrippingHazardDetected {
                    Text("⚠️ Tripping Hazard Detected")
                        .foregroundColor(.orange)
                        .font(.headline)
                        .padding()
                        .background(Color.yellow.opacity(0.3))
                        .cornerRadius(10)
                } else {
                    Text("No Tripping Hazard")
                        .foregroundColor(.green)
                        .font(.headline)
                        .padding()
                        .background(Color.green.opacity(0.3))
                        .cornerRadius(10)
                }

                // Fall detection
                if motionManager.isFallDetected {
                    Text("🚨 Fall Detected")
                        .foregroundColor(.red)
                        .font(.headline)
                        .padding()
                        .background(Color.red.opacity(0.3))
                        .cornerRadius(10)
                } else {
                    Text("No Fall Detected")
                        .foregroundColor(.green)
                        .font(.headline)
                        .padding()
                        .background(Color.green.opacity(0.3))
                        .cornerRadius(10)
                }

                // Stop Monitoring Button
                Button(action: {
                    motionManager.stopMonitoring()
                }) {
                    Text("Stop Monitoring")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Motion Manager")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Subscribe to fall detected notification
            NotificationCenter.default.addObserver(forName: .fallDetectedNotification, object: nil, queue: .main) { _ in
                showAlert = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Fall Detected"), message: Text("Are you okay?"), dismissButton: .default(Text("I’m okay!")))
        }
    }
}

