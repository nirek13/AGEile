import SwiftUI

struct HomeView: View {
    @StateObject private var motionManager = MotionManager()
    @State private var isMonitoring = false
    
    // Define theme colors
    private let primaryColor = Color(hex: "0A84FF") // Vibrant blue
    private let backgroundColor = Color(hex: "121212") // Deep dark background
    private let secondaryBackgroundColor = Color(hex: "1E1E1E") // Slightly lighter dark
    private let accentColor = Color(hex: "FF375F") // Vibrant pink/red accent
    private let highlightColor = Color(hex: "32D74B") // Vibrant green
    private let textColor = Color.white
    private let secondaryTextColor = Color(hex: "ADADAD") // Light gray
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [backgroundColor, Color(hex: "0F0F14")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Main content
            TabView {
                DashboardView(motionManager: motionManager, isMonitoring: $isMonitoring)
                    .tabItem {
                        Label("Dashboard", systemImage: "house.fill")
                    }
                
                SettingsView(bluetoothManager: BluetoothManager())
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                
                DataView()
                    .tabItem {
                        Label("Data", systemImage: "chart.bar.fill")
                    }
                
                ContactsView()
                    .tabItem {
                        Label("Connect", systemImage: "message.fill")
                    }
                
                CareView()
                    .tabItem {
                        Label("Care", systemImage: "figure.walk.motion.trianglebadge.exclamationmark")
                    }
            }
            .accentColor(primaryColor)
        }
        .preferredColorScheme(.dark) // Enforce dark mode
        .onAppear {
            // Apply custom tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            
            // Set background color with some transparency
            appearance.backgroundColor = UIColor(Color(hex: "18181A").opacity(0.9))
            
            // Apply blur effect for airy feel
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            
            // Customize tab bar item appearance
            let itemAppearance = UITabBarItemAppearance()
            
            // Normal state
            itemAppearance.normal.iconColor = UIColor(Color(hex: "8E8E93"))
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color(hex: "8E8E93"))]
            
            // Selected state
            itemAppearance.selected.iconColor = UIColor(primaryColor)
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(primaryColor)]
            
            // Apply item appearance to different states
            appearance.stackedLayoutAppearance = itemAppearance
            appearance.inlineLayoutAppearance = itemAppearance
            appearance.compactInlineLayoutAppearance = itemAppearance
            
            // Apply the appearance settings
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            
            // Custom tab bar shape with rounded corners using UIKit
            DispatchQueue.main.async {
                if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                    // Apply rounded corners to just the top
                    tabBarController.tabBar.layer.cornerRadius = 20
                    tabBarController.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    tabBarController.tabBar.layer.masksToBounds = true
                    
                    // Add subtle glow shadow for depth
                    tabBarController.tabBar.layer.shadowColor = UIColor(primaryColor.opacity(0.6)).cgColor
                    tabBarController.tabBar.layer.shadowOffset = CGSize(width: 0, height: -3)
                    tabBarController.tabBar.layer.shadowOpacity = 0.4
                    tabBarController.tabBar.layer.shadowRadius = 8
                }
            }
        }
    }
}

// Extension to create colors from hex codes


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
