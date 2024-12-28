import SwiftUI

struct SettingsView: View {
    @AppStorage("name") private var name: String = ""
    @AppStorage("email") private var email: String = ""
    @AppStorage("age") private var age: String = ""
    @AppStorage("weight") private var weight: String = ""
    @AppStorage("height") private var height: String = ""
    @AppStorage("heartRate") private var heartRate: String = ""
    @AppStorage("balanceThreshold") private var balanceThreshold: Double = 5.0 // Default threshold
    @AppStorage("tripHazardSensitivity") private var tripHazardSensitivity: Double = 0.5 // Default sensitivity
    @AppStorage("alertFrequency") private var alertFrequency: Int = 30 // In minutes
    @AppStorage("emergencyContact") private var emergencyContact: String = "" // Emergency contact info
    
    // Store the gaits tracked as a string
    @AppStorage("gaitsTracked") private var gaitsTracked: String = ""
    
    @ObservedObject var bluetoothManager: BluetoothManager
    
    // List of gaits with problem levels, each gait has an ID
    let gaits = [
        (id: 0, name: "Normal Gait", description: "Smooth, rhythmic walking pattern", level: 0),
        (id: 1, name: "Antalgic Gait", description: "Compensates for pain, limp", level: 1),
        (id: 2, name: "Spastic Gait", description: "Stiff, jerky movements", level: 2),
        (id: 3, name: "Ataxic Gait", description: "Uncoordinated, irregular walking", level: 2),
        (id: 4, name: "Parkinsonian Gait", description: "Shuffling, reduced arm swing", level: 1),
        (id: 5, name: "Trendelenburg Gait", description: "Pelvis drops on opposite side", level: 1),
        (id: 6, name: "Steppage Gait", description: "High stepping due to foot drop", level: 2),
        (id: 7, name: "Waddling Gait", description: "Side-to-side swaying", level: 1),
        (id: 8, name: "Shuffling Gait", description: "Difficulty lifting feet, tripping risk", level: 2),
        (id: 9, name: "Foot Drop Gait", description: "Feet dragged, scuffed", level: 2),
        (id: 10, name: "Hip-Hiking Gait", description: "Lifting hip to clear foot", level: 1),
        (id: 11, name: "Scissoring Gait", description: "Legs cross over each other", level: 2),
        (id: 12, name: "Shuffling with Stooped Posture", description: "Stooped posture, balance issues", level: 2),
        (id: 13, name: "Cerebellar Gait", description: "Wide-based, uncoordinated", level: 2),
        (id: 14, name: "Unilateral Neglect Gait", description: "One-sided walking, instability", level: 2)
    ]
    
    @State private var searchText: String = ""
    @State private var gaitSectionExpanded: Bool = false
    @State private var bluetoothSectionExpanded: Bool = false
    
