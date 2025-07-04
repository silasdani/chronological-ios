import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    @Published var isNotificationsEnabled = false
    @Published var notificationTime = Date()
    var dataManager: BibleDataManager? = nil // Set this from outside
    
    init() {
        checkNotificationStatus()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = granted
                if granted {
                    self.scheduleNotifications()
                }
            }
        }
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleNotifications() {
        // Remove existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "📖 Time for Your Daily Bible Reading!"
        
        // Get today's reading asynchronously
        Task { @MainActor in
            if let reading = dataManager?.getCurrentDayReading() {
                content.body = "Today's reading: \(reading.text). Tap to start your spiritual journey!"
            } else {
                content.body = "Discover today's chronological journey through Scripture. Your spiritual growth awaits!"
            }
            
            content.sound = .default
            content.badge = 1
            content.categoryIdentifier = "BIBLE_READING"
            
            // Create date components for the notification time
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: self.notificationTime)
            
            // Create trigger
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            // Create request
            let request = UNNotificationRequest(
                identifier: "bibleReadingReminder",
                content: content,
                trigger: trigger
            )
            
            // Schedule notification
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                } else {
                    print("Bible reading notification scheduled successfully")
                }
            }
            
            // Set up notification categories for actions
            self.setupNotificationCategories()
        }
    }
    
    func schedulePersonalizedNotification(for reading: String, day: Int) {
        let content = UNMutableNotificationContent()
        content.title = "📖 Day \(day): Your Bible Reading Awaits!"
        content.body = "Today's reading: \(reading). Tap to start your spiritual journey!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "BIBLE_READING"
        
        // Create date components for the notification time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: notificationTime)
        
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "personalizedBibleReading",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling personalized notification: \(error)")
            } else {
                print("Personalized Bible reading notification scheduled successfully")
            }
        }
    }
    
    private func setupNotificationCategories() {
        let openAppAction = UNNotificationAction(
            identifier: "OPEN_APP",
            title: "Open BibleReader",
            options: [.foreground]
        )
        
        let markCompleteAction = UNNotificationAction(
            identifier: "MARK_COMPLETE",
            title: "Mark as Read",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "BIBLE_READING",
            actions: [openAppAction, markCompleteAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func updateNotificationTime(_ newTime: Date) {
        notificationTime = newTime
        if isNotificationsEnabled {
            scheduleNotifications()
        }
    }
    
    func toggleNotifications() {
        if isNotificationsEnabled {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            isNotificationsEnabled = false
        } else {
            requestNotificationPermission()
        }
    }
    
    // Method to get a personalized notification message based on current day
    func getPersonalizedNotificationMessage(for day: Int) -> String {
        let messages = [
            "🌟 Day \(day): Continue your journey through God's Word today!",
            "📚 Day \(day): Discover the next chapter in your chronological Bible reading.",
            "🙏 Day \(day): Time to connect with Scripture and grow in faith.",
            "✨ Day \(day): Your daily dose of spiritual wisdom awaits!",
            "💫 Day \(day): Step into today's biblical narrative and find inspiration.",
            "📖 Day \(day): The story continues - dive into today's reading!",
            "🌟 Day \(day): Your chronological journey through Scripture continues.",
            "📚 Day \(day): Unlock the next piece of biblical history today!"
        ]
        
        return messages[day % messages.count]
    }
} 