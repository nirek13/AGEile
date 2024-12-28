import SwiftUI
import CoreMotion

struct DashboardView: View {
    @ObservedObject var motionManager: MotionManager
    @Binding var isMonitoring: Bool
    
    // User Data from AppStorage
    @AppStorage("email") private var email: String = "user@example.com"
    @AppStorage("age") private var age: String = "28"
    @AppStorage("weight") private var weight: String = "75 kg"
    @AppStorage("height") private var height: String = "180 cm"
    @AppStorage("heartRate") private var heartRate: String = "72 bpm"
    
    @State private var weather: String = "Loading..."
    @State private var temperature: String = "Loading..."
    @State private var hazardousRisk: String = "Loading..."
    @State private var walkingInsights: String = "Loading walking insights..."
    @State private var gaitIrregularities: String = "Loading gait irregularities..."
    
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
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
                .padding(.bottom, 15)
                
                // Key Walking Insights
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        Text("Key Walking Insights & Corrections")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .bold()
                    }

                    Text(walkingInsights)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Gait Irregularities Detected
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        
                        Text("Gait Irregularities Detected")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .bold()
                    }

                    Text(gaitIrregularities)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Weather and Risks
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "cloud.sun.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                        
                        Text("Weather and Risks")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .bold()
                    }

                    HStack {
                        Text("Weather: \(weather)")
                            .font(.body)
                            .foregroundColor(.primary)
                        Text("Temp: \(temperature)°C")
                            .font(.body)
                            .foregroundColor(.blue)
                    }

                    Text("Risk: \(hazardousRisk)")
                        .font(.body)
                        .foregroundColor(hazardousRisk.contains("High") ? .red : .green)
                        .padding()
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Hazardous Situations Detected
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        
                        Text("Hazardous Situations Detected")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .bold()
                    }

                    Text("No hazards detected.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Monitoring Status
                VStack(spacing: 18) {
                    if isMonitoring {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            
                            Text("Monitoring in Progress")
                                .font(.headline)
                                .foregroundColor(.green)
                                .padding(.vertical, 5)
                        }

                        NavigationLink(destination: MotionManagerView(motionManager: motionManager)) {
                            Text("Go to Motion Manager")
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 6)
                        }
                    } else {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                            
                            Text("Monitoring is not active.")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(.vertical, 5)
                        }

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
                                .cornerRadius(12)
                                .shadow(radius: 6)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 15)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal)
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .onAppear {
            fetchWeatherData() // Fetch data when the view appears
            fetchWalkingInsights() // Fetch walking insights
            fetchGaitIrregularities() // Fetch gait irregularities
        }
    }

    func fetchWeatherData() {
        // Simulate weather data
        weather = "Clear Sky"
        temperature = "22"
        hazardousRisk = "Low Risk" // Or "High Risk" based on weather data
    }

    func fetchWalkingInsights() {
        // Simulate walking insights
        walkingInsights = "Walking Pace: Normal | Stride Length: Short" // Placeholder
    }
    
    func fetchGaitIrregularities() {
        // Simulate gait irregularities
        gaitIrregularities = "Irregular gait detected: uneven stride length, possible limp on left leg." // Placeholder
    }
}

struct ProfileItemView: View {
    var title: String
    var value: String
    var icon: String

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
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray5))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

