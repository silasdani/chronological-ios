import Foundation
import UserNotifications
import SwiftUI
// import Chronological_BibleApp

// Forward declaration if needed
// class BibleDataManager

class NotificationManager: ObservableObject {
    @Published var isNotificationsEnabled = false // true if user wants notifications AND permission is granted
    @Published var userWantsNotifications = false {
        didSet {
            saveUserWantsNotifications()
            Task { @MainActor in
                self.updateNotificationState()
            }
        }
    }
    @Published var notificationTime = Date()
    // Forward declaration to fix error if BibleDataManager is not yet defined
    class BibleDataManager {
        func getCurrentDayReading() -> String {
            return "Genesis 1-3"
        }
    }
    var dataManager: BibleDataManager? = nil // Set this from outside

    private let notificationTimeKey = "NotificationTime"
    private let userWantsNotificationsKey = "UserWantsNotifications"
    private let badgeCountKey = "BadgeCount"
    private let lastNotificationDateKey = "LastNotificationDate"
    private var permissionGranted = false

    // MARK: - Badge Management
    
    private func getCurrentBadgeCount() -> Int {
        return UserDefaults.standard.integer(forKey: badgeCountKey)
    }
    
    private func setBadgeCount(_ count: Int) {
        UserDefaults.standard.set(count, forKey: badgeCountKey)
        updateAppBadge(count)
    }
    
    private func incrementBadgeCount() {
        let currentCount = getCurrentBadgeCount()
        let newCount = currentCount + 1
        setBadgeCount(newCount)
    }
    
    private func updateAppBadge(_ count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count) { error in
            if let error = error {
                print("Error setting badge count: \(error)")
            }
        }
    }
    
    private func updateBadgeCount() {
        let currentDay = dataManager?.getCurrentDayNumber() ?? 1
        let lastNotificationDate = UserDefaults.standard.object(forKey: lastNotificationDateKey) as? Date ?? Date.distantPast
        
        // Calculate missed days since last notification
        let calendar = Calendar.current
        let daysSinceLastNotification = calendar.dateComponents([.day], from: lastNotificationDate, to: Date()).day ?? 0
        
        if daysSinceLastNotification > 0 {
            // User has missed some days, increment badge accordingly
            let missedDays = min(daysSinceLastNotification, 7) // Cap at 7 days to avoid excessive badges
            let currentBadgeCount = getCurrentBadgeCount()
            setBadgeCount(currentBadgeCount + missedDays)
        }
    }
    
    func clearBadge() {
        setBadgeCount(0)
        UserDefaults.standard.set(Date(), forKey: lastNotificationDateKey)
    }

    init() {
        loadNotificationTime()
        loadUserWantsNotifications()
        checkNotificationStatus()
        updateBadgeCount()
    }

    private func loadNotificationTime() {
        if let timeData = UserDefaults.standard.data(forKey: notificationTimeKey),
           let savedTime = try? JSONDecoder().decode(Date.self, from: timeData) {
            notificationTime = savedTime
        }
    }

    private func loadUserWantsNotifications() {
        if UserDefaults.standard.object(forKey: userWantsNotificationsKey) != nil {
            userWantsNotifications = UserDefaults.standard.bool(forKey: userWantsNotificationsKey)
        } else {
            userWantsNotifications = false
        }
    }

    private func saveUserWantsNotifications() {
        UserDefaults.standard.set(userWantsNotifications, forKey: userWantsNotificationsKey)
    }

    private func saveNotificationTime() {
        if let data = try? JSONEncoder().encode(notificationTime) {
            UserDefaults.standard.set(data, forKey: notificationTimeKey)
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.permissionGranted = granted
                self.updateNotificationState()
                if granted && self.userWantsNotifications {
                    self.scheduleNotifications()
                }
            }
        }
    }

    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.permissionGranted = settings.authorizationStatus == .authorized
                self.updateNotificationState()
            }
        }
    }

    @MainActor
    private func updateNotificationState() {
        self.isNotificationsEnabled = self.userWantsNotifications && self.permissionGranted
        if self.isNotificationsEnabled {
            self.scheduleNotifications()
        } else {
            self.cancelNotifications()
        }
    }

    private func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    @MainActor
    func scheduleNotifications() {
        // Remove existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        // Use only app name for title with debug string
        let debugID = UUID().uuidString.prefix(4)
        let title = "TimeScripture DEBUG \(debugID)"
        var body = "Deschide aplicația pentru citirea de azi."
        if let reading = dataManager?.getCurrentDayReading() {
            if let summary = reading.summary, !summary.isEmpty {
                body = summary
            } else {
                body = "Citește pasajul de azi din \(reading.text)."
            }
        }
        content.title = title
        content.body = body

        content.sound = .default
        // Use dynamic badge count instead of static 1
        let currentBadgeCount = getCurrentBadgeCount()
        content.badge = NSNumber(value: currentBadgeCount + 1)
        content.categoryIdentifier = "BIBLE_READING"

        // Create date components for the notification time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self.notificationTime)

        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        // Create request with a new identifier
        let request = UNNotificationRequest(
            identifier: "bibleReadingReminderV3",
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
            // Print all pending notifications for debugging
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                print("Pending notifications after scheduling:")
                for req in requests {
                    print("\(req.identifier): \(req.content.title) - \(req.content.body)")
                }
            }
        }

        // Set up notification categories for actions
        self.setupNotificationCategories()
    }

    func schedulePersonalizedNotification(for reading: String, day: Int) {
        let content = UNMutableNotificationContent()
        content.title = "TimeScripture"
        content.body = "Citește pasajul de azi din \(reading)."
        content.sound = .default
        // Use dynamic badge count instead of static 1
        let currentBadgeCount = getCurrentBadgeCount()
        content.badge = NSNumber(value: currentBadgeCount + 1)
        content.categoryIdentifier = "BIBLE_READING"

        // Create date components for the notification time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: notificationTime)

        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        // Create request with a new identifier
        let request = UNNotificationRequest(
            identifier: "personalizedBibleReadingV2",
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
            // Print all pending notifications for debugging
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                print("Pending notifications after scheduling:")
                for req in requests {
                    print("\(req.identifier): \(req.content.title) - \(req.content.body)")
                }
            }
        }
    }

    private func setupNotificationCategories() {
        let openAppAction = UNNotificationAction(
            identifier: "OPEN_APP",
            title: "Open TimeScripture",
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

    @MainActor
    func updateNotificationTime(_ newTime: Date) {
        notificationTime = newTime
        saveNotificationTime()
        if isNotificationsEnabled {
            scheduleNotifications()
        }
    }

    func toggleNotifications() {
        userWantsNotifications.toggle()
        if userWantsNotifications && !permissionGranted {
            requestNotificationPermission()
        }
    }

    // Method to get a personalized notification message based on current day
    func getPersonalizedNotificationMessage(for day: Int) -> String {
        let messages = [
            "🌟 Day \(day): Continue your journey through God's Word today!",
            "📚 Day \(day): Discover the next chapter in your TimeScripture reading.",
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