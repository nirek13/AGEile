import SwiftUI
import Charts
import SceneKit

struct DataView: View {
    @State private var selectedMetricIndex = 0
    @State private var aiGeneratedInsight: String = "Click 'Generate AI Insight' to see custom insights."

    // Sample weight data
    private let weightData: [WeightDistribution] = [
        WeightDistribution(day: "Mon", front: 60, back: 40),
        WeightDistribution(day: "Tue", front: 55, back: 45),
        WeightDistribution(day: "Wed", front: 50, back: 50),
        WeightDistribution(day: "Thu", front: 70, back: 30),
        WeightDistribution(day: "Fri", front: 65, back: 35),
        WeightDistribution(day: "Sat", front: 75, back: 25),
        WeightDistribution(day: "Sun", front: 80, back: 20)
    ]

    private let strideLengthData: [Double] = [0.6, 0.7, 0.65, 0.75, 0.8, 0.78, 0.76]
    private let stepCountData: [Int] = [10000, 12000, 11000, 8000, 15000, 13000, 9000]
    private let stabilityScores: [Double] = [80, 85, 90, 70, 95, 92, 88]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Weekly Data Overview")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)
                    .foregroundColor(.primary)

                Picker("Select Metric", selection: $selectedMetricIndex) {
                    Text("Weight").tag(0)
                    Text("Stride").tag(1)
                    Text("Steps").tag(2)
                    Text("Stability").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.bottom)

