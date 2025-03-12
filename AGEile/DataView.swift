import SwiftUI
import Charts
import SceneKit

struct GaitDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let value: Double
    let annotation: String?
    
    init(value: Double, daysAgo: Int, annotation: String? = nil) {
        self.value = value
        self.timestamp = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        self.annotation = annotation
    }
}

struct WeightDistribution: Identifiable {
    let id = UUID()
    let day: String
    let date: Date
    let front: Double
    let back: Double
    
    init(day: String, daysAgo: Int, front: Double, back: Double) {
        self.day = day
        self.date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        self.front = front
        self.back = back
    }
}

struct FootPressurePoint: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
    let pressure: Double // 0-1 scale
}

struct DataView: View {
    // Theme colors
    let themeBackground = Color(hex: "121212")
    let themeSurface = Color(hex: "1E1E1E")
    let themePrimary = Color(hex: "BB86FC")
    let themeSecondary = Color(hex: "03DAC6")
    let themeAccent = Color(hex: "CF6679")
    
    let greenGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "00E676"), Color(hex: "00C853")]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    let purpleGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "BB86FC"), Color(hex: "7E57C2")]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    let redGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "FF5252"), Color(hex: "D32F2F")]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    @State private var selectedMetricIndex = 0
    @State private var aiGeneratedInsight: String = "Click 'Generate AI Insight' to see custom insights."
    @State private var showGaitVisualization = false
    @State private var footPressurePoints: [FootPressurePoint] = []
    
    private let metrics = [
        "Weight Distribution",
        "Stride Variability",
        "Step Count",
        "Stability Score",
        "Foot Pronation",
        "Ground Contact Time",
        "Impact Force",
        "Toe-Off Power",
        "Gait Symmetry"
    ]
    
    // Sample data for original metrics
    private let gaitData: [Double] = [0.1, 0.2, 0.35, 0.4, 0.5, 0.4, 0.3, 0.2, 0.1]
    
    // Enhanced weight data with more context
    private let weightData: [WeightDistribution] = [
        WeightDistribution(day: "Mon", daysAgo: 6, front: 60, back: 40),
        WeightDistribution(day: "Tue", daysAgo: 5, front: 55, back: 45),
        WeightDistribution(day: "Wed", daysAgo: 4, front: 50, back: 50),
        WeightDistribution(day: "Thu", daysAgo: 3, front: 70, back: 30),
        WeightDistribution(day: "Fri", daysAgo: 2, front: 65, back: 35),
        WeightDistribution(day: "Sat", daysAgo: 1, front: 75, back: 25),
        WeightDistribution(day: "Sun", daysAgo: 0, front: 80, back: 20)
    ]

    private let strideVariabilityData: [GaitDataPoint] = (0..<30).map { i in
        let baseValue = Double.random(in: 0.02...0.07)
        let anomaly = i % 7 == 0 ? Double.random(in: 0.09...0.15) : 0.0
        let value = baseValue + anomaly
        return GaitDataPoint(
            value: value,
            daysAgo: i/4,
            annotation: anomaly > 0 ? "Irregular" : nil
        )
    }
   
    private let stepCountData: [GaitDataPoint] = [
        GaitDataPoint(value: 10500, daysAgo: 6),
        GaitDataPoint(value: 12300, daysAgo: 5),
        GaitDataPoint(value: 11200, daysAgo: 4),
        GaitDataPoint(value: 8400, daysAgo: 3, annotation: "Low"),
        GaitDataPoint(value: 15600, daysAgo: 2, annotation: "High"),
        GaitDataPoint(value: 13100, daysAgo: 1),
        GaitDataPoint(value: 9200, daysAgo: 0)
    ]
    
    private let stabilityScores: [GaitDataPoint] = [
        GaitDataPoint(value: 80, daysAgo: 6),
        GaitDataPoint(value: 85, daysAgo: 5),
        GaitDataPoint(value: 90, daysAgo: 4, annotation: "Excellent"),
        GaitDataPoint(value: 70, daysAgo: 3, annotation: "Poor"),
        GaitDataPoint(value: 95, daysAgo: 2, annotation: "Peak"),
        GaitDataPoint(value: 92, daysAgo: 1),
        GaitDataPoint(value: 88, daysAgo: 0)
    ]
    
    // New data sets for the additional metrics
    private let footPronationData: [GaitDataPoint] = [
        GaitDataPoint(value: 4.2, daysAgo: 6, annotation: "Neutral"),
        GaitDataPoint(value: 3.8, daysAgo: 5, annotation: "Slight Underpronation"),
        GaitDataPoint(value: 3.5, daysAgo: 4, annotation: "Underpronation"),
        GaitDataPoint(value: 4.5, daysAgo: 3),
        GaitDataPoint(value: 5.7, daysAgo: 2),
        GaitDataPoint(value: 3.1, daysAgo: 1),
        GaitDataPoint(value: 3.8, daysAgo: 0 , annotation:"Underpronation")
    ]
    
    private let groundContactTimeData: [GaitDataPoint] = [
        GaitDataPoint(value: 280, daysAgo: 6),
        GaitDataPoint(value: 275, daysAgo: 5),
        GaitDataPoint(value: 295, daysAgo: 4, annotation: "Long"),
        GaitDataPoint(value: 265, daysAgo: 3),
        GaitDataPoint(value: 260, daysAgo: 2, annotation: "Optimal"),
        GaitDataPoint(value: 270, daysAgo: 1),
        GaitDataPoint(value: 285, daysAgo: 0)
    ]
    
    private let impactForceData: [GaitDataPoint] = [
        GaitDataPoint(value: 1.8, daysAgo: 6),
        GaitDataPoint(value: 2.2, daysAgo: 5, annotation: "High Impact"),
        GaitDataPoint(value: 1.9, daysAgo: 4),
        GaitDataPoint(value: 1.7, daysAgo: 3),
        GaitDataPoint(value: 2.0, daysAgo: 2),
        GaitDataPoint(value: 1.8, daysAgo: 1),
        GaitDataPoint(value: 1.6, daysAgo: 0, annotation: "Low Impact")
    ]
    
    private let toeOffPowerData: [GaitDataPoint] = [
        GaitDataPoint(value: 3.2, daysAgo: 6),
        GaitDataPoint(value: 3.5, daysAgo: 5),
        GaitDataPoint(value: 3.7, daysAgo: 4),
        GaitDataPoint(value: 3.0, daysAgo: 3, annotation: "Weak"),
        GaitDataPoint(value: 4.1, daysAgo: 2, annotation: "Strong"),
        GaitDataPoint(value: 3.8, daysAgo: 1),
        GaitDataPoint(value: 3.6, daysAgo: 0)
    ]
    
    private let gaitSymmetryData: [GaitDataPoint] = [
        GaitDataPoint(value: 92, daysAgo: 6),
        GaitDataPoint(value: 94, daysAgo: 5),
        GaitDataPoint(value: 89, daysAgo: 4, annotation: "Asymmetric"),
        GaitDataPoint(value: 91, daysAgo: 3),
        GaitDataPoint(value: 97, daysAgo: 2, annotation: "Excellent"),
        GaitDataPoint(value: 95, daysAgo: 1),
        GaitDataPoint(value: 93, daysAgo: 0)
    ]

    // Generate foot pressure points
    private func generateFootPressureMap() -> [FootPressurePoint] {
        var points: [FootPressurePoint] = []
        
        // Heel area
        for _ in 0..<5 {
            points.append(FootPressurePoint(
                x: Double.random(in: 0.1...0.3),
                y: Double.random(in: 0.8...0.95),
                pressure: Double.random(in: 0.7...0.9)
            ))
        }
        
        // Midfoot
        for _ in 0..<8 {
            points.append(FootPressurePoint(
                x: Double.random(in: 0.1...0.3),
                y: Double.random(in: 0.4...0.7),
                pressure: Double.random(in: 0.3...0.6)
            ))
        }
        
        // Ball of foot
        for _ in 0..<5 {
            points.append(FootPressurePoint(
                x: Double.random(in: 0.1...0.3),
                y: Double.random(in: 0.1...0.3),
                pressure: Double.random(in: 0.6...0.9)
            ))
        }
        
        // Toes
        for _ in 0..<3 {
            points.append(FootPressurePoint(
                x: Double.random(in: 0.1...0.3),
                y: Double.random(in: 0.0...0.1),
                pressure: Double.random(in: 0.4...0.7)
            ))
        }
        
        return points
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Gait Analysis Dashboard")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(themePrimary)
                    .padding(.bottom, 4)
                
                Text("Comprehensive analysis of your walking patterns")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
                
                // Metrics selector with improved UI
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<metrics.count, id: \.self) { index in
                            Button(action: {
                                withAnimation {
                                    selectedMetricIndex = index
                                    if index == 0 {
                                        footPressurePoints = generateFootPressureMap()
                                    }
                                }
                            }) {
                                Text(metrics[index])
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedMetricIndex == index ? themePrimary : themeSurface)
                                    )
                                    .foregroundColor(selectedMetricIndex == index ? Color.black : Color.white)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 4)
                
                // Dynamic chart based on selection
                VStack(alignment: .leading, spacing: 10) {
                    Text(metrics[selectedMetricIndex])
                        .font(.headline)
                        .foregroundColor(themeSecondary)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            switch selectedMetricIndex {
                            case 0:
                                Text("Front/Back Balance")
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                            case 1:
                                Text("Stride Consistency")
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                            case 4:
                                Text("Degree of Foot Roll")
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                            case 5:
                                Text("Ground Contact (ms)")
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                            case 6:
                                Text("Body Weight Multiplier")
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                            case 7:
                                Text("Propulsion Force (N/kg)")
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                            case 8:
                                Text("L/R Symmetry %")
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                            default:
                                Text("Weekly Trend")
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                            }
                        }
                        
                        Spacer()
                        
                        // Quick stats
                        if selectedMetricIndex < 9 {
                            HStack(spacing: 16) {
                                statView(
                                    label: "Avg",
                                    value: averageValue(for: selectedMetricIndex),
                                    color: themePrimary
                                )
                                
                                statView(
                                    label: "Max",
                                    value: maxValue(for: selectedMetricIndex),
                                    color: themeSecondary
                                )
                            }
                        }
                    }
                    .padding(.bottom, 4)
                    
                    // Chart view based on selected metric
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(themeSurface)
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        VStack {
                            switch selectedMetricIndex {
                            case 0:
                                weightDistributionChart()
                            case 1:
                                strideVariabilityChart()
                            case 2:
                                stepCountChart()
                            case 3:
                                stabilityScoreChart()
                            case 4:
                                footPronationChart()
                            case 5:
                                groundContactTimeChart()
                            case 6:
                                impactForceChart()
                            case 7:
                                toeOffPowerChart()
                            case 8:
                                gaitSymmetryChart()
                            default:
                                Text("Chart not available")
                                    .foregroundColor(Color.gray)
                            }
                        }
                        .padding()
                    }
                    .frame(height: 300)
                }
                
                // Insights Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Analysis & Recommendations")
                        .font(.headline)
                        .foregroundColor(themeSecondary)
                    
                    insightView()
                    
                    // AI Insight Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("AI-Generated Insights")
                            .font(.headline)
                            .foregroundColor(themeSecondary)
                        
                        Text(aiGeneratedInsight)
                            .foregroundColor(Color.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(themeSurface)
                            .cornerRadius(12)

                        Button(action: generateAIInsight) {
                            Label("Generate AI Insight", systemImage: "sparkles")
                                .font(.callout)
                                .bold()
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(themePrimary)
                                )
                                .foregroundColor(Color.black)
                        }
                    }
                    .padding()
                    .background(Color(hex: "2A2A2A"))
                    .cornerRadius(16)
                }
                
                // Visualization Section
                visualizationSection()
            }
            .padding()
            .background(themeBackground.ignoresSafeArea())
        }
        .preferredColorScheme(.dark)
        .onAppear {
            footPressurePoints = generateFootPressureMap()
        }
    }
    
    private func statView(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color.gray)
        }
    }
    
    private func averageValue(for metricIndex: Int) -> String {
        switch metricIndex {
        case 0:
            let avgFront = weightData.reduce(0) { $0 + $1.front } / Double(weightData.count)
            return String(format: "%.1f%%", avgFront)
        case 1:
            let avg = strideVariabilityData.reduce(0) { $0 + $1.value } / Double(strideVariabilityData.count)
            return String(format: "%.3fm", avg)
        case 2:
            let avg = stepCountData.reduce(0) { $0 + $1.value } / Double(stepCountData.count)
            return String(format: "%.0f", avg)
        case 3:
            let avg = stabilityScores.reduce(0) { $0 + $1.value } / Double(stabilityScores.count)
            return String(format: "%.1f", avg)
        case 4:
            let avg = footPronationData.reduce(0) { $0 + $1.value } / Double(footPronationData.count)
            return String(format: "%.1f°", avg)
        case 5:
            let avg = groundContactTimeData.reduce(0) { $0 + $1.value } / Double(groundContactTimeData.count)
            return String(format: "%.0fms", avg)
        case 6:
            let avg = impactForceData.reduce(0) { $0 + $1.value } / Double(impactForceData.count)
            return String(format: "%.1fx", avg)
        case 7:
            let avg = toeOffPowerData.reduce(0) { $0 + $1.value } / Double(toeOffPowerData.count)
            return String(format: "%.1f", avg)
        case 8:
            let avg = gaitSymmetryData.reduce(0) { $0 + $1.value } / Double(gaitSymmetryData.count)
            return String(format: "%.1f%%", avg)
        default:
            return "N/A"
        }
    }
    
    private func maxValue(for metricIndex: Int) -> String {
        switch metricIndex {
        case 0:
            let maxFront = weightData.map { $0.front }.max() ?? 0
            return String(format: "%.1f%%", maxFront)
        case 1:
            let max = strideVariabilityData.map { $0.value }.max() ?? 0
            return String(format: "%.3fm", max)
        case 2:
            let max = stepCountData.map { $0.value }.max() ?? 0
            return String(format: "%.0f", max)
        case 3:
            let max = stabilityScores.map { $0.value }.max() ?? 0
            return String(format: "%.1f", max)
        case 4:
            let max = footPronationData.map { $0.value }.max() ?? 0
            return String(format: "%.1f°", max)
        case 5:
            let max = groundContactTimeData.map { $0.value }.max() ?? 0
            return String(format: "%.0fms", max)
        case 6:
            let max = impactForceData.map { $0.value }.max() ?? 0
            return String(format: "%.1fx", max)
        case 7:
            let max = toeOffPowerData.map { $0.value }.max() ?? 0
            return String(format: "%.1f", max)
        case 8:
            let max = gaitSymmetryData.map { $0.value }.max() ?? 0
            return String(format: "%.1f%%", max)
        default:
            return "N/A"
        }
    }
    
    // Enhanced charts with better visuals and annotations
    private func weightDistributionChart() -> some View {
        Chart {
            ForEach(weightData) { data in
                let totalWeight = data.front + data.back
                let frontPercentage = (data.front / totalWeight) * 100
                let backPercentage = (data.back / totalWeight) * 100

                BarMark(
                    x: .value("Day", data.day),
                    y: .value("Front Weight (%)", frontPercentage)
                )
                .foregroundStyle(Color(hex: "03DAC6"))
                .cornerRadius(4)
                .annotation(position: .top) {
                    if frontPercentage > 65 {
                        Text("\(Int(frontPercentage))%")
                            .font(.system(size: 10))
                            .foregroundColor(Color.white)
                    }
                }
                
                BarMark(
                    x: .value("Day", data.day),
                    y: .value("Back Weight (%)", backPercentage)
                )
                .foregroundStyle(Color(hex: "CF6679"))
                .cornerRadius(4)
            }
            
            RuleMark(y: .value("Ideal", 50))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .foregroundStyle(Color.gray)
                .annotation(position: .leading) {
                    Text("50%")
                        .font(.system(size: 10))
                        .foregroundColor(Color.gray)
                }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
    }

    private func strideVariabilityChart() -> some View {
        Chart {
            ForEach(strideVariabilityData) { point in
                PointMark(
                    x: .value("Step", point.timestamp),
                    y: .value("Variability", point.value)
                )
                .foregroundStyle(point.value > 0.08 ? themeAccent : themeSecondary)
                .symbolSize(point.value > 0.08 ? 100 : 60)
                
                if let annotation = point.annotation {
                    PointMark(
                        x: .value("Step", point.timestamp),
                        y: .value("Variability", point.value)
                    )
                    .annotation(position: .top) {
                        Text(annotation)
                            .font(.system(size: 10))
                            .foregroundColor(point.value > 0.08 ? themeAccent : themeSecondary)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.black.opacity(0.7))
                            )
                    }
                }
            }
            
            RuleMark(y: .value("Threshold", 0.08))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .foregroundStyle(Color.orange)
                .annotation(position: .trailing) {
                    Text("Threshold")
                        .font(.system(size: 10))
                        .foregroundColor(Color.orange)
                }
        }
        .chartYScale(domain: 0...0.16)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
    }

    private func stepCountChart() -> some View {
        Chart {
            ForEach(stepCountData) { point in
                BarMark(
                    x: .value("Day", point.timestamp),
                    y: .value("Steps", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "FF9E80"), Color(hex: "FF3D00")]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(6)
                
                if let annotation = point.annotation {
                    BarMark(
                        x: .value("Day", point.timestamp),
                        y: .value("Steps", point.value)
                    )
                    .annotation(position: .top) {
                        Text(annotation)
                            .font(.system(size: 10))
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(4)
                            .foregroundColor(annotation == "High" ? Color.green : Color.red)
                    }
                }
            }
            
            RuleMark(y: .value("Target", 10000))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .foregroundStyle(Color.green)
                .annotation(position: .trailing) {
                    Text("Target")
                        .font(.system(size: 10))
                        .foregroundColor(Color.green)
                }
        }
        .chartYScale(domain: 0...16000)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
    }

    private func stabilityScoreChart() -> some View {
        Chart {
            ForEach(stabilityScores) { point in
                LineMark(
                    x: .value("Day", point.timestamp),
                    y: .value("Stability Score", point.value)
                )
                .foregroundStyle(themePrimary)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                PointMark(
                    x: .value("Day", point.timestamp),
                    y: .value("Stability Score", point.value)
                )
                .foregroundStyle(
                    point.value > 90 ? Color.green :
                    point.value < 75 ? Color.red :
                    Color.orange
                )
                .symbolSize(point.value < 75 || point.value > 90 ? 100 : 80)
                
                if let annotation = point.annotation {
                    PointMark(
                        x: .value("Day", point.timestamp),
                        y: .value("Stability Score", point.value)
                    )
                    .annotation(position: .top) {
                        Text(annotation)
                            .font(.system(size: 10))
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(4)
                            .foregroundColor(
                                annotation == "Excellent" || annotation == "Peak" ? Color.green :
                                annotation == "Poor" ? Color.red :
                                Color.orange
                            )
                    }
                }
            }
            
            RuleMark(y: .value("Good", 85))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .foregroundStyle(Color.green)
                .annotation(position: .trailing) {
                    Text("Good")
                        .font(.system(size: 10))
                        .foregroundColor(Color.green)
                }
                
            RuleMark(y: .value("Warning", 75))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .foregroundStyle(Color.orange)
                .annotation(position: .trailing) {
                    Text("Warning")
                        .font(.system(size: 10))
                        .foregroundColor(Color.orange)
                }
        }
        .chartYScale(domain: 65...100)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
    }
    
    // New metric charts
    private func footPronationChart() -> some View {
        Chart {
            ForEach(footPronationData) { point in
                LineMark(
                    x: .value("Day", point.timestamp),
                    y: .value("Pronation Angle", point.value)
                )
                .foregroundStyle(themeSecondary)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                PointMark(
                    x: .value("Day", point.timestamp),
                    y: .value("Pronation Angle", point.value)
                )
            
                .foregroundStyle(
                                    point.value < 5 ? Color.green :
                                    point.value > 7 ? Color.red :
                                    Color.orange
                                )
                                .symbolSize(point.value < 5 || point.value > 7 ? 100 : 80)
                                
                                if let annotation = point.annotation {
                                    PointMark(
                                        x: .value("Day", point.timestamp),
                                        y: .value("Pronation Angle", point.value)
                                    )
                                    .annotation(position: .top) {
                                        Text(annotation)
                                            .font(.system(size: 10))
                                            .padding(.vertical, 2)
                                            .padding(.horizontal, 6)
                                            .background(Color.black.opacity(0.7))
                                            .cornerRadius(4)
                                            .foregroundColor(
                                                annotation == "Neutral" ? Color.green :
                                                annotation == "Overpronation" ? Color.red :
                                                Color.orange
                                            )
                                    }
                                }
                            }
                            
                            RuleMark(y: .value("Neutral", 5))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                .foregroundStyle(Color.green)
                                .annotation(position: .trailing) {
                                    Text("Neutral")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color.green)
                                }
                                
                            RuleMark(y: .value("Overpronation", 7))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                .foregroundStyle(Color.red)
                                .annotation(position: .trailing) {
                                    Text("Over")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color.red)
                                }
                        }
                        .chartYScale(domain: 3...8)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            }
                        }
                    }
                    
                    private func groundContactTimeChart() -> some View {
                        Chart {
                            ForEach(groundContactTimeData) { point in
                                LineMark(
                                    x: .value("Day", point.timestamp),
                                    y: .value("Contact Time", point.value)
                                )
                                .foregroundStyle(themePrimary)
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                
                                PointMark(
                                    x: .value("Day", point.timestamp),
                                    y: .value("Contact Time", point.value)
                                )
                                .foregroundStyle(
                                    point.value < 270 ? Color.green :
                                    point.value > 290 ? Color.red :
                                    Color.orange
                                )
                                .symbolSize(point.value < 270 || point.value > 290 ? 100 : 80)
                                
                                if let annotation = point.annotation {
                                    PointMark(
                                        x: .value("Day", point.timestamp),
                                        y: .value("Contact Time", point.value)
                                    )
                                    .annotation(position: .top) {
                                        Text(annotation)
                                            .font(.system(size: 10))
                                            .padding(.vertical, 2)
                                            .padding(.horizontal, 6)
                                            .background(Color.black.opacity(0.7))
                                            .cornerRadius(4)
                                            .foregroundColor(
                                                annotation == "Optimal" ? Color.green :
                                                annotation == "Long" ? Color.red :
                                                Color.orange
                                            )
                                    }
                                }
                            }
                            
                            RuleMark(y: .value("Optimal", 270))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                .foregroundStyle(Color.green)
                                .annotation(position: .trailing) {
                                    Text("Optimal")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color.green)
                                }
                        }
                        .chartYScale(domain: 250...300)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            }
                        }
                    }
                    
                    private func impactForceChart() -> some View {
                        Chart {
                            ForEach(impactForceData) { point in
                                LineMark(
                                    x: .value("Day", point.timestamp),
                                    y: .value("Impact Force", point.value)
                                )
                                .foregroundStyle(themeSecondary)
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                
                                PointMark(
                                    x: .value("Day", point.timestamp),
                                    y: .value("Impact Force", point.value)
                                )
                                .foregroundStyle(
                                    point.value < 1.8 ? Color.green :
                                    point.value > 2.1 ? Color.red :
                                    Color.orange
                                )
                                .symbolSize(point.value < 1.8 || point.value > 2.1 ? 100 : 80)
                                
                                if let annotation = point.annotation {
                                    PointMark(
                                        x: .value("Day", point.timestamp),
                                        y: .value("Impact Force", point.value)
                                    )
                                    .annotation(position: .top) {
                                        Text(annotation)
                                            .font(.system(size: 10))
                                            .padding(.vertical, 2)
                                            .padding(.horizontal, 6)
                                            .background(Color.black.opacity(0.7))
                                            .cornerRadius(4)
                                            .foregroundColor(
                                                annotation == "Low Impact" ? Color.green :
                                                annotation == "High Impact" ? Color.red :
                                                Color.orange
                                            )
                                    }
                                }
                            }
                            
                            RuleMark(y: .value("Safe", 1.8))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                .foregroundStyle(Color.green)
                                .annotation(position: .trailing) {
                                    Text("Safe")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color.green)
                                }
                                
                            RuleMark(y: .value("High", 2.1))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                .foregroundStyle(Color.red)
                                .annotation(position: .trailing) {
                                    Text("High")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color.red)
                                }
                        }
                        .chartYScale(domain: 1.5...2.3)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            }
                        }
                    }
                    
                    private func toeOffPowerChart() -> some View {
                        Chart {
                            ForEach(toeOffPowerData) { point in
                                LineMark(
                                    x: .value("Day", point.timestamp),
                                    y: .value("Toe-Off Power", point.value)
                                )
                                .foregroundStyle(themePrimary)
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                
                                PointMark(
                                    x: .value("Day", point.timestamp),
                                    y: .value("Toe-Off Power", point.value)
                                )
                                .foregroundStyle(
                                    point.value > 3.8 ? Color.green :
                                    point.value < 3.2 ? Color.red :
                                    Color.orange
                                )
                                .symbolSize(point.value > 3.8 || point.value < 3.2 ? 100 : 80)
                                
                                if let annotation = point.annotation {
                                    PointMark(
                                        x: .value("Day", point.timestamp),
                                        y: .value("Toe-Off Power", point.value)
                                    )
                                    .annotation(position: .top) {
                                        Text(annotation)
                                            .font(.system(size: 10))
                                            .padding(.vertical, 2)
                                            .padding(.horizontal, 6)
                                            .background(Color.black.opacity(0.7))
                                            .cornerRadius(4)
                                            .foregroundColor(
                                                annotation == "Strong" ? Color.green :
                                                annotation == "Weak" ? Color.red :
                                                Color.orange
                                            )
                                    }
                                }
                            }
                            
                            RuleMark(y: .value("Good", 3.8))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                .foregroundStyle(Color.green)
                                .annotation(position: .trailing) {
                                    Text("Good")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color.green)
                                }
                        }
                        .chartYScale(domain: 2.9...4.2)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            }
                        }
                    }
                    
                    private func gaitSymmetryChart() -> some View {
                        Chart {
                            ForEach(gaitSymmetryData) { point in
                                LineMark(
                                    x: .value("Day", point.timestamp),
                                    y: .value("Symmetry", point.value)
                                )
                                .foregroundStyle(themeSecondary)
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                
                                PointMark(
                                    x: .value("Day", point.timestamp),
                                    y: .value("Symmetry", point.value)
                                )
                                .foregroundStyle(
                                    point.value > 95 ? Color.green :
                                    point.value < 90 ? Color.red :
                                    Color.orange
                                )
                                .symbolSize(point.value > 95 || point.value < 90 ? 100 : 80)
                                
                                if let annotation = point.annotation {
                                    PointMark(
                                        x: .value("Day", point.timestamp),
                                        y: .value("Symmetry", point.value)
                                    )
                                    .annotation(position: .top) {
                                        Text(annotation)
                                            .font(.system(size: 10))
                                            .padding(.vertical, 2)
                                            .padding(.horizontal, 6)
                                            .background(Color.black.opacity(0.7))
                                            .cornerRadius(4)
                                            .foregroundColor(
                                                annotation == "Excellent" ? Color.green :
                                                annotation == "Asymmetric" ? Color.red :
                                                Color.orange
                                            )
                                    }
                                }
                            }
                            
                            RuleMark(y: .value("Excellent", 95))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                .foregroundStyle(Color.green)
                                .annotation(position: .trailing) {
                                    Text("Excellent")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color.green)
                                }
                                
                            RuleMark(y: .value("Concern", 90))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                .foregroundStyle(Color.red)
                                .annotation(position: .trailing) {
                                    Text("Concern")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color.red)
                                }
                        }
                        .chartYScale(domain: 85...100)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            }
                        }
                    }
                    
                    // Insights section based on selected metric
                    private func insightView() -> some View {
                        VStack(alignment: .leading, spacing: 15) {
                            switch selectedMetricIndex {
                            case 0:
                                insightCard(
                                    title: "Forward Weight Shift",
                                    description: "Your weight distribution shows a significant forward bias (70-80%), which may increase pressure on the balls of your feet.",
                                    recommendations: [
                                        "Practice balanced standing posture exercises",
                                        "Consider shoe inserts for better weight distribution",
                                        "Check your walking form with a coach"
                                    ],
                                    icon: "figure.walk",
                                    color: themeAccent
                                )
                            case 1:
                                insightCard(
                                    title: "Inconsistent Stride",
                                    description: "Your stride variability shows occasional spikes, indicating potential gait instability every few days.",
                                    recommendations: [
                                        "Focus on consistent cadence during walks",
                                        "Strengthen core and hip stabilizers",
                                        "Try metronome-based training for consistency"
                                    ],
                                    icon: "waveform.path",
                                    color: themePrimary
                                )
                            case 2:
                                insightCard(
                                    title: "Daily Step Target",
                                    description: "Your step count varies widely, with inconsistent activity levels throughout the week.",
                                    recommendations: [
                                        "Set a minimum daily step goal of 10,000 steps",
                                        "Schedule walking breaks during sedentary periods",
                                        "Track active minutes rather than just steps"
                                    ],
                                    icon: "figure.walk",
                                    color: themeSecondary
                                )
                            case 3:
                                insightCard(
                                    title: "Stability Fluctuations",
                                    description: "Your stability score drops significantly on certain days, suggesting possible fatigue or recovery issues.",
                                    recommendations: [
                                        "Include balance training in your routine",
                                        "Monitor stability patterns after workouts",
                                        "Consider proprioception exercises"
                                    ],
                                    icon: "rotate.3d",
                                    color: themePrimary
                                )
                            case 4:
                                insightCard(
                                    title: "Overpronation Detected",
                                    description: "Your data shows moderate overpronation, which may contribute to knee or hip alignment issues over time.",
                                    recommendations: [
                                        "Consider stability running shoes",
                                        "Strengthen foot intrinsic muscles",
                                        "Try arch-specific stretching exercises"
                                    ],
                                    icon: "foot.fill",
                                    color: themeAccent
                                )
                            case 5:
                                insightCard(
                                    title: "Extended Ground Contact",
                                    description: "Your ground contact time is longer than optimal, potentially reducing walking efficiency.",
                                    recommendations: [
                                        "Practice quick-feet drills",
                                        "Work on forefoot walking technique",
                                        "Include plyometric exercises in training"
                                    ],
                                    icon: "timer",
                                    color: themePrimary
                                )
                            case 6:
                                insightCard(
                                    title: "High Impact Forces",
                                    description: "Your impact forces occasionally spike above recommended levels, increasing injury risk.",
                                    recommendations: [
                                        "Focus on soft landings during walks",
                                        "Consider shoes with better cushioning",
                                        "Gradually increase walking volume"
                                    ],
                                    icon: "arrow.down.circle.fill",
                                    color: themeAccent
                                )
                            case 7:
                                insightCard(
                                    title: "Propulsion Power",
                                    description: "Your toe-off power varies throughout the week, with lower values potentially indicating fatigue.",
                                    recommendations: [
                                        "Add calf and forefoot strengthening exercises",
                                        "Practice explosive jumping movements",
                                        "Monitor toe-off power for recovery tracking"
                                    ],
                                    icon: "bolt.fill",
                                    color: themeSecondary
                                )
                            case 8:
                                insightCard(
                                    title: "Left-Right Imbalance",
                                    description: "Your gait symmetry occasionally drops below 90%, indicating potential muscular imbalances.",
                                    recommendations: [
                                        "Include unilateral strength exercises",
                                        "Check for leg length discrepancies",
                                        "Practice single-leg balance training"
                                    ],
                                    icon: "equal.circle.fill",
                                    color: themePrimary
                                )
                            default:
                                Text("No insights available for this metric")
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }
                    
                    private func insightCard(title: String, description: String, recommendations: [String], icon: String, color: Color) -> some View {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(color)
                                
                                Text(title)
                                    .font(.headline)
                                    .foregroundColor(color)
                            }
                            
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                            
                            Text("Recommendations")
                                .font(.subheadline)
                                .foregroundColor(Color.white.opacity(0.8))
                                .padding(.top, 5)
                            
                            ForEach(recommendations, id: \.self) { recommendation in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(color)
                                        .font(.system(size: 14))
                                    
                                    Text(recommendation)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.white.opacity(0.7))
                                }
                                .padding(.vertical, 3)
                            }
                        }
                        .padding()
                        .background(Color(hex: "2A2A2A"))
                        .cornerRadius(16)
                    }
                    
                    // 3D Visualization section
                    private func visualizationSection() -> some View {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Foot Pressure Map")
                                .font(.headline)
                                .foregroundColor(themeSecondary)
                            
                            ZStack {
                                // Foot outline
                                Image(systemName: "figure.walk")
                                    .font(.system(size: 120))
                                    .foregroundColor(Color.gray.opacity(0.3))
                                
                                // Canvas for pressure points
                                Canvas { context, size in
                                    let footWidth = size.width * 0.7
                                    let footHeight = size.height * 0.8
                                    let footOriginX = (size.width - footWidth) / 2
                                    let footOriginY = (size.height - footHeight) / 2
                                    
                                    // Draw foot outline
                                    let footPath = Path { path in
                                        path.move(to: CGPoint(x: footOriginX + footWidth * 0.3, y: footOriginY))
                                        path.addCurve(
                                            to: CGPoint(x: footOriginX + footWidth * 0.7, y: footOriginY),
                                            control1: CGPoint(x: footOriginX + footWidth * 0.4, y: footOriginY - footHeight * 0.1),
                                            control2: CGPoint(x: footOriginX + footWidth * 0.6, y: footOriginY - footHeight * 0.1)
                                        )
                                        path.addLine(to: CGPoint(x: footOriginX + footWidth * 0.9, y: footOriginY + footHeight * 0.7))
                                        path.addCurve(
                                            to: CGPoint(x: footOriginX + footWidth * 0.5, y: footOriginY + footHeight),
                                            control1: CGPoint(x: footOriginX + footWidth * 0.9, y: footOriginY + footHeight * 0.85),
                                            control2: CGPoint(x: footOriginX + footWidth * 0.7, y: footOriginY + footHeight)
                                        )
                                        path.addCurve(
                                            to: CGPoint(x: footOriginX + footWidth * 0.1, y: footOriginY + footHeight * 0.7),
                                            control1: CGPoint(x: footOriginX + footWidth * 0.3, y: footOriginY + footHeight),
                                            control2: CGPoint(x: footOriginX + footWidth * 0.1, y: footOriginY + footHeight * 0.85)
                                        )
                                        path.closeSubpath()
                                    }
                                    
                                    context.stroke(footPath, with: .color(Color.gray), lineWidth: 2)
                                    
                                    // Draw pressure points
                                    for point in footPressurePoints {
                                        let x = footOriginX + point.x * footWidth
                                        let y = footOriginY + point.y * footHeight
                                        let radius = 5.0 + point.pressure * 15.0
                                        
                                        let pressurePoint = Path(ellipseIn: CGRect(
                                            x: x - radius,
                                            y: y - radius,
                                            width: radius * 2,
                                            height: radius * 2
                                        ))
                                        
                                        // Create color based on pressure
                                        let color = Color(
                                            hue: 0.66 - (point.pressure * 0.66), // Blue to red
                                            saturation: 0.8,
                                            brightness: 0.9
                                        )
                                        
                                        context.fill(pressurePoint, with: .color(color))
                                        context.stroke(pressurePoint, with: .color(Color.white.opacity(0.5)), lineWidth: 1)
                                    }
                                }
                                .frame(height: 300)
                                .background(themeSurface)
                                .cornerRadius(16)
                            }
                            
                            Button(action: {
                                showGaitVisualization.toggle()
                                if showGaitVisualization {
                                    footPressurePoints = generateFootPressureMap()
                                }
                            }) {
                                HStack {
                                    Image(systemName: showGaitVisualization ? "eye.slash.fill" : "eye.fill")
                                    Text(showGaitVisualization ? "Hide 3D Visualization" : "Show 3D Visualization")
                                }
                                .font(.callout)
                                .bold()
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(themeSecondary)
                                )
                                .foregroundColor(Color.black)
                            }
                            
                            if showGaitVisualization {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(themeSurface)
                                    
                                    VStack {
                                        Text("3D Gait Visualization")
                                            .font(.subheadline)
                                            .foregroundColor(themeSecondary)
                                            .padding(.top, 10)
                                        
                                        SceneView(
                                            scene: createGaitScene(),
                                            options: [.allowsCameraControl, .autoenablesDefaultLighting]
                                        )
                                        .frame(height: 300)
                                    }
                                }
                            }
                        }
                    }
                    
                    private func createGaitScene() -> SCNScene {
                        let scene = SCNScene()
                        
                        // Create a floor
                        let floorGeometry = SCNBox(width: 10, height: 0.1, length: 20, chamferRadius: 0)
                        let floorNode = SCNNode(geometry: floorGeometry)
                        floorNode.position = SCNVector3(x: 0, y: -1, z: 0)
                        floorGeometry.firstMaterial?.diffuse.contents = Color(hex: "2A2A2A")
                        scene.rootNode.addChildNode(floorNode)
                        
                        // Create a simple foot model
                        let footGeometry = SCNBox(width: 1, height: 0.2, length: 3, chamferRadius: 0.2)
                        let footNode = SCNNode(geometry: footGeometry)
                        footNode.position = SCNVector3(x: 0, y: -0.8, z: 0)
                        footGeometry.firstMaterial?.diffuse.contents = Color(hex: "BB86FC").opacity(0.8)
                        scene.rootNode.addChildNode(footNode)
                        
                        // Add animation for the foot
                        let walkAnimation = CABasicAnimation(keyPath: "position")
                        walkAnimation.fromValue = SCNVector3(x: -3, y: -0.8, z: 0)
                        walkAnimation.toValue = SCNVector3(x: 3, y: -0.8, z: 0)
                        walkAnimation.duration = 2.0
                        walkAnimation.repeatCount = .infinity
                        walkAnimation.autoreverses = true
                        footNode.addAnimation(walkAnimation, forKey: "position")
                        
                        // Add pressure points
                        for (index, point) in footPressurePoints.prefix(5).enumerated() {
                            let sphereGeometry = SCNSphere(radius: CGFloat(0.1 + point.pressure * 0.2))
                            let sphereNode = SCNNode(geometry: sphereGeometry)
                            
                            // Position along the foot based on point.y
                            let zPos = (1.0 - point.y) * 1.2 - 0.6
                            sphereNode.position = SCNVector3(
                                x: 0,
                                y: -0.7,
                                z: Float(Double(zPos))
                            )
                            
                            // Color based on pressure
                            let color = Color(
                                hue: 0.66 - (point.pressure * 0.66), // Blue to red
                                saturation: 0.8,
                                brightness: 0.9
                            )
                            sphereGeometry.firstMaterial?.diffuse.contents = color
                            
                            // Attach to foot
                            footNode.addChildNode(sphereNode)
                            
                            // Add pulse animation
                            let pulseAnimation = CABasicAnimation(keyPath: "scale")
                            pulseAnimation.fromValue = SCNVector3(x: 1, y: 1, z: 1)
                            pulseAnimation.toValue = SCNVector3(x: 1.2, y: 1.2, z: 1.2)
                            pulseAnimation.duration = 0.5 + Double(index) * 0.1
                            pulseAnimation.autoreverses = true
                            pulseAnimation.repeatCount = .infinity
                            sphereNode.addAnimation(pulseAnimation, forKey: "scale")
                        }
                        
                        return scene
                    }
                    
                    // Generate AI insights based on the selected metric
                    private func generateAIInsight() {
                        let insights = [
                            // Weight Distribution
                            "Your forward weight distribution has been steadily increasing over the past week, from 60% to 80%. This pattern often indicates compensating for weakness in the posterior chain muscles. Consider adding hamstring and glute strengthening exercises to your routine. If this trend continues, consult with a physical therapist as it may lead to plantar fasciitis.",
                            
                            // Stride Variability
                            "Your stride variability shows a pattern of irregularity every 7 days, which correlates with your longer walks based on step count data. The increased variability on these days suggests fatigue-related form breakdown. Try breaking your longer walks into smaller segments with brief walking recoveries to maintain technique throughout.",
                            
                            // Step Count
                            "Your weekly step count analysis shows high variability (8,400 to 15,600 steps). Days following high step counts show reduced stability scores, suggesting possible recovery issues. I recommend implementing a more consistent activity pattern with smaller day-to-day fluctuations to improve recovery cycles.",
                            
                            // Stability Score
                            "Your stability score dropped significantly (90→70) on Thursday after Wednesday's high pronation measurement. This pattern suggests that excessive foot rolling is compromising your overall stability. Focus on short foot exercises and arch strengthening to improve foot positioning and enhance stability.",
                            
                            // Foot Pronation
                            "Your pronation data shows a peak of 7.3° (Wednesday) followed by a steady improvement to 4.8° (Sunday). This improvement correlates with lower impact forces and improved toe-off power, suggesting your walking mechanics improve as pronation normalizes. Continue with your current foot strengthening routine as it's showing positive results.",
                            
                            // Ground Contact Time
                            "Your ground contact time averages 275ms, which is slightly longer than optimal for your activity profile. Longer contact times correlate with your lower stability scores, suggesting inefficient force transfer. I recommend incorporating plyometric exercises like box jumps and jump rope to develop more reactive foot strength.",
                            
                            // Impact Force
                            "Your impact forces show a concerning spike (2.2x body weight) on Tuesday, followed by a gradual decrease throughout the week. This spike corresponds with your highest foot pronation value, suggesting a connection between improper foot landing and impact. Work on landing softer with a slight midfoot strike to reduce these forces.",
                            
                            // Toe-Off Power
                            "Your toe-off power data reveals inconsistent propulsion (range: 3.0-4.1 N/kg). The lowest value (Thursday) correlates with your poorest stability score, indicating a connection between balance and propulsive force. Try single-leg calf raises with proper balance to improve both metrics simultaneously.",
                            
                            // Gait Symmetry
                            "Your gait symmetry data shows a significant drop to 89% on Wednesday, which correlates with your highest pronation values and longest ground contact time. This suggests that overpronation is creating asymmetries in your gait. Focus on equal weight distribution and symmetric foot placement during walking and walking to address this issue."
                        ]
                        
                        aiGeneratedInsight = insights[selectedMetricIndex]
                    }
                }

                extension Color {
                    init(hex: String) {
                        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                        var int: UInt64 = 0
                        Scanner(string: hex).scanHexInt64(&int)
                        let a, r, g, b: UInt64
                        switch hex.count {
                        case 3: // RGB (12-bit)
                            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
                        case 6: // RGB (24-bit)
                            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
                        case 8: // ARGB (32-bit)
                            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
                        default:
                            (a, r, g, b) = (1, 1, 1, 0)
                        }
                        
                        self.init(
                            .sRGB,
                            red: Double(r) / 255,
                            green: Double(g) / 255,
                            blue: Double(b) / 255,
                            opacity: Double(a) / 255
                        )
                    }
                }
