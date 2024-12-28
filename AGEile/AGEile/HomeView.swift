import SwiftUI

struct HomeView: View {
    @StateObject private var motionManager = MotionManager()
    @State private var isMonitoring = false
  

    var body: some View {
        
        TabView {
            
            DashboardView(motionManager: motionManager, isMonitoring: $isMonitoring)
                .tabItem {
                    Label("Dashboard", systemImage: "house") // Icon for Dashboard
                }
            
            SettingsView(bluetoothManager: BluetoothManager())
                .tabItem {
                    Label("Settings", systemImage: "gear") // Icon for Settings
                }

            DataView()
                .tabItem {
                    Label("Data", systemImage: "chart.bar") // Icon for Data
                }
            ContactsView().tabItem{Label("My AI", systemImage : "app.fill")}
            
            ReminderView()
                .tabItem{Label("Reminders" ,  systemImage: "bell")}
            
            //CommunicationView().tabItem{Label("Device" ,  systemImage: "bubble.left.and.bubble.right.fill")}
        }
        .accentColor(.blue) // Change the selected tab color
       
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

