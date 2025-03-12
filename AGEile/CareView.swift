import SwiftUI
import UserNotifications

struct CareView: View {
    @State private var exercises: [Exercise] = [
        Exercise(name: "Toe Raises", description: "Strengthens your shin muscles for improved foot control.", guide: "1. Stand upright, feet shoulder-width apart.\n2. Slowly raise your toes while keeping your heels on the ground.\n3. Hold for 3 seconds, then lower.\n4. Repeat 10 times."),
        Exercise(name: "Heel Walks", description: "Improves balance and strengthens ankle muscles.", guide: "1. Stand tall, lift your toes off the ground.\n2. Walk forward on your heels for 20 steps.\n3. Rest and repeat.")
    ]
    @State private var doctorAppointmentDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var events: [Event] = [
        Event(title: "Doctor's Appointment", date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date())
    ]
    @State private var showingAddEventView = false
    @State private var showingDiaryView = false
    @State private var streakCount = 2 // Track streak count for "Great" gait days
    @State private var maxStreakCount = 7 // Example max streak target (1 week)
    @State private var gaitDiaryEntries: [GaitDiaryEntry] = [] // Array to hold all diary entries
    
    // Accent colors for vibrant dark mode
    let accentColor = Color(red: 0.4, green: 0.7, blue: 1.0)
    let secondaryAccentColor = Color(red: 0.8, green: 0.4, blue: 1.0)
    let cardBackgroundColor = Color(red: 0.12, green: 0.12, blue: 0.15)
    let mainBackgroundColor = Color(red: 0.08, green: 0.08, blue: 0.1)
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notifications permission granted.")
            } else {
                print("Notifications permission denied.")
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                mainBackgroundColor.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerView
                        exercisesView
                        scheduleView
                        streakTrackerView
                        diaryButtonView
                        previousEntriesView
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddEventView) {
            AddEventView(events: $events)
        }
        .sheet(isPresented: $showingDiaryView) {
            DiaryEntryView(gaitDiaryEntries: $gaitDiaryEntries)
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Care")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
            Text("Your Personalized Health Assistant")
                .font(.system(size: 18))
                .foregroundColor(Color.gray.opacity(0.8))
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }

    private var exercisesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI-Suggested Exercises")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            ForEach(exercises) { exercise in
                ExerciseCardView(exercise: exercise, accentColor: accentColor, backgroundColor: cardBackgroundColor)
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }

    private var scheduleView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Schedule")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Spacer()
                Button(action: { showingAddEventView.toggle() }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(accentColor)
                        .clipShape(Circle())
                }
            }
            
            if events.isEmpty {
                Text("No upcoming events")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(events.sorted(by: { $0.date < $1.date })) { event in
                    EventRowView(event: event, events: $events, accentColor: accentColor)
                }
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }

    private var streakTrackerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Streak Tracker")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            HStack {
                Spacer()
                VStack(spacing: 16) {
                    ZStack {
                        CircularProgressView(
                            currentValue: Double(streakCount),
                            maxValue: Double(maxStreakCount),
                            primaryColor: accentColor,
                            secondaryColor: secondaryAccentColor
                        )
                        .frame(width: 150, height: 150)
                        
                        VStack {
                            Text("\(streakCount)")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.white)
                            Text("days")
                                .font(.subheadline)
                                .foregroundColor(accentColor)
                        }
                    }
                    
                    Text("Great Gait Days: \(streakCount)/\(maxStreakCount)")
                        .font(.headline)
                        .foregroundColor(accentColor)
                }
                Spacer()
            }
            
            Text("Keep up the good work!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private var diaryButtonView: some View {
        Button(action: {
            showingDiaryView = true
        }) {
            HStack {
                Image(systemName: "pencil.and.outline")
                    .font(.title2)
                Text("Write in Gait Diary")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [accentColor, secondaryAccentColor]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }

    private var previousEntriesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Previous Diary Entries")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            if gaitDiaryEntries.isEmpty {
                Text("No entries yet")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(gaitDiaryEntries.sorted(by: { $0.date > $1.date }).prefix(3)) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(formattedDate(entry.date))
                                .font(.headline)
                                .foregroundColor(accentColor)
                            
                            Spacer()
                            
                            Text(formattedTime(entry.date))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Text(entry.entry)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(cardBackgroundColor.opacity(0.7))
                    .cornerRadius(12)
                }
                
                if gaitDiaryEntries.count > 3 {
                    Button(action: {
                        showingDiaryView = true
                    }) {
                        Text("View All Entries")
                            .font(.subheadline.bold())
                            .foregroundColor(accentColor)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DiaryEntryView: View {
    @Binding var gaitDiaryEntries: [GaitDiaryEntry]
    @State private var newEntry: String = ""
    @State private var isShowingAllEntries = false
    @Environment(\.presentationMode) var presentationMode
    
    let accentColor = Color(red: 0.4, green: 0.7, blue: 1.0)
    let secondaryAccentColor = Color(red: 0.8, green: 0.4, blue: 1.0)
    let cardBackgroundColor = Color(red: 0.12, green: 0.12, blue: 0.15)
    let mainBackgroundColor = Color(red: 0.08, green: 0.08, blue: 0.1)
    
    var body: some View {
        NavigationView {
            ZStack {
                mainBackgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    if !isShowingAllEntries {
                        // New entry view
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Gait Diary Entry")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextEditor(text: $newEntry)
                                .foregroundColor(.white)
                                .colorMultiply(cardBackgroundColor)
                                .cornerRadius(12)
                                .frame(minHeight: 150)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.bottom, 8)
                            
                            if newEntry.isEmpty {
                                Text("Write about your gait experience today...")
                                    .foregroundColor(.gray.opacity(0.7))
                                    .padding(.leading, 6)
                                    .padding(.top, 10)
                                    .allowsHitTesting(false)
                                    .position(x: 180, y: -80)
                            }
                            
                            Button(action: {
                                if !newEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    let entry = GaitDiaryEntry(date: Date(), entry: newEntry)
                                    gaitDiaryEntries.append(entry)
                                    newEntry = ""
                                }
                            }) {
                                Text("Save Entry")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [accentColor, secondaryAccentColor]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(cardBackgroundColor)
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(isShowingAllEntries ? "All Diary Entries" : "Recent Entries")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                isShowingAllEntries.toggle()
                            }) {
                                Text(isShowingAllEntries ? "Show Recent" : "View All")
                                    .font(.subheadline)
                                    .foregroundColor(accentColor)
                            }
                        }
                        
                        if gaitDiaryEntries.isEmpty {
                            Text("No entries yet")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            let sortedEntries = gaitDiaryEntries.sorted(by: { $0.date > $1.date })
                            let displayEntries = isShowingAllEntries ? sortedEntries : Array(sortedEntries.prefix(5))
                            
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(displayEntries) { entry in
                                        DiaryEntryRow(entry: entry, accentColor: accentColor)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(cardBackgroundColor)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarTitle("Gait Diary", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct DiaryEntryRow: View {
    let entry: GaitDiaryEntry
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(formattedDate(entry.date))
                    .font(.headline)
                    .foregroundColor(accentColor)
                
                Spacer()
                
                Text(formattedTime(entry.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(entry.entry)
                .font(.body)
                .foregroundColor(.white)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(red: 0.15, green: 0.15, blue: 0.18))
        .cornerRadius(12)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ExerciseCardView: View {
    let exercise: Exercise
    let accentColor: Color
    let backgroundColor: Color

    var body: some View {
        NavigationLink(destination: ExerciseDetailView(exercise: exercise, accentColor: accentColor, backgroundColor: backgroundColor)) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(exercise.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(accentColor)
                    .font(.system(size: 14, weight: .bold))
            }
            .padding()
            .background(backgroundColor.opacity(0.7))
            .cornerRadius(12)
        }
    }
}

struct EventRowView: View {
    let event: Event
    @Binding var events: [Event]
    let accentColor: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(event.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: { removeEvent(event) }) {
                Image(systemName: "trash")
                    .foregroundColor(Color.red.opacity(0.8))
                    .font(.system(size: 14))
                    .padding(8)
                    .background(Color.red.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(red: 0.15, green: 0.15, blue: 0.18))
        .cornerRadius(12)
    }

    private func removeEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise
    let accentColor: Color
    let backgroundColor: Color

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.1).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(exercise.name)
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text(exercise.description)
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                    
                    Text("How to Perform")
                        .font(.title2.bold())
                        .foregroundColor(accentColor)
                    
                    Text(exercise.guide)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(backgroundColor)
                        .cornerRadius(12)
                    
                    Spacer()
                    
                    // Example timer button
                    Button(action: {
                        // Add timer functionality
                    }) {
                        HStack {
                            Image(systemName: "timer")
                                .font(.title3)
                            Text("Start Exercise Timer")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [accentColor, Color(red: 0.4, green: 0.4, blue: 0.9)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddEventView: View {
    @Binding var events: [Event]
    @State private var title: String = ""
    @State private var date: Date = Date()
    @Environment(\.presentationMode) var presentationMode
    
    let accentColor = Color(red: 0.4, green: 0.7, blue: 1.0)
    let mainBackgroundColor = Color(red: 0.08, green: 0.08, blue: 0.1)

    var body: some View {
        NavigationView {
            ZStack {
                mainBackgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Event Title")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("", text: $title)
                            .padding()
                            .background(Color(red: 0.15, green: 0.15, blue: 0.18))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Event Date")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .accentColor(accentColor)
                            .background(Color(red: 0.15, green: 0.15, blue: 0.18))
                            .cornerRadius(10)
                            .colorScheme(.dark)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            let newEvent = Event(title: title, date: date)
                            events.append(newEvent)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Add Event")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : accentColor)
                            .cornerRadius(12)
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .navigationTitle("Add New Event")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CircularProgressView: View {
    let currentValue: Double
    let maxValue: Double
    let primaryColor: Color
    let secondaryColor: Color

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 10)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: CGFloat(min(currentValue / maxValue, 1.0)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [primaryColor, secondaryColor]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(), value: currentValue)
        }
    }
}

struct GaitDiaryEntry: Identifiable {
    let id = UUID()
    let date: Date
    let entry: String
}

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let guide: String
}

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
}

struct CareView_Previews: PreviewProvider {
    static var previews: some View {
        CareView()
    }
}
