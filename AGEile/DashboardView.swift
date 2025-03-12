import SwiftUI
import CoreMotion
import Charts

struct DashboardView: View {
    @ObservedObject var motionManager: MotionManager
    @Binding var isMonitoring: Bool
    
    // User Data from AppStorage
    @AppStorage("email") private var email: String = "user@example.com"
    @AppStorage("age") private var age: String = "28"
    @AppStorage("weight") private var weight: String = "75 kg"
    @AppStorage("height") private var height: String = "180 cm"
    @AppStorage("heartRate") private var heartRate: String = "72 bpm"
    
    // Theme colors
    let primaryColor = Color(hex: "6A11CB")
    let accentColor = Color(hex: "2575FC")
    let backgroundColor = Color(hex: "121212")
    let cardBackgroundColor = Color(hex: "1E1E1E")
    let textPrimaryColor = Color.white
    let textSecondaryColor = Color(hex: "B3B3B3")
    let dangerColor = Color(hex: "FF5252")
    let warningColor = Color(hex: "FFB74D")
    let successColor = Color(hex: "4CAF50")
    
    // Additional sensor data states
    @State private var walkingInsights: String = "Loading walking insights..."
    @State private var gaitIrregularities: String = "Loading gait irregularities..."
    @State private var muscleWeakness: String = "Loading muscle weakness insights..."
    @State private var footPressureDistribution: String = "Loading pressure data..."
    @State private var balanceScore: Int = 0
    @State private var fallRiskLevel: String = "Loading..."
    @State private var stepCount: Int = 0
    @State private var distanceCovered: Double = 0.0
    @State private var caloriesBurned: Int = 0
    @State private var gaitSymmetry: Double = 0.0
    @State private var footClearance: Double = 0.0
    @State private var turnRate: Double = 0.0
    @State private var weeklyTrend: [Double] = [0, 0, 0, 0, 0, 0, 0]
    @State private var showingDetailView: Bool = false
    @State private var selectedMetric: String = ""
    
    // IMU and Force Sensor Specific Metrics
    @State private var leftFootForce: Double = 0
    @State private var rightFootForce: Double = 0
    @State private var propulsionForce: Double = 0
    @State private var impactForce: Double = 0
    @State private var angularVelocity: [Double] = [0, 0, 0]
    @State private var accelerationPeaks: Double = 0
    @State private var pronationSupination: String = "Neutral"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with User Info and Status
                headerView
                
                // Activity Summary
                activitySummaryView
                
