import SwiftUI
import UserNotifications

struct ReminderView: View {
    @State private var reminderType = "Medicine"
    @State private var reminderDescription = ""
    @State private var date = Date()
    @State private var repeats = false
    
    @State private var reminders: [Reminder] = []
    
    let reminderTypes = ["Medicine", "Activity", "Exercise", "Other"]
    let reminderIcons: [String: String] = [
        "Medicine": "pill.fill",
        "Activity": "figure.walk",
        "Exercise": "sportscourt.fill",
        "Other": "star.fill"
    ]
    
    init() {
        // Request permission for notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notifications permission granted.")
            } else {
                print("Notifications permission denied.")
            }
        }
        
        // Load saved reminders from UserDefaults
        loadReminders()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Reminder Type")) {
                        Picker("Select Reminder Type", selection: $reminderType) {
                            ForEach(reminderTypes, id: \.self) { type in
                                HStack {
                                    Image(systemName: reminderIcons[type] ?? "star")
                                    Text(type)
                                }
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Section(header: Text("Reminder Description")) {
                        TextField("Enter reminder description", text: $reminderDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Section(header: Text("Schedule Reminder")) {
                        DatePicker("Select Reminder Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(GraphicalDatePickerStyle())
                        
                        Toggle(isOn: $repeats) {
                            Text("Repeat Reminder")
                        }
                    }
                    
                    Section {
                        Button(action: {
                            if !reminderDescription.isEmpty {
                                let newReminder = Reminder(type: reminderType, description: reminderDescription)
                                reminders.append(newReminder)
                                saveReminders()
                                scheduleNotification(title: reminderType, body: reminderDescription, at: date, repeats: repeats, id: newReminder.id)
                                reminderDescription = ""
                            }
                        }) {
                            Text("Add Reminder")
                        }
                    }
                    
                    Section(header: Text("Your Reminders")) {
                        List {
                            ForEach(reminders) { reminder in
                                HStack {
                                    Image(systemName: reminderIcons[reminder.type] ?? "star")
                                    VStack(alignment: .leading) {
                                        Text(reminder.type)
                                            .font(.headline)
                                        Text(reminder.description)
                                            .font(.subheadline)
                                    }
                                    Spacer()
                                    Button(action: {
                                        // Edit reminder action
                                        reminderDescription = reminder.description
                                        reminderType = reminder.type
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                    }
                                    Button(action: {
                                        // Remove reminder action
                                        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
                                            let deletedReminder = reminders.remove(at: index)
                                            saveReminders()
                                            removeNotification(reminderId: deletedReminder.id)
                                        }
                                    }) {
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(.red)
                                    }

                                    Button(action: {
                                        // Snooze reminder action (e.g., 10 minutes)
                                        let snoozeTime = Calendar.current.date(byAdding: .minute, value: 10, to: date) ?? date
                                        reminders.removeAll { $0.id == reminder.id }
                                        reminders.append(reminder)
                                        saveReminders()
                                        scheduleNotification(title: reminder.type, body: reminder.description, at: snoozeTime, repeats: reminder.repeats, id: reminder.id)
                                    }) {
                                        Image(systemName: "alarm.fill")
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Reminders")
            }
        }
    }
    
    // Function to schedule a notification
    private func scheduleNotification(title: String, body: String, at date: Date, repeats: Bool, id: UUID) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Create the trigger for the notification
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: repeats)
        
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(date)!")
            }
        }
    }
    
    // Function to remove the notification
    private func removeNotification(reminderId: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                if request.identifier == reminderId.uuidString {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
                    print("Removed notification for \(reminderId)")
                }
            }
        }
    }
    
    // Save reminders to UserDefaults
    private func saveReminders() {
        let encodedData = try? JSONEncoder().encode(reminders)
        UserDefaults.standard.set(encodedData, forKey: "savedReminders")
    }
    
    // Load saved reminders from UserDefaults
    private func loadReminders() {
        if let savedData = UserDefaults.standard.data(forKey: "savedReminders"),
           let decodedReminders = try? JSONDecoder().decode([Reminder].self, from: savedData) {
            reminders = decodedReminders
        }
    }
}

// Reminder struct to conform to Codable
struct Reminder: Identifiable, Codable {
    var id = UUID()  // To make it uniquely identifiable in the list
    var type: String
    var description: String
    var repeats: Bool = false
}

struct ReminderView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderView()
    }
}

