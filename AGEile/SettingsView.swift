import SwiftUI

struct SettingsView: View {
    @AppStorage("name") private var name: String = ""
    @AppStorage("email") private var email: String = ""
    @AppStorage("age") private var age: String = ""
    @AppStorage("weight") private var weight: String = ""
    @AppStorage("height") private var height: String = ""
    @AppStorage("balanceThreshold") private var balanceThreshold: Double = 5.0
    @AppStorage("tripHazardSensitivity") private var tripHazardSensitivity: Double = 0.5
    @AppStorage("alertFrequency") private var alertFrequency: Int = 30
    @AppStorage("emergencyContact") private var emergencyContact: String = ""
    @AppStorage("gaitsTracked") private var gaitsTracked: String = ""
    @AppStorage("imuThreshold") private var imuThreshold: Double = 0.3
    @AppStorage("pressureSensitivity") private var pressureSensitivity: Double = 0.4
    @AppStorage("leftFootAnalysis") private var leftFootAnalysis: Bool = true
    @AppStorage("rightFootAnalysis") private var rightFootAnalysis: Bool = true
    
    @ObservedObject var bluetoothManager: BluetoothManager
    
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
    
    let sensorLocations = ["Ankle", "Lower Shin", "Upper Shin", "Knee", "Thigh", "Hip"]
    
    @State private var searchText: String = ""
    @State private var gaitSectionExpanded: Bool = false
    @State private var bluetoothSectionExpanded: Bool = false
    @State private var sensorSectionExpanded: Bool = false
    @State private var selectedIMU1Location: String = "Ankle"
    @State private var selectedIMU2Location: String = "Hip"
    @State private var batteryLevels: [String: Double] = [
        "Left IMU": 85.0,
        "Right IMU": 92.0,
        "Left Pressure": 78.0,
        "Right Pressure": 80.0
    ]
    
