//
//  ContentView.swift
//  Chronological Bible
//
//  Created by Silas Daniel on 04.07.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = BibleDataManager()
    @StateObject private var notificationManager = NotificationManager()
    @State private var selectedTab = 0
    @AppStorage("appColorScheme") private var appColorScheme: String = AppColorScheme.system.rawValue

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(dataManager: dataManager, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Today")
                }
                .tag(0)
            
            CalendarView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(1)
            
            SettingsView(notificationManager: notificationManager, dataManager: dataManager)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(.blue)
        .onAppear {
            notificationManager.dataManager = dataManager
        }
        .preferredColorScheme(selectedColorScheme)
    }
    
    private var selectedColorScheme: ColorScheme? {
        switch AppColorScheme(rawValue: appColorScheme) ?? .system {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

#Preview {
    ContentView()
}
