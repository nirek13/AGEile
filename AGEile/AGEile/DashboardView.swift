import SwiftUI

struct DashboardView: View {
    @ObservedObject var motionManager: MotionManager
    @Binding var isMonitoring: Bool
    
    // Example hard-coded balance index value
    private let balanceIndex: Double = 75.0 // Replace with actual balance index
    
    // Define columns for Masonry layout
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Greeting and Title
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Hi Nirek,")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(.bottom, 10)

                // Balance Index Section (Moved to the top)
                VStack {
                    Text("Balance Index")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("\(balanceIndex, specifier: "%.1f")")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(balanceColor(for: balanceIndex)) // Color coding based on index
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2) // Outline effect
                        )
                }
                .padding(.horizontal) // Add horizontal padding
                
                // User Profile Section (hard-coded values)
                VStack(alignment: .leading, spacing: 5) {
                    Text("User Profile")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // Masonry layout for user data
                    LazyVGrid(columns: columns, spacing: 15) {
                        ProfileItemView(title: "Email", value: "user@example.com", icon: "envelope.fill")
                        ProfileItemView(title: "Age", value: "28", icon: "person.fill")
                        ProfileItemView(title: "Weight", value: "75 kg", icon: "scalemass.fill")
                        ProfileItemView(title: "Height", value: "180 cm", icon: "arrow.up.and.down.circle.fill")
                        ProfileItemView(title: "Steps Today", value: "10,000", icon: "figure.walk")
                        ProfileItemView(title: "Heart Rate", value: "72 bpm", icon: "heart.fill")
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .shadow(color: Color.primary.opacity(0.1), radius: 8, x: 0, y: 4)
                
                // Monitoring Status
                VStack(spacing: 8) {
                    if isMonitoring {
                        Text("Monitoring in Progress")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.vertical, 5)

                        NavigationLink(destination: MotionManagerView(motionManager: motionManager)) {
                            Text("Go to Motion Manager")
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else {
                        Text("Monitoring is not active.")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding(.vertical, 5)

                        Button(action: {
                            isMonitoring = true
                            motionManager.startMonitoring()
                        }) {
                            Text("Start Monitoring")
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
    }
    
    // Function to determine color based on balance index
    private func balanceColor(for index: Double) -> Color {
        switch index {
        case ..<50:
            return .red // Low balance
        case 50..<75:
            return .orange // Medium balance
        case 75...:
            return .green // High balance
        default:
            return .gray // Default case
        }
    }
}

struct ProfileItemView: View {
    var title: String
    var value: String
    var icon: String
    var balanceColor: Color? // Optional balance color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title2)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
                    .foregroundColor(balanceColor ?? .primary) // Use balance color if available
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(motionManager: MotionManager(), isMonitoring: .constant(false))
            .preferredColorScheme(.dark) // Preview in dark mode
    }
}

