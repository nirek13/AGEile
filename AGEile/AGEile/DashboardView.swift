import SwiftUI

struct DashboardView: View {
    @ObservedObject var motionManager: MotionManager
    @Binding var isMonitoring: Bool

    var body: some View {
        VStack(spacing: 20) {
            if isMonitoring {
                NavigationLink(destination: MotionManagerView(motionManager: motionManager)) {
                    Text("Go to Motion Manager")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                Button(action: {
                    isMonitoring = true
                    motionManager.startMonitoring()
                }) {
                    Text("Start Monitoring")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .navigationTitle("") // No title
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(motionManager: MotionManager(), isMonitoring: .constant(false))
    }
}