    // Filtered list based on search query
    var filteredGaits: [(id: Int, name: String, description: String, level: Int)] {
        if searchText.isEmpty {
            return gaits
        } else {
            return gaits.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Personal Information").font(.headline)) {
                    TextField("Full Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 10)
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 10)
                    TextField("Age", text: $age)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 10)
                    TextField("Weight (kg)", text: $weight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 10)
                    TextField("Height (cm)", text: $height)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 10)
                    TextField("Heart Rate (bpm)", text: $heartRate)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 10)
                    TextField("Emergency Contact", text: $emergencyContact)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 10)
                }
                
                Section(header: Text("App Settings").font(.headline)) {
                    VStack(alignment: .leading) {
                        Text("Balance Threshold")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Slider(value: $balanceThreshold, in: 1...10, step: 0.1) {
                            Text("Balance Threshold")
                        }
                        Text("Sensitivity: \(balanceThreshold, specifier: "%.1f")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                    
                    VStack(alignment: .leading) {
                        Text("Trip Hazard Sensitivity")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Slider(value: $tripHazardSensitivity, in: 0...1, step: 0.01) {
                            Text("Trip Hazard Sensitivity")
                        }
                        Text("Sensitivity: \(tripHazardSensitivity, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                    
                    VStack(alignment: .leading) {
                        Text("Alert Frequency (minutes)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Picker("Alert Frequency", selection: $alertFrequency) {
                            ForEach([15, 30, 60], id: \.self) { frequency in
                                Text("\(frequency) min").tag(frequency)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                // Gait Tracking Section
                DisclosureGroup(
                    isExpanded: $gaitSectionExpanded,
                    content: {
                        // Search bar for gait filtering
                        SearchBar(text: $searchText)
                        
                        ForEach(filteredGaits, id: \.id) { gait in
                            VStack {
                                HStack {
                                    Text(gait.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(gait.description)
                                        .font(.subheadline)
                                        .foregroundColor(gait.level == 2 ? .red : (gait.level == 1 ? Color.blue : .gray))
                                }
                                .padding(.bottom, 5)
                                
                                Button(action: {
                                    // Toggle tracking/untracking
                                    if gaitsTracked.contains("\(gait.id)") {
                                        // Remove from tracked list
                                        gaitsTracked = gaitsTracked.replacingOccurrences(of: "\(gait.id)", with: "")
                                        gaitsTracked = gaitsTracked.replacingOccurrences(of: ",,", with: ",") // Fix double commas
                                        if gaitsTracked.hasPrefix(",") { gaitsTracked.removeFirst() } // Remove leading comma
                                    } else {
                                        // Add to tracked list
                                        gaitsTracked += (gaitsTracked.isEmpty ? "" : ",") + "\(gait.id)"
                                    }
                                }) {
                                    Text(gaitsTracked.contains("\(gait.id)") ? "Untrack this gait" : "Track this gait")
                                        .font(.subheadline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(gaitsTracked.contains("\(gait.id)") ? Color.red : Color.purple)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding(.top, 5)
                                        .shadow(radius: 5)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(15)
                            .padding(.bottom, 10)
                        }
                    },
                    label: {
                        Text("Gait Tracking")
                            .font(.headline)
                            .foregroundColor(.primary)
                    })
                
                // Bluetooth Settings Section
                DisclosureGroup(
                    isExpanded: $bluetoothSectionExpanded,
                    content: {
                        // Bluetooth Scanning Status
                        if bluetoothManager.isScanning {
                            Text("Scanning for Bluetooth devices...")
                                .foregroundColor(.gray)
                        } else {
                            Button(action: {
                                bluetoothManager.startScanning()
                            }) {
                                Text("Start Scanning")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                        
                        // Displaying discovered device names
                        if !bluetoothManager.discoveredDevices.isEmpty {
                            ForEach(bluetoothManager.discoveredDevices, id: \.identifier) { device in
                                Text(device.name ?? "Unknown Device")
                                    .padding(.vertical, 5)
                                
                                // Device Connection Button
                                Button(action: {
                                    bluetoothManager.connect(to: device)
                                }) {
                                    Label("Pair", systemImage: "hand.thumbsup.fill")
                                        .font(.body)
                                        .padding(10)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .shadow(radius: 3)
                                }
                            }
                        }
                        
                        // Connection Status
                        VStack(spacing: 12) {
                            Text(bluetoothManager.isConnected ? "Connected" : "Disconnected")
                                .font(.title3)
                                .bold()
                                .foregroundColor(bluetoothManager.isConnected ? .green : .red)
                            
                            Button(action: {
                                if bluetoothManager.isConnected {
                                    bluetoothManager.disconnect()
                                }
                            }) {
                                Label(
                                    bluetoothManager.isConnected ? "Disconnect" : "Scanning...",
                                    systemImage: bluetoothManager.isConnected ? "arrow.down.circle.fill" : "magnifyingglass.circle.fill"
                                )
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(bluetoothManager.isConnected ? Color.red : Color.blue.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.gray.opacity(0.15), radius: 5, x: 0, y: 3)
                    },
                    label: {
                        Text("Bluetooth Settings")
                            .font(.headline)
                            .foregroundColor(.primary)
                    })
            }
        }
    }
    
    // SearchBar component
    struct SearchBar: View {
        @Binding var text: String
        
        var body: some View {
            TextField("Search Gaits", text: $text)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(bluetoothManager:BluetoothManager())
    }
}