                VStack {
                    if selectedMetricIndex == 0 {
                        weightDistributionChart()
                    } else if selectedMetricIndex == 1 {
                        strideLengthChart()
                    } else if selectedMetricIndex == 2 {
                        stepCountChart()
                    } else {
                        stabilityScoreChart()
                    }
                }
                .frame(height: 300)
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.gray.opacity(0.2), radius: 8, x: 0, y: 4)

                VStack(alignment: .leading, spacing: 20) {
                    if selectedMetricIndex == 0 {
                        insightsForWeight()
                    } else if selectedMetricIndex == 1 {
                        insightsForStride()
                    } else if selectedMetricIndex == 2 {
                        insightsForSteps()
                    } else {
                        insightsForStability()
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("AI-Generated Insights")
                            .font(.headline)
                            .padding(.bottom, 2)
                        Text(aiGeneratedInsight)
                            .foregroundColor(.gray)

                        Button(action: generateAIInsight) {
                            Text("Generate AI Insight")
                                .font(.callout)
                                .bold()
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(color: Color.gray.opacity(0.15), radius: 5, x: 0, y: 3)
                
                // 3D Animation Section
                               VStack {
                                   Text("Gait Visualized")
                                       .font(.title2)
                                       .bold()
                                       .padding(.bottom, 5)
                                   SceneView(scene: createFullWalkingScene(), options: [.allowsCameraControl])
                                       .frame(height: 300)
                                       .cornerRadius(12)
                                       .shadow(color: Color.gray.opacity(0.2), radius: 8, x: 0, y: 4)
                               }
                               .padding()
            }
            .padding()
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }
    private func createFullWalkingScene() -> SCNScene {
        let scene = SCNScene()

        // Create pelvis (hips)
        let pelvis = SCNNode(geometry: SCNSphere(radius: 0.15))
        pelvis.geometry?.firstMaterial?.diffuse.contents = UIColor.systemPurple
        pelvis.position = SCNVector3(0, 0, 0)

        // Adjust leg proportions
        let thighHeight: CGFloat = 1.0  // Thigh is slightly longer than calf
        let calfHeight: CGFloat = 0.7
        let footHeight: CGFloat = 0.3

        // Create knee circle (geometry)
        let kneeRadius: CGFloat = 0.2
        let knee = SCNNode(geometry: SCNSphere(radius: kneeRadius))
        knee.geometry?.firstMaterial?.diffuse.contents = UIColor.systemYellow
        knee.position = SCNVector3(0, -0.8, 0)

        // Create the thighs, calves, and feet
        let leg1Thigh = SCNNode(geometry: SCNCylinder(radius: 0.05, height: thighHeight))
        let leg1Calf = SCNNode(geometry: SCNCylinder(radius: 0.04, height: calfHeight))
        let leg1Foot = SCNNode(geometry: SCNCylinder(radius: 0.07, height: footHeight)) // Foot added

        let leg2Thigh = SCNNode(geometry: SCNCylinder(radius: 0.05, height: thighHeight))
        let leg2Calf = SCNNode(geometry: SCNCylinder(radius: 0.04, height: calfHeight))
        let leg2Foot = SCNNode(geometry: SCNCylinder(radius: 0.07, height: footHeight)) // Foot added

        leg1Thigh.geometry?.firstMaterial?.diffuse.contents = UIColor.systemBlue
        leg1Calf.geometry?.firstMaterial?.diffuse.contents = UIColor.systemGreen
        leg1Foot.geometry?.firstMaterial?.diffuse.contents = UIColor.brown

        leg2Thigh.geometry?.firstMaterial?.diffuse.contents = UIColor.systemBlue
        leg2Calf.geometry?.firstMaterial?.diffuse.contents = UIColor.systemGreen
        leg2Foot.geometry?.firstMaterial?.diffuse.contents = UIColor.brown

        // Position the legs
        leg1Thigh.position = SCNVector3(-0.2, 0, 0)
        leg1Calf.position = SCNVector3(-0.2, -0.8, 0)
        leg1Foot.position = SCNVector3(-0.2, -1.5, 0)

        leg2Thigh.position = SCNVector3(0.2, 0, 0)
        leg2Calf.position = SCNVector3(0.2, -0.8, 0)
        leg2Foot.position = SCNVector3(0.2, -1.5, 0)

        // Attach the calf and foot to the thighs
        leg1Thigh.addChildNode(leg1Calf)
        leg1Calf.addChildNode(leg1Foot)

        leg2Thigh.addChildNode(leg2Calf)
        leg2Calf.addChildNode(leg2Foot)

        // Attach the legs to the pelvis
        pelvis.addChildNode(leg1Thigh)
        pelvis.addChildNode(leg2Thigh)

        // Attach the knee circle to the scene
        scene.rootNode.addChildNode(knee)
        scene.rootNode.addChildNode(pelvis)

        // Create walking animation
        let pelvisRotation = CABasicAnimation(keyPath: "rotation")
        pelvisRotation.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, -Float.pi / 32))
        pelvisRotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi / 32))
        pelvisRotation.duration = 0.5
        pelvisRotation.autoreverses = true
        pelvisRotation.repeatCount = .infinity

        let hipRotation = CABasicAnimation(keyPath: "rotation")
        hipRotation.fromValue = NSValue(scnVector4: SCNVector4(0, 0, 1, -Float.pi / 16))
        hipRotation.toValue = NSValue(scnVector4: SCNVector4(0, 0, 1, Float.pi / 16))
        hipRotation.duration = 0.5
        hipRotation.autoreverses = true
        hipRotation.repeatCount = .infinity

        let kneeRotation = CABasicAnimation(keyPath: "rotation")
        kneeRotation.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, -Float.pi / 8))
        kneeRotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi / 8))
        kneeRotation.duration = 0.5
        kneeRotation.autoreverses = true
        kneeRotation.repeatCount = .infinity

        // Foot animation (heel lift and step)
        let footLift = CABasicAnimation(keyPath: "position")
        footLift.fromValue = NSValue(scnVector3: SCNVector3(0, -1.5, 0))
        footLift.toValue = NSValue(scnVector3: SCNVector3(0, -1.3, 0))  // Lift foot slightly
        footLift.duration = 0.3
        footLift.autoreverses = true
        footLift.repeatCount = .infinity

        // Apply the animations
        pelvis.addAnimation(pelvisRotation, forKey: "pelvisRotation")
        leg1Thigh.addAnimation(hipRotation, forKey: "hipRotation1")
        leg1Calf.addAnimation(kneeRotation, forKey: "kneeRotation1")
        leg1Foot.addAnimation(footLift, forKey: "footLift1")

        leg2Thigh.addAnimation(hipRotation, forKey: "hipRotation2")
        leg2Calf.addAnimation(kneeRotation, forKey: "kneeRotation2")
        leg2Foot.addAnimation(footLift, forKey: "footLift2")

        // Add light
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(1, 1, 1)
        scene.rootNode.addChildNode(lightNode)

        // Add camera
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 2)
        scene.rootNode.addChildNode(cameraNode)

        // Adjust background based on user interface style
        if UITraitCollection.current.userInterfaceStyle == .dark {
            scene.background.contents = UIColor.black
        } else {
            scene.background.contents = UIColor.white
        }

        return scene
    }







    private func weightDistributionChart() -> some View {
        Chart {
            ForEach(weightData, id: \.day) { data in
                let totalWeight = data.front + data.back
                let frontPercentage = (data.front / totalWeight) * 100
                let backPercentage = (data.back / totalWeight) * 100

                BarMark(x: .value("Day", data.day), y: .value("Weight (%)", frontPercentage))
                    .foregroundStyle(Color.blue)
                BarMark(x: .value("Day", data.day), y: .value("Weight (%)", backPercentage))
                    .foregroundStyle(Color.red)
            }
        }
        .chartYAxisLabel("Weight (%)")
        .chartXAxisLabel("Days of the Week")
    }

    private func strideLengthChart() -> some View {
        Chart {
            ForEach(strideLengthData.indices, id: \.self) { index in
                LineMark(x: .value("Day", index + 1), y: .value("Stride Length (m)", strideLengthData[index]))
                    .foregroundStyle(Color.green)
            }
        }
        .chartYAxisLabel("Stride Length (m)")
        .chartXAxisLabel("Days of the Week")
    }

    private func stepCountChart() -> some View {
        Chart {
            ForEach(stepCountData.indices, id: \.self) { index in
                BarMark(x: .value("Day", index + 1), y: .value("Steps", stepCountData[index]))
                    .foregroundStyle(Color.orange)
            }
        }
        .chartYAxisLabel("Step Count")
        .chartXAxisLabel("Days of the Week")
    }

    private func stabilityScoreChart() -> some View {
        Chart {
            ForEach(stabilityScores.indices, id: \.self) { index in
                LineMark(x: .value("Day", index + 1), y: .value("Stability Score", stabilityScores[index]))
                    .foregroundStyle(Color.purple)
            }
        }
        .chartYAxisLabel("Stability Score")
        .chartXAxisLabel("Days of the Week")
    }

    private func insightsForWeight() -> some View {
        insightsTemplate(
            title: "Weight Distribution",
            text: """
A balanced weight distribution is essential for posture and stability. Deviations of more than 20% in weight distribution may indicate a need for ergonomic adjustments or targeted strength training to prevent injury.
"""
        )
    }

    private func insightsForStride() -> some View {
        insightsTemplate(
            title: "Stride Length",
            text: """
Consistent stride lengths reflect efficient walking patterns. Noticeable variation in stride length over time may suggest fatigue, changes in gait, or early signs of musculoskeletal issues.
"""
        )
    }

    private func insightsForSteps() -> some View {
        insightsTemplate(
            title: "Step Count",
            text: """
Regular step counts above 10,000 are a good indicator of an active lifestyle. Significant drops in daily steps could indicate sedentary behavior or health issues that require attention.
"""
        )
    }

    private func insightsForStability() -> some View {
        insightsTemplate(
            title: "Stability Score",
            text: """
Stability scores below 75 may signal poor balance, potentially increasing the risk of falls. Regular exercises focusing on core strength and balance can help improve stability over time.
"""
        )
    }

    private func insightsTemplate(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Insights: \(title)")
                .font(.headline)
                .padding(.bottom, 5)
            Text(text)
                .foregroundColor(.gray)
        }
    }

    private func generateAIInsight() {
        // Mock AI insight generation
        let insights = [
            "Your weight distribution indicates a stronger reliance on the front, suggesting potential posture adjustments.",
            "Stride length fluctuations suggest uneven gait efficiency. Targeted exercises may stabilize this metric.",
            "Step count trends show active weekdays but significant drops on weekends, highlighting rest days.",
            "Stability scores reveal a consistent balance, though Monday shows a slight dip worth monitoring."
        ]
        aiGeneratedInsight = insights[selectedMetricIndex]
    }
}

struct WeightDistribution {
    let day: String
    let front: Double
    let back: Double
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
            .preferredColorScheme(.dark)
    }
}


