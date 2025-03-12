import SwiftUI
import GoogleGenerativeAI
import MarkdownUI
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (1, 1, 1, 0)
//        }
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}
// MARK: - Theme Colors
struct AppTheme {
    static let background = Color(hex: "121212")
    static let surface = Color(hex: "1E1E1E")
    static let primary = Color(hex: "BB86FC")
    static let secondary = Color(hex: "03DAC6")
    static let accent = Color(hex: "CF6679")
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
}

// MARK: - Models
struct User: Identifiable {
    let id = UUID()
    var name: String
    var userID: String
    var alias: String
}

struct ChatMessage: Identifiable {
    let id = UUID()
    var content: String
    var isUser: Bool
}

struct Exercise2: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var steps: [String]
    var duration: String
    var difficulty: String
    var imageURL: String
    var completed: Bool = false
}

// MARK: - Color Extension

// MARK: - Views
struct RoundedCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContactsView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Chat")
                }
                .tag(0)
            
            Exercise2GuideView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Exercise2s")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(2)
        }
        .accentColor(AppTheme.primary)
        .preferredColorScheme(.dark)
    }
}

struct ContactsView: View {
    @State private var users: [User] = [
        User(name: "AGEile AI", userID: "1", alias: "AI Assistant"),
        User(name: "Doctor", userID: "2", alias: "Dr. Smith"),
        User(name: "Family Member", userID: "3", alias: "John Doe")
    ]
    
    @State private var newUserName = ""
    @State private var newUserID = ""
    @State private var newAlias = ""
    @State private var showingAddContactSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.edgesIgnoringSafeArea(.all)
                
                VStack {
                    List {
                        ForEach(users) { user in
                            NavigationLink(destination: ChatView(userName: user.name)) {
                                HStack {
                                    Circle()
                                        .fill(AppTheme.primary)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Text(String(user.name.prefix(1)))
                                                .foregroundColor(AppTheme.background)
                                                .fontWeight(.bold)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(user.name)
                                            .font(.headline)
                                            .foregroundColor(AppTheme.textPrimary)
                                        Text(user.alias)
                                            .font(.subheadline)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    .padding(.leading, 8)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(AppTheme.surface)
                                )
                            }
                            .listRowBackground(AppTheme.background)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarTitle("Contacts", displayMode: .inline)
            .navigationBarItems(
                leading: Text("AGEile")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.primary),
                trailing: Button(action: {
                    showingAddContactSheet.toggle()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(AppTheme.primary)
                }
            )
            .sheet(isPresented: $showingAddContactSheet) {
                AddContactSheet(
                    newUserName: $newUserName,
                    newUserID: $newUserID,
                    newAlias: $newAlias,
                    users: $users,
                    showingAddContactSheet: $showingAddContactSheet
                )
            }
        }
        .accentColor(AppTheme.primary)
    }
}

struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var newMessage: String = ""
    @State private var isTyping: Bool = false
    @State private var currentResponseIndex: Int = 0
    @State private var showingExercise2Recommendation = false
    
    var userName: String
    
    private let aiResponses = [
        "Based on your data from the last 7 days it seems that you have a slight foot drag, which may pose a tripping hazard and result in a potential fall risk.",
        "It seems I have already included an Exercise for you in the Exercise Guide tab. Would you like to see it now?",
        "Sure thing Nirek, I booked an appointment for you tommorow!",
        "I'm not sure about that. Could you rephrase?",
        "Thank you for your message. Let me check that for you."
    ]
    
