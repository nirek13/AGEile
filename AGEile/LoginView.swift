import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggedIn = false
    @State private var showSignup = false  // State variable to trigger SignupView
    let persistenceController = PersistenceController.shared
    var body: some View {
        VStack(spacing: 20) {
            Text("Login").font(.largeTitle).bold()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            Button("Log In") {
                loginUser()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            // Navigation link to SignupView
            Button("Don't have an account? Sign Up") {
                showSignup = true
            }
            .foregroundColor(.blue)
            
            Spacer()
            
            NavigationLink(destination: HomeView().navigationBarBackButtonHidden(true).environment(\.managedObjectContext, persistenceController.container.viewContext), isActive: $isLoggedIn) {
                EmptyView().environment(\.managedObjectContext, persistenceController.container.viewContext) // Pass the context to the environment
            
            }
            
            NavigationLink(destination: SignupView().navigationBarBackButtonHidden(true).environment(\.managedObjectContext, persistenceController.container.viewContext), isActive: $showSignup) {
                EmptyView().environment(\.managedObjectContext, persistenceController.container.viewContext) // Pass the context to the environment
            
            }

        }
        .padding()
        .navigationBarHidden(true)
    }
    
    // Firebase login function
    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Error: \(error.localizedDescription)"
                isLoggedIn = true
            } else {
                isLoggedIn = true  // Navigate to HomeView on successful login
            }
        }
    }
}

