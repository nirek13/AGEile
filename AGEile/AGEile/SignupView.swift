import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// User Profile model
struct UserProfile {
    var username: String
    var email: String
    var age: Int
    var weight: Double
    var height: Double
}

struct SignupView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var age = ""
    @State private var weight = ""
    @State private var height = ""
    @State private var errorMessage = ""
    @State private var isSignedUp = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Sign Up")
                    .font(.largeTitle)
                    .bold()

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Age", text: $age)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                TextField("Weight (kg)", text: $weight)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                
                TextField("Height (cm)", text: $height)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button("Sign Up") {
                    registerUser()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

                NavigationLink(destination: HomeView(), isActive: $isSignedUp) {
                    EmptyView()
                }
            }
            .padding()
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
                    height: heightDouble
                )
                
                saveUserProfile(userProfile: newUserProfile)
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
            "height": userProfile.height
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