    var body: some View {
        ZStack {
            AppTheme.background.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Chat header
                HStack {
                    Spacer()
                    Text(userName)
                        .font(.headline)
                        .foregroundColor(AppTheme.primary)
                    Spacer()
                }
                .padding(.vertical, 8)
                .background(AppTheme.surface)
                
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
                                        .background(AppTheme.primary)
                                        .foregroundColor(AppTheme.background)
                                        .cornerRadius(18)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                } else {
                                    Markdown(message.content)
                                        .padding(12)
                                        .background(AppTheme.surface)
                                        .foregroundColor(AppTheme.textPrimary)
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
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(AppTheme.primary)
                                        .frame(width: 10, height: 10)
                                        .opacity(0.7)
                                    Circle()
                                        .fill(AppTheme.primary)
                                        .frame(width: 10, height: 10)
                                        .opacity(0.5)
                                    Circle()
                                        .fill(AppTheme.primary)
                                        .frame(width: 10, height: 10)
                                        .opacity(0.3)
                                }
                                .padding(8)
                                .background(AppTheme.surface)
                                .cornerRadius(16)
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 20)
                }
                
                // Input area
                HStack {
                    TextField("Type a message...", text: $newMessage)
                        .padding(12)
                        .background(AppTheme.surface)
                        .foregroundColor(AppTheme.textPrimary)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .padding(.leading)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .padding(12)
                            .background(AppTheme.primary)
                            .foregroundColor(AppTheme.background)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding(.trailing)
                }
                .padding(.vertical, 10)
                .background(AppTheme.surface)
            }
            
            if showingExercise2Recommendation {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showingExercise2Recommendation = false
                    }
                
                VStack {
                    Text("Exercise Recommendation")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                        .padding()
                    
                    Text("Heel Walks")
                        .font(.title3)
                        .foregroundColor(AppTheme.primary)
                        .padding(.bottom, 10)
                    
                    Text("This Exercise helps strengthen ankle muscles to reduce foot drag. Tap to view in Exercise Guide.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.horizontal)
                    
                    Button("View Exercise Guide") {
                        showingExercise2Recommendation = false
                        CareView()
                        // Here you would include your tab switching logic
                    }
                    .padding()
                    .background(AppTheme.primary)
                    .foregroundColor(AppTheme.background)
                    .cornerRadius(10)
                    .padding(.top, 10)
                    
                    Button("Dismiss") {
                        showingExercise2Recommendation = false
                    }
                    .padding()
                    .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                .background(AppTheme.surface)
                .cornerRadius(16)
                .shadow(radius: 20)
                .padding(30)
                .transition(.scale)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
        
        // Simulate response delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let response = getAIResponse()
            messages.append(ChatMessage(content: response, isUser: false))
            isTyping = false
            
            // Show Exercise2 recommendation if it's the second response
            if currentResponseIndex == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingExercise2Recommendation = true
                }
            }
        }
    }
    
    private func getAIResponse() -> String {
        let response = aiResponses[currentResponseIndex]
        currentResponseIndex = (currentResponseIndex + 1) % aiResponses.count
        return response
    }
}

struct AddContactSheet: View {
    @Binding var newUserName: String
    @Binding var newUserID: String
    @Binding var newAlias: String
    @Binding var users: [User]
    @Binding var showingAddContactSheet: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Add a New Contact")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.primary)
                        .padding(.top)
                    
