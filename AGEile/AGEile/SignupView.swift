import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// User Profile model
struct UserProfile: Codable {
    var username: String
    var email: String
    var age: Int
    var weight: Double
    var height: Double
    var activityLevel: String
    var healthConditions: String
    var medications: String
    var historyOfFalls: Bool
    var role: String // Added role
}

struct SignupView: View {
    
    @State private var currentPage = 0
    @State private var email = ""
    @State private var password = ""
    @State private var age = ""
    @State private var weight = ""
    @State private var height = ""
    @State private var activityLevel = "Sedentary"
    @State private var healthConditions = ""
    @State private var medications = ""
    @State private var historyOfFalls = false
    @State private var role = "Patient" // Default role
    @State private var errorMessage = ""
    @State private var isSignedUp = false

    // Save data to UserDefaults
    private func saveUserProfileToLocal(userProfile: UserProfile) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Pure black background
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()

                    Text("Sign Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    // Slideshow - Show questions based on currentPage
                    Group {
                        if currentPage == 0 {
                            QuestionView(title: "Email", text: $email, isSecure: false)
                        } else if currentPage == 1 {
                            QuestionView(title: "Password", text: $password, isSecure: true)
                        } else if currentPage == 2 {
                            QuestionView(title: "Age", text: $age, isSecure: false)
                        } else if currentPage == 3 {
                            QuestionView(title: "Weight (kg)", text: $weight, isSecure: false)
                        } else if currentPage == 4 {
                            QuestionView(title: "Height (cm)", text: $height, isSecure: false)
                        } else if currentPage == 5 {
                            PickerView(title: "Activity Level", selection: $activityLevel)
                        } else if currentPage == 6 {
                            QuestionView(title: "Health Conditions", text: $healthConditions, isSecure: false)
                        } else if currentPage == 7 {
                            QuestionView(title: "Medications", text: $medications, isSecure: false)
                        } else if currentPage == 8 {
                            ToggleView(title: "History of Falls", isOn: $historyOfFalls)
                        } else if currentPage == 9 {
                            PickerView(title: "Are you a Doctor or Patient?", selection: $role) // New question
                        }
                    }
                    .padding(.horizontal, 20)
                    .animation(.easeInOut, value: currentPage)
                    
                    // Error message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 10)
                            .padding(.bottom, 20)
                    }

                    // Navigation and Progress Bar
                    HStack {
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }) {
                                Text("Back")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.gray.opacity(0.4))
                                    .cornerRadius(8)
                                    .padding(.trailing)
                            }
                        }

                        Spacer()

                        Button(action: {
                            if currentPage < 9 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                registerUser()
                            }
                        }) {
                            Text(currentPage < 9 ? "Next" : "Sign Up")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)

                    // Progress Bar
                    ProgressBar(progress: CGFloat(currentPage) / 9)

                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    // Firebase signup function
    private func registerUser() {
        guard isValidEmail(email) else {
            errorMessage = "Invalid email format."
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long."
            return
        }
        
        guard let ageInt = Int(age), let weightDouble = Double(weight), let heightDouble = Double(height) else {
            errorMessage = "Please enter valid numerical values for age, weight, and height."
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Error: \(error.localizedDescription)"
            } else {
                let newUserProfile = UserProfile(
                    username: result?.user.uid ?? "",
                    email: email,
                    age: ageInt,
                    weight: weightDouble,
                    height: heightDouble,
                    activityLevel: activityLevel,
                    healthConditions: healthConditions,
                    medications: medications,
                    historyOfFalls: historyOfFalls,
                    role: role // Store the role as part of the user profile
                )
                
                saveUserProfile(userProfile: newUserProfile)
                saveUserProfileToLocal(userProfile: newUserProfile)
                errorMessage = "Sign up successful!"
                isSignedUp = true // Trigger navigation to HomeView
            }
        }
    }
    
    // Save user profile to Firestore
    private func saveUserProfile(userProfile: UserProfile) {
        let db = Firestore.firestore()
        db.collection("users").document(userProfile.username).setData([
            "email": userProfile.email,
            "age": userProfile.age,
            "weight": userProfile.weight,
            "height": userProfile.height,
            "activityLevel": userProfile.activityLevel,
            "healthConditions": userProfile.healthConditions,
            "medications": userProfile.medications,
            "historyOfFalls": userProfile.historyOfFalls,
            "role": userProfile.role // Store role
        ]) { error in
            if let error = error {
                print("Error saving user profile: \(error)")
            }
        }
    }
    
    // Validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}

struct QuestionView: View {
    var title: String
    @Binding var text: String
    var isSecure: Bool
    
    var body: some View {
        VStack {
            if isSecure {
                SecureField(title, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            } else {
                TextField(title, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }
}

struct PickerView: View {
    var title: String
    @Binding var selection: String
    
    var body: some View {
        VStack {
            Picker(title, selection: $selection) {
                if title == "Are you a Doctor or Patient?" {
                    Text("Patient").tag("Patient")
                    Text("Doctor").tag("Doctor")
                } else {
                    Text("Sedentary").tag("Sedentary")
                    Text("Moderate").tag("Moderate")
                    Text("Active").tag("Active")
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .foregroundColor(.white)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
    }
}

struct ToggleView: View {
    var title: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack {
            Toggle(isOn: $isOn) {
                Text(title)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
    }
}

struct ProgressBar: View {
    var progress: CGFloat
    
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(height: 5)
            
            Capsule()
                .fill(Color.green)
                .frame(width: progress * UIScreen.main.bounds.width, height: 5)
        }
        .padding(.top, 20)
    }
}