    // Minimalist purple theme
    let darkBackground = Color(red: 0.06, green: 0.06, blue: 0.1)
    let cardBackground = Color(red: 0.1, green: 0.1, blue: 0.15)
    let purpleAccent = Color(red: 0.5, green: 0.3, blue: 0.9)
    let purpleLight = Color(red: 0.7, green: 0.5, blue: 1.0)
    let warningColor = Color(red: 0.95, green: 0.4, blue: 0.6) // Purplish red
    let successColor = Color(red: 0.4, green: 0.8, blue: 0.7)
    
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
            ScrollView {
                VStack(spacing: 24) {
                    // Personal Information
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Personal Information")
                            .font(.headline)
                            .foregroundColor(purpleLight)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 16) {
                            MinimalTextField(icon: "person", placeholder: "Full Name", text: $name)
                            MinimalTextField(icon: "envelope", placeholder: "Email", text: $email)
                            
                            HStack(spacing: 12) {
                                MinimalTextField(icon: "calendar", placeholder: "Age", text: $age)
                                    .keyboardType(.numberPad)
                                    .frame(maxWidth: .infinity)
                                MinimalTextField(icon: "phone", placeholder: "Emergency Contact", text: $emergencyContact)
                                    .keyboardType(.phonePad)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            HStack(spacing: 12) {
                                MinimalTextField(icon: "scalemass", placeholder: "Weight (kg)", text: $weight)
                                    .keyboardType(.decimalPad)
                                    .frame(maxWidth: .infinity)
                                MinimalTextField(icon: "ruler", placeholder: "Height (cm)", text: $height)
                                    .keyboardType(.decimalPad)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(20)
                    .background(cardBackground)
                    .cornerRadius(16)
                    
                    // App Settings
                    VStack(alignment: .leading, spacing: 20) {
                        Text("App Settings")
                            .font(.headline)
                            .foregroundColor(purpleLight)
                            .padding(.horizontal, 4)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            // Alert sensitivity
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Alert Sensitivity")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(balanceThreshold, specifier: "%.1f")")
                                        .font(.caption)
                                        .foregroundColor(purpleAccent)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                
                                Slider(value: $balanceThreshold, in: 1...10, step: 0.1)
                                    .accentColor(purpleAccent)
                            }
                            
                            // Fall sensitivity
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Fall Sensitivity")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(tripHazardSensitivity, specifier: "%.2f")")
                                        .font(.caption)
                                        .foregroundColor(purpleAccent)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                
                                Slider(value: $tripHazardSensitivity, in: 0...1, step: 0.01)
                                    .accentColor(purpleAccent)
                            }
                            
                            // Data update frequency
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Data Update Frequency")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                Picker("", selection: $alertFrequency) {
                                    Text("15 min").tag(15)
                                    Text("30 min").tag(30)
                                    Text("60 min").tag(60)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(20)
                    .background(cardBackground)
                    .cornerRadius(16)
                    
                    // Sensor Settings
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Sensor Configuration")
                                .font(.headline)
                                .foregroundColor(purpleLight)
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    sensorSectionExpanded.toggle()
                                }
                            }) {
                                Image(systemName: sensorSectionExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(purpleAccent)
                            }
                        }
                        .padding(.horizontal, 4)
                        
                        if sensorSectionExpanded {
                            // IMU Configuration
                            VStack(alignment: .leading, spacing: 20) {
                                Text("IMU Sensors")
                                    .font(.subheadline)
                                    .foregroundColor(purpleLight)
                                
                                // Sensor placement
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("IMU 1")
                                            .font(.caption)
                                            .foregroundColor(Color.white.opacity(0.6))
                                        
                                        Menu {
                                            ForEach(sensorLocations, id: \.self) { location in
                                                Button(action: {
                                                    selectedIMU1Location = location
                                                }) {
                                                    Text(location)
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text(selectedIMU1Location)
                                                    .foregroundColor(.white)
                                                Image(systemName: "chevron.down")
                                                    .font(.caption)
                                                    .foregroundColor(purpleAccent)
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("IMU 2")
                                            .font(.caption)
                                            .foregroundColor(Color.white.opacity(0.6))
                                        
                                        Menu {
                                            ForEach(sensorLocations, id: \.self) { location in
                                                Button(action: {
                                                    selectedIMU2Location = location
                                                }) {
                                                    Text(location)
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text(selectedIMU2Location)
                                                    .foregroundColor(.white)
                                                Image(systemName: "chevron.down")
                                                    .font(.caption)
                                                    .foregroundColor(purpleAccent)
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                
                                // IMU Sensitivity
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("IMU Sensitivity")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(imuThreshold, specifier: "%.2f")")
                                            .font(.caption)
                                            .foregroundColor(purpleAccent)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                    
                                    Slider(value: $imuThreshold, in: 0.1...1.0, step: 0.05)
                                        .accentColor(purpleAccent)
                                }
                                
                                Divider()
                                    .background(Color.white.opacity(0.2))
                                
                                // Pressure Sensors
                                Text("Pressure Sensors")
                                    .font(.subheadline)
                                    .foregroundColor(purpleLight)
                                
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Left Foot")
                                            .font(.caption)
                                            .foregroundColor(Color.white.opacity(0.6))
                                        
                                        Toggle("", isOn: $leftFootAnalysis)
                                            .toggleStyle(SwitchToggleStyle(tint: purpleAccent))
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Right Foot")
                                            .font(.caption)
                                            .foregroundColor(Color.white.opacity(0.6))
                                        
                                        Toggle("", isOn: $rightFootAnalysis)
                                            .toggleStyle(SwitchToggleStyle(tint: purpleAccent))
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                
                                // Pressure Sensitivity
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Pressure Sensitivity")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(pressureSensitivity, specifier: "%.2f")")
                                            .font(.caption)
                                            .foregroundColor(purpleAccent)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                    
                                    Slider(value: $pressureSensitivity, in: 0.1...1.0, step: 0.05)
                                        .accentColor(purpleAccent)
                                }
                                
                                Divider()
                                    .background(Color.white.opacity(0.2))
                                
                                // Battery Status
                                Text("Battery Status")
                                    .font(.subheadline)
                                    .foregroundColor(purpleLight)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(Array(batteryLevels.keys.sorted()), id: \.self) { key in
                                        BatteryIndicator(
                                            label: key,
                                            percentage: batteryLevels[key] ?? 0,
                                            accentColor: purpleAccent,
                                            warningColor: warningColor
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(cardBackground)
                    .cornerRadius(16)
                    
                    // Gait Tracking
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Gait Analysis")
                                .font(.headline)
                                .foregroundColor(purpleLight)
                            Spacer()
                            Text("\(gaitsTracked.components(separatedBy: ",").filter { !$0.isEmpty }.count) tracked")
                                .font(.caption)
                                .foregroundColor(purpleAccent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                            Button(action: {
                                withAnimation {
                                    gaitSectionExpanded.toggle()
                                }
                            }) {
                                Image(systemName: gaitSectionExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(purpleAccent)
                            }
                        }
                        .padding(.horizontal, 4)
                        
                        if gaitSectionExpanded {
                            VStack(spacing: 16) {
                                // Search Bar
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(Color.white.opacity(0.5))
                                    
                                    TextField("Search gaits...", text: $searchText)
                                        .foregroundColor(.white)
                                    
                                    if !searchText.isEmpty {
                                        Button(action: { searchText = "" }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(Color.white.opacity(0.5))
                                        }
                                    }
                                }
                                .padding(10)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(10)
                                
                                // Gait List
                                ForEach(filteredGaits, id: \.id) { gait in
                                    HStack(spacing: 12) {
                                        // Tracking Status
                                        Button(action: {
                                            if gaitsTracked.contains("\(gait.id)") {
                                                gaitsTracked = gaitsTracked.replacingOccurrences(of: "\(gait.id)", with: "")
                                                gaitsTracked = gaitsTracked.replacingOccurrences(of: ",,", with: ",")
                                                if gaitsTracked.hasPrefix(",") { gaitsTracked.removeFirst() }
                                            } else {
                                                gaitsTracked += (gaitsTracked.isEmpty ? "" : ",") + "\(gait.id)"
                                            }
                                        }) {
                                            Image(systemName: gaitsTracked.contains("\(gait.id)") ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 22))
                                                .foregroundColor(gaitsTracked.contains("\(gait.id)") ? purpleAccent : Color.white.opacity(0.3))
                                        }
                                        
                                        // Gait Info
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(gait.name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.white)
                                            
                                            Text(gait.description)
                                                .font(.caption)
                                                .foregroundColor(Color.white.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        // Risk Level
                                        Text(gait.level == 0 ? "Normal" : (gait.level == 1 ? "Moderate" : "High"))
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                gait.level == 0 ? Color.green.opacity(0.2) :
                                                (gait.level == 1 ? purpleAccent.opacity(0.2) : warningColor.opacity(0.2))
                                            )
                                            .foregroundColor(
                                                gait.level == 0 ? Color.green :
                                                (gait.level == 1 ? purpleAccent : warningColor)
                                            )
                                            .cornerRadius(4)
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(cardBackground)
                    .cornerRadius(16)
                    
                    // Bluetooth Settings
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Bluetooth Devices")
                                .font(.headline)
                                .foregroundColor(purpleLight)
                            Spacer()
                            Circle()
                                .fill(bluetoothManager.isConnected ? successColor : warningColor)
                                .frame(width: 8, height: 8)
                            Text(bluetoothManager.isConnected ? "Connected" : "Disconnected")
                                .font(.caption)
                                .foregroundColor(bluetoothManager.isConnected ? successColor : warningColor)
                                .padding(.trailing, 4)
                            Button(action: {
                                withAnimation {
                                    bluetoothSectionExpanded.toggle()
                                }
                            }) {
                                Image(systemName: bluetoothSectionExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(purpleAccent)
                            }
                        }
                        .padding(.horizontal, 4)
                        
                        if bluetoothSectionExpanded {
                            VStack(spacing: 16) {
                                // Scan Button
                                if bluetoothManager.isScanning {
                                    HStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: purpleAccent))
                                        Text("Scanning...")
                                            .foregroundColor(Color.white.opacity(0.7))
                                            .padding(.leading, 8)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(12)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(10)
                                } else {
                                    Button(action: {
                                        bluetoothManager.startScanning()
                                    }) {
                                        HStack {
                                            Image(systemName: "bluetooth")
                                            Text("Scan for Devices")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(12)
                                        .background(purpleAccent)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }
                                }
                                
                                // Device List
                                if !bluetoothManager.discoveredDevices.isEmpty {
                                    ForEach(bluetoothManager.discoveredDevices, id: \.identifier) { device in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(device.name ?? "Unknown Device")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                
                                                Text(device.identifier.uuidString.prefix(8) + "...")
                                                    .font(.caption)
                                                    .foregroundColor(Color.white.opacity(0.5))
                                            }
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                bluetoothManager.connect(to: device)
                                            }) {
                                                Text("Pair")
                                                    .font(.caption)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(purpleAccent)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(8)
                                            }
                                        }
                                        .padding(12)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(10)
                                    }
                                }
                                
                                // Connected Device Controls
                                if bluetoothManager.isConnected {
                                    VStack(spacing: 8) {
                                        Text("IMU and pressure sensors connected")
                                            .font(.caption)
                                            .foregroundColor(Color.white.opacity(0.7))
                                        
                                        Button(action: {
                                            bluetoothManager.disconnect()
                                        }) {
                                            Text("Disconnect")
                                                .frame(maxWidth: .infinity)
                                                .padding(12)
                                                .background(Color.white.opacity(0.1))
                                                .foregroundColor(warningColor)
                                                .cornerRadius(10)
                                        }
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(cardBackground)
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(darkBackground.edgesIgnoringSafeArea(.all))
            .navigationBarTitle("Settings", displayMode: .inline)
            .preferredColorScheme(.dark)
            .navigationBarColor(backgroundColor: darkBackground, titleColor: .white)
        }
    }
}

// Custom UI Components
struct MinimalTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    let purpleAccent = Color(red: 0.5, green: 0.3, blue: 0.9)
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(purpleAccent)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .keyboardType(keyboardType)
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

struct BatteryIndicator: View {
    var label: String
    var percentage: Double
    var accentColor: Color
    var warningColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(percentage))%")
                    .font(.caption)
                    .foregroundColor(percentage > 20 ? accentColor : warningColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 3)
                        .opacity(0.3)
                        .foregroundColor(Color.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(percentage)/100.0 * geometry.size.width, geometry.size.width), height: 3)
                        .foregroundColor(percentage > 20 ? accentColor : warningColor)
                }
            }
            .frame(height: 3)
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

// Extension to customize navigation bar
extension View {
    func navigationBarColor(backgroundColor: Color, titleColor: Color) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, titleColor: titleColor))
    }
}

struct NavigationBarModifier: ViewModifier {
    var backgroundColor: Color
    var titleColor: Color
    
    init(backgroundColor: Color, titleColor: Color) {
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(backgroundColor)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(titleColor)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(titleColor)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    func body(content: Content) -> some View {
        content
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(bluetoothManager: BluetoothManager())
    }
}
