import SwiftUI
import GoogleGenerativeAI
import MarkdownUI // Import a Markdown rendering library, e.g., MarkdownUI

// User struct to represent a contact
struct User: Identifiable {
    let id = UUID()
    var name: String
    var imageName: String // For profile image
    var userID: String // Added userID
    var alias: String // Added alias
}

// ChatMessage struct remains unchanged
struct ChatMessage: Identifiable {
    let id = UUID()
    var content: String
    var isUser: Bool
}

struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var newMessage: String = ""
    @State private var isTyping: Bool = false // To control typing animation
    
    var userName: String // The user being chatted with

    var body: some View {
        VStack {
            // AGEile AI Indicator
            HStack {
                Spacer()
                Text(userName)
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
            }
        
            // Chat history scroll view
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(messages) { message in
                        HStack {
                            if message.isUser {
                                Spacer()
                            }
                            if message.isUser {
                                Text(message.content)
                                    .padding(12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(18)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            } else {
                                Markdown(message.content) // Render AI messages with Markdown
                                    .padding(12)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(18)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            if !message.isUser {
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // AI typing animation
                    if isTyping {
                        HStack {
                            Spacer()
                            Text("AI is typing...")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                                .padding(.trailing, 10)
                        }
                    }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal)
            
            // Input area
            HStack {
                TextField("Type a message...", text: $newMessage)
                    .padding(12)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.leading)
                
                Button(action: sendMessage) {
                    Text("Send")
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                }
                .padding(.trailing)
            }
            .padding(.bottom, 10)
            .background(Color(UIColor.systemBackground)) // Adjust for dark mode
            .cornerRadius(20)
            .padding(.horizontal)
        }
        .background(Color(UIColor.systemBackground)) // Adjust for dark mode
    }
    
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        // Add user message
        messages.append(ChatMessage(content: newMessage, isUser: true))
        
        // Clear the input field
        let userInput = newMessage
        newMessage = ""
        
        // Show AI typing animation
        isTyping = true
        
        // Fetch AI response asynchronously
        Task {
            let aiResponse = await generateTextForPrompt(prompt: userInput)
            DispatchQueue.main.async {
                messages.append(ChatMessage(content: aiResponse, isUser: false))
                isTyping = false
            }
        }
    }
    
    // Async function to generate text using the generative AI model
    public func generateTextForPrompt(prompt: String) async -> String {
        let model = GenerativeModel(name: "gemini-1.5-flash-latest", apiKey: "AIzaSyDjru4IHEVpGEqMaUBs7qcjTmi-_hiudZI") // Add your API key here
        do {
            let response = try await model.generateContent(prompt)
            if let text = response.text {
                return text
            } else {
                return "Empty response from AI."
            }
        } catch {
            print("Error generating content: \(error)")
            return "Error generating AI response."
        }
    }
}

struct ContactsView: View {
    @State private var users: [User] = [
        User(name: "AGEile AI", imageName: "person.circle", userID: "1", alias: "AI Assistant"),
        User(name: "Doctor", imageName: "doctor", userID: "2", alias: "Dr. Smith"),
        User(name: "Family Member", imageName: "person.2", userID: "3", alias: "John Doe")
    ]
    
    @State private var newUserName = ""
    @State private var newUserID = ""
    @State private var newAlias = ""
    @State private var newUserImageName = "person.circle" // Default image name
    @State private var showingAddContactSheet = false
    
    var body: some View {
        NavigationView {
            List(users) { user in
                NavigationLink(destination: ChatView(userName: user.name)) {
                    HStack {
                        Image(systemName: user.imageName) // Profile icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.accentColor)
                        
                        Text(user.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.leading)
                        
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.15))
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.black.edgesIgnoringSafeArea(.all)) // Dark background for the list
            
            .navigationBarTitle("Contacts", displayMode: .inline)
            .navigationBarHidden(false)
            .navigationBarItems(
                leading: Text("AGEile").foregroundColor(.white),
                trailing: Button(action: {
                    showingAddContactSheet.toggle()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.accentColor)
                }
            )
        }
        .accentColor(.cyan) // Accent color for navigation links and system icons
        .preferredColorScheme(.dark) // Forcing dark mode
        .sheet(isPresented: $showingAddContactSheet) {
            VStack {
                Text("Add Contact")
                    .font(.title)
                    .padding()

                TextField("User Name", text: $newUserName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("User ID", text: $newUserID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Alias", text: $newAlias)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack {
                    Button("Cancel") {
                        showingAddContactSheet = false
                    }
                    .padding()
                    
                    Button("Add") {
                        // Add new user to the list
                        if !newUserName.isEmpty && !newUserID.isEmpty && !newAlias.isEmpty {
                            users.append(User(name: newUserName, imageName: newUserImageName, userID: newUserID, alias: newAlias))
                            newUserName = "" // Reset input
                            newUserID = "" // Reset input
                            newAlias = "" // Reset input
                            newUserImageName = "person.circle" // Reset default image
                        }
                        showingAddContactSheet = false
                    }
                    .padding()
                }
            }
            .padding()
        }
    }
}

struct ContentView: View {
    var body: some View {
        ContactsView()
    }
}

struct ChatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

