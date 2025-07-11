//
//  Chronological_BibleApp.swift
//  Chronological Bible
//
//  Created by Silas Daniel on 04.07.2025.
//

import SwiftUI
import UIKit
import UserNotifications

@main
struct Chronological_BibleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = self

        // Remove all pending and delivered notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()

        // Print all pending notifications at launch
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Pending notifications at launch:")
            for req in requests {
                print("\(req.identifier): \(req.content.title) - \(req.content.body)")
            }
        }

        // Clear badge when app launches
        clearBadge()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Clear badge when app becomes active
        clearBadge()
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Clear badge when notification is tapped
        clearBadge()
        
        // Handle different notification actions
        switch response.actionIdentifier {
        case "OPEN_APP":
            // App will open automatically
            break
        case "MARK_COMPLETE":
            // Handle mark as complete action if needed
            break
        default:
            // Default notification tap
            break
        }
        
        completionHandler()
    }
    
    private func clearBadge() {
        // Clear badge count and update last notification date
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("Error clearing badge: \(error)")
            }
        }
        // Update last notification date to prevent badge accumulation
        UserDefaults.standard.set(Date(), forKey: "LastNotificationDate")
    }
}
