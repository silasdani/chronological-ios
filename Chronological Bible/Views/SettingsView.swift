import SwiftUI

struct SettingsView: View {
    @ObservedObject var notificationManager: NotificationManager
    @ObservedObject var dataManager: BibleDataManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Reminders")
                                .font(.headline)
                            Text("Get notified to read your daily Bible passage")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $notificationManager.userWantsNotifications)
                            .onChange(of: notificationManager.userWantsNotifications) { _, newValue in
                                if newValue {
                                    notificationManager.requestNotificationPermission()
                                }
                                // Do nothing when turning off; state is handled by didSet in NotificationManager
                            }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("You'll receive a daily reminder at the time you set below.")
                }
                
                if notificationManager.userWantsNotifications && !notificationManager.isNotificationsEnabled {
                    Section {
                        Text("Notifications are disabled in iOS Settings. Please enable them in Settings > Notifications > Chronological Bible.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                if notificationManager.isNotificationsEnabled {
                    Section {
                        DatePicker(
                            "Reminder Time",
                            selection: $notificationManager.notificationTime,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: notificationManager.notificationTime) { _, newTime in
                            notificationManager.updateNotificationTime(newTime)
                        }
                    } header: {
                        Text("Reminder Time")
                    } footer: {
                        Text("Choose when you'd like to receive your daily Bible reading reminder.")
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Reading Progress")
                                .font(.headline)
                        }
                        
                        let progress = dataManager.getCompletionProgress()
                        let currentDay = dataManager.getCurrentDayNumber()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Completed: \(progress.completed) of \(progress.total) days")
                                .font(.subheadline)
                            
                            Text("Current day: \(currentDay)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button("Mark All to Date") {
                                dataManager.markAllToDate()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Reading Progress")
                } footer: {
                    Text("Mark all readings up to today as completed. This is useful if you want to catch up on your reading progress.")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("About This App")
                                .font(.headline)
                        }
                        
                        Text("This app helps you follow a chronological Bible reading plan throughout the year. Each day shows you which passages to read in the order they occurred historically.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Information")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("© 2025 Chronological Bible Reader")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }
                
                Section {
                    NavigationLink(destination: SummariesView(dataManager: dataManager)) {
                        HStack {
                            Image(systemName: "text.bubble")
                                .foregroundColor(.purple)
                            Text("View All Summaries")
                                .font(.headline)
                        }
                    }
                } header: {
                    Text("Summaries")
                } footer: {
                    Text("See a high-level overview of all summaries for the readings.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Removed Done button as it's unused
            }
        }
    }
} 