                // Main Insights Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    MetricCardView(
                        title: "Balance Score",
                        value: "\(balanceScore)/100",
                        icon: "figure.balance",
                        color: balanceScore > 70 ? successColor : (balanceScore > 40 ? warningColor : dangerColor),
                        backgroundColor: cardBackgroundColor
                    )
                    
                    MetricCardView(
                        title: "Fall Risk",
                        value: fallRiskLevel,
                        icon: "exclamationmark.triangle.fill",
                        color: fallRiskLevel == "Low" ? successColor : (fallRiskLevel == "Moderate" ? warningColor : dangerColor),
                        backgroundColor: cardBackgroundColor
                    )
                    
                    MetricCardView(
                        title: "Gait Symmetry",
                        value: "\(Int(gaitSymmetry))%",
                        icon: "arrow.left.and.right",
                        color: gaitSymmetry > 85 ? successColor : (gaitSymmetry > 70 ? warningColor : dangerColor),
                        backgroundColor: cardBackgroundColor
                    )
                    
                    MetricCardView(
                        title: "Foot Clearance",
                        value: "\(String(format: "%.1f", footClearance)) cm",
                        icon: "arrow.up.to.line",
                        color: footClearance > 1.0 ? successColor : (footClearance > 0.5 ? warningColor : dangerColor),
                        backgroundColor: cardBackgroundColor
                    )
                }
                .padding(.horizontal)
                
                // Force Distribution Chart
                forceDistributionView
                
                // IMU Data Visualization
                imuDataVisualizationView
                
                // Key Walking Insights
                DashboardCardView(
                    title: "Key Walking Insights",
                    icon: "figure.walk",
                    content: walkingInsights,
                    iconColor: accentColor,
                    backgroundColor: cardBackgroundColor,
                    textColor: textPrimaryColor,
                    secondaryTextColor: textSecondaryColor
                )
                
                // Pressure Distribution Analysis
                DashboardCardView(
                    title: "Pressure Distribution Analysis",
                    icon: "waveform.path",
                    content: footPressureDistribution,
                    iconColor: primaryColor,
                    backgroundColor: cardBackgroundColor,
                    textColor: textPrimaryColor,
                    secondaryTextColor: textSecondaryColor
                )
                
                // Gait Irregularities
                DashboardCardView(
                    title: "Gait Irregularities Detected",
                    icon: "exclamationmark.triangle.fill",
                    content: gaitIrregularities,
                    iconColor: dangerColor,
                    backgroundColor: cardBackgroundColor,
                    textColor: textPrimaryColor,
                    secondaryTextColor: textSecondaryColor
                )
                
                // Muscle Weakness Insights
                DashboardCardView(
                    title: "Muscle Weakness Insights",
                    icon: "bolt.fill",
                    content: muscleWeakness,
                    iconColor: warningColor,
                    backgroundColor: cardBackgroundColor,
                    textColor: textPrimaryColor,
                    secondaryTextColor: textSecondaryColor
                )
                
                // Weekly Trend Chart
                weeklyTrendView
                
                // Monitoring Status
                monitoringStatusView
            }
            .padding(.vertical)
        }
        .background(backgroundColor.ignoresSafeArea())
        .navigationBarTitle("Gait Analysis", displayMode: .inline)
        .onAppear {
            loadDemoData()
        }
    }
    
    // MARK: - Subviews
    
    var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Hi Nirek,")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(textPrimaryColor)
                
                Text("Your Mobility Dashboard")
                    .font(.headline)
                    .foregroundColor(textSecondaryColor)
            }
            
            Spacer()
            
            // Profile Image
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [primaryColor, accentColor]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 50, height: 50)
                
                Text("N")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
    }
    
    var activitySummaryView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Today's Activity")
                .font(.title3)
                .bold()
                .foregroundColor(textPrimaryColor)
            
            HStack(spacing: 15) {
                ActivityItemView(
                    title: "Steps",
                    value: "\(stepCount)",
                    icon: "shoeprints.fill",
                    color: accentColor,
                    backgroundColor: cardBackgroundColor,
                    textColor: textPrimaryColor
                )
                
                ActivityItemView(
                    title: "Distance",
                    value: "\(String(format: "%.1f", distanceCovered)) km",
                    icon: "figure.walk",
                    color: primaryColor,
                    backgroundColor: cardBackgroundColor,
                    textColor: textPrimaryColor
                )
                
                ActivityItemView(
                    title: "Calories",
                    value: "\(caloriesBurned)",
                    icon: "flame.fill",
                    color: dangerColor,
                    backgroundColor: cardBackgroundColor,
                    textColor: textPrimaryColor
                )
            }
        }
        .padding(.horizontal)
    }
    
    var forceDistributionView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Foot Pressure Map")
                .font(.title3)
                .bold()
                .foregroundColor(textPrimaryColor)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                VStack {
                    Text("Left Foot")
                        .font(.headline)
                        .foregroundColor(textSecondaryColor)
                    
                    ZStack {
                        // Foot outline shape
                        Image(systemName: "figure.walk")
                            .font(.system(size: 80))
                            .foregroundColor(textSecondaryColor.opacity(0.5))
                        
                        // Heat map visualization (simplified)
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Circle().fill(Color.blue.opacity(0.3)).frame(width: 25, height: 25)
                                Circle().fill(Color.green.opacity(0.5)).frame(width: 25, height: 25)
                            }
                            HStack(spacing: 0) {
                                Circle().fill(Color.yellow.opacity(0.7)).frame(width: 25, height: 25)
                                Circle().fill(Color.red.opacity(0.9)).frame(width: 25, height: 25)
                            }
                        }
                        .offset(y: 10)
                    }
                    .frame(width: 120, height: 180)
                    .background(cardBackgroundColor)
                    .cornerRadius(15)
                    
                    Text("Peak: \(Int(leftFootForce)) N")
                        .font(.subheadline)
                        .foregroundColor(textSecondaryColor)
                }
                
                VStack {
                    Text("Right Foot")
                        .font(.headline)
                        .foregroundColor(textSecondaryColor)
                    
                    ZStack {
                        // Foot outline shape
                        Image(systemName: "figure.walk")
                            .font(.system(size: 80))
                            .foregroundColor(textSecondaryColor.opacity(0.5))
                        
                        // Heat map visualization (simplified)
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Circle().fill(Color.green.opacity(0.5)).frame(width: 25, height: 25)
                                Circle().fill(Color.blue.opacity(0.3)).frame(width: 25, height: 25)
                            }
                            HStack(spacing: 0) {
                                Circle().fill(Color.red.opacity(0.9)).frame(width: 25, height: 25)
                                Circle().fill(Color.yellow.opacity(0.7)).frame(width: 25, height: 25)
                            }
                        }
                        .offset(y: 10)
                    }
                    .frame(width: 120, height: 180)
                    .background(cardBackgroundColor)
                    .cornerRadius(15)
                    
                    Text("Peak: \(Int(rightFootForce)) N")
                        .font(.subheadline)
                        .foregroundColor(textSecondaryColor)
                }
            }
            .padding()
            .background(cardBackgroundColor)
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
    
    var imuDataVisualizationView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("IMU Sensor Data")
                .font(.title3)
                .bold()
                .foregroundColor(textPrimaryColor)
                .padding(.horizontal)
            
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    IMUDataCardView(
                        title: "Propulsion Force",
                        value: "\(Int(propulsionForce)) N",
                        icon: "arrow.right",
                        color: accentColor,
                        backgroundColor: cardBackgroundColor,
                        textColor: textPrimaryColor
                    )
                    
                    IMUDataCardView(
                        title: "Impact Force",
                        value: "\(Int(impactForce)) N",
                        icon: "arrow.down",
                        color: dangerColor,
                        backgroundColor: cardBackgroundColor,
                        textColor: textPrimaryColor
                    )
                }
                
                HStack(spacing: 15) {
                    IMUDataCardView(
                        title: "Angular Velocity",
                        value: "\(Int(angularVelocity[1])) °/s",
                        icon: "rotate.right",
                        color: primaryColor,
                        backgroundColor: cardBackgroundColor,
                        textColor: textPrimaryColor
                    )
                    
                    IMUDataCardView(
                        title: "Pronation/Supination",
                        value: pronationSupination,
                        icon: "arrow.triangle.turn.up.right.diamond",
                        color: pronationSupination == "Neutral" ? successColor : warningColor,
                        backgroundColor: cardBackgroundColor,
                        textColor: textPrimaryColor
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    var weeklyTrendView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Weekly Trend")
                .font(.title3)
                .bold()
                .foregroundColor(textPrimaryColor)
            
            VStack {
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(0..<7, id: \.self) { index in
                        VStack {
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 30, height: 150)
                                
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(LinearGradient(gradient: Gradient(colors: [primaryColor, accentColor]), startPoint: .top, endPoint: .bottom))
                                    .frame(width: 30, height: max(20, 150 * CGFloat(weeklyTrend[index] / 100)))
                            }
                            
                            Text(["M", "T", "W", "T", "F", "S", "S"][index])
                                .font(.caption)
                                .foregroundColor(textSecondaryColor)
                                .padding(.top, 5)
                        }
                    }
                }
                .padding()
                .background(cardBackgroundColor)
                .cornerRadius(15)
            }
        }
        .padding(.horizontal)
    }
    
    var monitoringStatusView: some View {
        VStack(spacing: 18) {
            if isMonitoring {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(successColor)
                        .font(.title2)
                    
                    Text("Monitoring in Progress")
                        .font(.headline)
                        .foregroundColor(successColor)
                        .padding(.vertical, 5)
                }
                
                NavigationLink(destination: MotionManagerView(motionManager: motionManager)) {
                    Text("Go to Motion Manager")
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryColor, accentColor]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: accentColor.opacity(0.5), radius: 8)
                }
            } else {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(dangerColor)
                        .font(.title2)
                    
                    Text("Monitoring is not active")
                        .font(.headline)
                        .foregroundColor(dangerColor)
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
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryColor, accentColor]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: accentColor.opacity(0.5), radius: 8)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 15)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: - Data Loading Functions
    
    func loadDemoData() {
        walkingInsights = "Gait Type: Mild Steppage Gait with reduced propulsion force. Right side shows 23% more effort than left, indicating compensation behavior."
        
        gaitIrregularities = "1. Insufficient foot clearance during swing phase\n2. Right foot dragging increases tripping risk\n3. Reduced heel strike on left foot\n4. Altered loading pattern during mid-stance"
        
        muscleWeakness = "Primary weakness detected in tibialis anterior (shin muscle) and gastrocnemius (calf muscle), affecting foot control. Secondary weakness in vastus lateralis (outer quad) may be contributing to knee stability issues during heel strike. Recommended exercises: ankle dorsiflexion, calf raises, and quad strengthening."
        
        footPressureDistribution = "Left foot: Excessive pressure on lateral edge during mid-stance phase indicating possible supination. Right foot: Increased forefoot loading with minimal heel contact. Overall pattern suggests compensatory mechanics to avoid pain."
        
        balanceScore = 67
        fallRiskLevel = "Moderate"
        stepCount = 3247
        distanceCovered = 2.3
        caloriesBurned = 187
        gaitSymmetry = 76.5
        footClearance = 0.8
        turnRate = 72.3
        weeklyTrend = [45, 58, 62, 75, 68, 72, 76]
        
        // IMU and Force Sensor specific metrics
        leftFootForce = 720
        rightFootForce = 685
        propulsionForce = 210
        impactForce = 892
        angularVelocity = [12.3, 45.7, 8.2]
        accelerationPeaks = 3.8
        pronationSupination = "Mild Supination"
    }
}

// MARK: - Supporting Views

struct DashboardCardView: View {
    var title: String
    var icon: String
    var content: String
    var iconColor: Color
    var backgroundColor: Color
    var textColor: Color
    var secondaryTextColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .foregroundColor(textColor)
                    .bold()
            }
            Text(content)
                .font(.body)
                .foregroundColor(secondaryTextColor)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(backgroundColor.opacity(0.5))
                .cornerRadius(12)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 8)
        .padding(.horizontal)
    }
}

struct MetricCardView: View {
    var title: String
    var value: String
    var icon: String
    var color: Color
    var backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 30))
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.gray)
        }
        .padding()
        .frame(height: 130)
        .background(backgroundColor)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 5)
    }
}

struct ActivityItemView: View {
    var title: String
    var value: String
    var icon: String
    var color: Color
    var backgroundColor: Color
    var textColor: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 24))
            }
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(textColor)
            
            Text(title)
                .font(.caption)
                .foregroundColor(Color.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
    }
}

struct IMUDataCardView: View {
    var title: String
    var value: String
    var icon: String
    var color: Color
    var backgroundColor: Color
    var textColor: Color
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color.gray)
                
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(textColor)
            }
            
            Spacer()
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(15)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Helper Extensions