                    VStack(spacing: 15) {
                        InputField(placeholder: "User Name", text: $newUserName)
                        InputField(placeholder: "User ID", text: $newUserID)
                        InputField(placeholder: "Alias", text: $newAlias)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    HStack {
                        Button("Cancel") {
                            showingAddContactSheet = false
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(AppTheme.accent)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppTheme.accent, lineWidth: 1)
                        )
                        
                        Button("Add") {
                            if !newUserName.isEmpty && !newUserID.isEmpty && !newAlias.isEmpty {
                                users.append(User(name: newUserName, userID: newUserID, alias: newAlias))
                                newUserName = ""
                                newUserID = ""
                                newAlias = ""
                            }
                            showingAddContactSheet = false
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(AppTheme.background)
                        .background(AppTheme.primary)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct InputField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .foregroundColor(AppTheme.textPrimary)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(AppTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppTheme.primary.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Exercise2 Guide Views
struct Exercise2GuideView: View {
    @State private var Exercise2s: [Exercise2] = [
        Exercise2(
            title: "Ankle Strengthening",
            description: "Helps prevent foot drag by strengthening ankle dorsiflexors",
            steps: [
                "Sit in a chair with your feet flat on the floor",
                "Slowly raise your toes while keeping your heels on the ground",
                "Hold for 5 seconds",
                "Lower your toes back to the floor",
                "Repeat 10 times for 3 sets"
            ],
            duration: "15 minutes",
            difficulty: "Easy",
            imageURL: "ankle_Exercise2"
        ),
        Exercise2(
            title: "Balance Training",
            description: "Improves stability and reduces fall risk",
            steps: [
                "Stand beside a sturdy chair for support if needed",
                "Lift one foot slightly off the ground",
                "Hold the position for 30 seconds",
                "Switch to the other foot",
                "Repeat 5 times for each foot"
            ],
            duration: "20 minutes",
            difficulty: "Moderate",
            imageURL: "balance_Exercise2"
        ),
        Exercise2(
            title: "Gait Training",
            description: "Improves walking pattern and reduces foot drag",
            steps: [
                "Find a clear path to walk in a straight line",
                "Focus on heel-to-toe walking pattern",
                "Take deliberate steps, ensuring your heel strikes first",
                "Walk for 10 steps, then turn around",
                "Complete 5 rounds of walking"
            ],
            duration: "25 minutes",
            difficulty: "Moderate",
            imageURL: "gait_Exercise2"
        )
    ]
    
    @State private var selectedExercise2: Exercise2?
    @State private var showExercise2Detail = false
    @State private var searchText = ""
    
    var filteredExercise2s: [Exercise2] {
        if searchText.isEmpty {
            return Exercise2s
        } else {
            return Exercise2s.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.textSecondary)
                        
                        TextField("Search Exercise2s", text: $searchText)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                    }
                    .padding()
                    .background(AppTheme.surface)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Text("Your Exercise2 Plan")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    Text("Complete these Exercise2s daily to improve stability")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredExercise2s) { Exercise2 in
                                Exercise2Card(Exercise2: Exercise2) {
                                    selectedExercise2 = Exercise2
                                    showExercise2Detail = true
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle("Exercise2 Guide", displayMode: .inline)
            .sheet(isPresented: $showExercise2Detail) {
                if let Exercise2 = selectedExercise2 {
                    Exercise2DetailView(Exercise2: Exercise2, isShowing: $showExercise2Detail)
                }
            }
        }
    }
}

struct Exercise2Card: View {
    let Exercise2: Exercise2
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.primary.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "figure.walk")
                            .font(.system(size: 30))
                            .foregroundColor(AppTheme.primary)
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(Exercise2.title)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(Exercise2.description)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                    
                    HStack {
                        Label(Exercise2.duration, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(AppTheme.secondary)
                        
                        Spacer()
                        
                        Label(Exercise2.difficulty, systemImage: "chart.bar")
                            .font(.caption)
                            .foregroundColor(
                                Exercise2.difficulty == "Easy" ? AppTheme.secondary :
                                Exercise2.difficulty == "Moderate" ? Color.orange :
                                Color.red
                            )
                    }
                }
                .padding(.leading, 8)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

struct Exercise2DetailView: View {
    let Exercise2: Exercise2
    @Binding var isShowing: Bool
    @State private var progress: Double = 0.0
    @State private var currentStep = 0
    @State private var isExercising = false
    @State private var remainingTime = 300 // 5 minutes in seconds
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            AppTheme.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        isShowing = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding()
                            .background(AppTheme.surface)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(Exercise2.title)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        // Save progress or mark as favorite
                    }) {
                        Image(systemName: "heart")
                            .font(.headline)
                            .foregroundColor(AppTheme.accent)
                            .padding()
                            .background(AppTheme.surface)
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Image placeholder
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppTheme.primary.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "figure.walk")
                                    .font(.system(size: 60))
                                    .foregroundColor(AppTheme.primary)
                            )
                            .padding(.horizontal)
                        
                        // Description
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Description")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.primary)
                            
                            Text(Exercise2.description)
                                .foregroundColor(AppTheme.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal)
                        
                        // Metadata
                        HStack(spacing: 20) {
                            VStack {
                                Text("Duration")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(Exercise2.duration)
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(12)
                            
                            VStack {
                                Text("Difficulty")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(Exercise2.difficulty)
                                    .font(.headline)
                                    .foregroundColor(
                                        Exercise2.difficulty == "Easy" ? AppTheme.secondary :
                                        Exercise2.difficulty == "Moderate" ? Color.orange :
                                        Color.red
                                    )
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Steps
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Steps")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.primary)
                            
                            ForEach(0..<Exercise2.steps.count, id: \.self) { index in
                                HStack(alignment: .top) {
                                    ZStack {
                                        Circle()
                                            .fill(index == currentStep && isExercising ? AppTheme.primary : AppTheme.surface)
                                            .frame(width: 30, height: 30)
                                        
                                        Text("\(index + 1)")
                                            .font(.subheadline)
                                            .foregroundColor(index == currentStep && isExercising ? AppTheme.background : AppTheme.textPrimary)
                                    }
                                    
                                    Text(Exercise2.steps[index])
                                        .foregroundColor(AppTheme.textPrimary)
                                        .padding(.leading, 8)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Interactive progress
                        if isExercising {
                            VStack(spacing: 15) {
                                Text("Current Step")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Text(Exercise2.steps[currentStep])
                                    .multilineTextAlignment(.center)
                                    .font(.title3)
                                    .foregroundColor(AppTheme.primary)
                                    .padding()
                                    .background(AppTheme.surface)
                                    .cornerRadius(12)
                                
                                // Timer display
                                Text(timeFormatted(remainingTime))
                                    .font(.system(size: 48, design: .monospaced))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                // Progress bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(AppTheme.surface)
                                            .frame(width: geometry.size.width, height: 20)
                                        
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(AppTheme.primary)
                                            .frame(width: geometry.size.width * progress, height: 20)
                                    }
                                }
                                .frame(height: 20)
                                
                                HStack(spacing: 20) {
                                    Button(action: {
                                        previousStep()
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.left")
                                            Text("Previous")
                                        }
                                        .foregroundColor(AppTheme.textPrimary)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(AppTheme.surface)
                                        .cornerRadius(12)
                                    }
                                    .disabled(currentStep == 0)
                                    .opacity(currentStep == 0 ? 0.5 : 1)
                                    
                                    Button(action: {
                                        nextStep()
                                    }) {
                                        HStack {
                                            Text("Next")
                                            Image(systemName: "arrow.right")
                                        }
                                        .foregroundColor(AppTheme.background)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(AppTheme.primary)
                                        .cornerRadius(12)
                                    }
                                    .disabled(currentStep == Exercise2.steps.count - 1)
                                    .opacity(currentStep == Exercise2.steps.count - 1 ? 0.5 : 1)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppTheme.background)
                                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                            )
                            .padding()
                        }
                    }
                    .padding(.bottom, 100)
                }
                
                // Start/Stop button
                Button(action: {
                    if isExercising {
                        stopExercise2()
                                            } else {
                                                startExercise2()
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: isExercising ? "stop.fill" : "play.fill")
                                                Text(isExercising ? "Stop Exercise2" : "Start Exercise2")
                                            }
                                            .font(.headline)
                                            .foregroundColor(isExercising ? AppTheme.background : AppTheme.textPrimary)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(isExercising ? AppTheme.accent : AppTheme.primary)
                                            .cornerRadius(16)
                                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                        }
                                        .padding()
                                        .background(AppTheme.background)
                                    }
                                }
                            }
                            
                            private func startExercise2() {
                                isExercising = true
                                progress = 0.0
                                currentStep = 0
                                remainingTime = 300 // 5 minutes
                                
                                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                    if remainingTime > 0 {
                                        remainingTime -= 1
                                        progress = 1.0 - (Double(remainingTime) / 300.0)
                                    } else {
                                        stopExercise2()
                                    }
                                }
                            }
                            
                            private func stopExercise2() {
                                isExercising = false
                                timer?.invalidate()
                                timer = nil
                            }
                            
                            private func nextStep() {
                                if currentStep < Exercise2.steps.count - 1 {
                                    currentStep += 1
                                }
                            }
                            
                            private func previousStep() {
                                if currentStep > 0 {
                                    currentStep -= 1
                                }
                            }
                            
                            private func timeFormatted(_ totalSeconds: Int) -> String {
                                let minutes = totalSeconds / 60
                                let seconds = totalSeconds % 60
                                return String(format: "%02d:%02d", minutes, seconds)
                            }
                        }

                        // MARK: - Profile View
                        struct ProfileView: View {
                            @State private var name = "John Doe"
                            @State private var age = "72"
                            @State private var medicalHistory = "History of falls, mild cognitive impairment"
                            @State private var medications = "Lisinopril, Metformin"
                            @State private var emergencyContact = "Jane Doe (Daughter) 555-123-4567"
                            @State private var isEditing = false
                            
                            var body: some View {
                                NavigationView {
                                    ZStack {
                                        AppTheme.background.edgesIgnoringSafeArea(.all)
                                        
                                        ScrollView {
                                            VStack(spacing: 24) {
                                                // Profile header
                                                VStack {
                                                    Circle()
                                                        .fill(AppTheme.primary)
                                                        .frame(width: 100, height: 100)
                                                        .overlay(
                                                            Text(String(name.prefix(1)))
                                                                .font(.system(size: 40))
                                                                .fontWeight(.bold)
                                                                .foregroundColor(AppTheme.background)
                                                        )
                                                    
                                                    Text(name)
                                                        .font(.title2)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(AppTheme.textPrimary)
                                                    
                                                    Text("Age: \(age)")
                                                        .font(.subheadline)
                                                        .foregroundColor(AppTheme.textSecondary)
                                                }
                                                .padding()
                                                .modifier(RoundedCard())
                                                
                                                // Progress section
                                                VStack(alignment: .leading, spacing: 16) {
                                                    Text("Weekly Progress")
                                                        .font(.headline)
                                                        .foregroundColor(AppTheme.textPrimary)
                                                    
                                                    HStack(spacing: 12) {
                                                        ProgressCircle(value: 0.65, label: "Exercise2s", color: AppTheme.primary)
                                                        ProgressCircle(value: 0.80, label: "Steps", color: AppTheme.secondary)
                                                        ProgressCircle(value: 0.45, label: "Balance", color: AppTheme.accent)
                                                    }
                                                }
                                                .padding()
                                                .modifier(RoundedCard())
                                                
                                                // Health information
                                                VStack(alignment: .leading, spacing: 16) {
                                                    HStack {
                                                        Text("Health Information")
                                                            .font(.headline)
                                                            .foregroundColor(AppTheme.textPrimary)
                                                        
                                                        Spacer()
                                                        
                                                        Button(action: {
                                                            isEditing.toggle()
                                                        }) {
                                                            Text(isEditing ? "Save" : "Edit")
                                                                .font(.subheadline)
                                                                .foregroundColor(AppTheme.primary)
                                                        }
                                                    }
                                                    
                                                    Group {
                                                        ProfileInfoRow(title: "Medical History", value: $medicalHistory, isEditing: isEditing)
                                                        ProfileInfoRow(title: "Medications", value: $medications, isEditing: isEditing)
                                                        ProfileInfoRow(title: "Emergency Contact", value: $emergencyContact, isEditing: isEditing)
                                                    }
                                                }
                                                .padding()
                                                .modifier(RoundedCard())
                                                
                                                // Settings
                                                VStack(alignment: .leading, spacing: 16) {
                                                    Text("Settings")
                                                        .font(.headline)
                                                        .foregroundColor(AppTheme.textPrimary)
                                                    
                                                    Button(action: {}) {
                                                        SettingRow(icon: "bell.fill", title: "Notifications")
                                                    }
                                                    
                                                    Button(action: {}) {
                                                        SettingRow(icon: "lock.fill", title: "Privacy Settings")
                                                    }
                                                    
                                                    Button(action: {}) {
                                                        SettingRow(icon: "person.fill", title: "Account Settings")
                                                    }
                                                    
                                                    Button(action: {}) {
                                                        SettingRow(icon: "questionmark.circle.fill", title: "Help & Support")
                                                    }
                                                }
                                                .padding()
                                                .modifier(RoundedCard())
                                            }
                                            .padding()
                                        }
                                    }
                                    .navigationBarTitle("Profile", displayMode: .inline)
                                }
                            }
                        }

                        struct ProgressCircle: View {
                            var value: Double
                            var label: String
                            var color: Color
                            
                            var body: some View {
                                VStack {
                                    ZStack {
                                        Circle()
                                            .stroke(color.opacity(0.2), lineWidth: 10)
                                            .frame(width: 80, height: 80)
                                        
                                        Circle()
                                            .trim(from: 0, to: CGFloat(value))
                                            .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                            .frame(width: 80, height: 80)
                                            .rotationEffect(.degrees(-90))
                                        
                                        Text("\(Int(value * 100))%")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(AppTheme.textPrimary)
                                    }
                                    
                                    Text(label)
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                        .padding(.top, 8)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }

                        struct ProfileInfoRow: View {
                            var title: String
                            @Binding var value: String
                            var isEditing: Bool
                            
                            var body: some View {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(title)
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    if isEditing {
                                        TextField("", text: $value)
                                            .padding(10)
                                            .background(AppTheme.background)
                                            .cornerRadius(8)
                                            .foregroundColor(AppTheme.textPrimary)
                                    } else {
                                        Text(value)
                                            .font(.body)
                                            .foregroundColor(AppTheme.textPrimary)
                                            .padding(.vertical, 4)
                                    }
                                    
                                    Divider()
                                        .background(AppTheme.textSecondary.opacity(0.3))
                                }
                            }
                        }

                        struct SettingRow: View {
                            var icon: String
                            var title: String
                            
                            var body: some View {
                                HStack {
                                    Image(systemName: icon)
                                        .foregroundColor(AppTheme.primary)
                                        .frame(width: 30)
                                    
                                    Text(title)
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                .padding(.vertical, 8)
                            }
                        }

                       
                            
                        
