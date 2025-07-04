import Foundation
import SwiftUI

struct BibleDataResponse: Codable {
    let days: [BibleReading]
}

@MainActor
class BibleDataManager: ObservableObject {
    @Published var readings: [BibleReading] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var completedReadings: Set<Int> = []
    
    private let completedReadingsKey = "CompletedReadings"
    
    init() {
        loadCompletedReadings()
        loadBibleReadings()
    }
    
    func loadBibleReadings() {
        isLoading = true
        errorMessage = nil
        
        guard let url = Bundle.main.url(forResource: "ChronologicalBible", withExtension: "json") else {
            errorMessage = "Could not find ChronologicalBible.json file"
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(BibleDataResponse.self, from: data)
            readings = response.days
            isLoading = false
        } catch {
            errorMessage = "Failed to load Bible readings: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func getReadingForDay(_ day: Int) -> BibleReading? {
        return readings.first { $0.day == day }
    }
    
    func getCurrentDayReading() -> BibleReading? {
        let currentDay = getCurrentDayNumber()
        return getReadingForDay(currentDay)
    }
    
    func getCurrentDayNumber() -> Int {
        let calendar = Calendar.current
        let startOfYear = calendar.dateInterval(of: .year, for: Date())?.start ?? Date()
        let daysSinceStart = calendar.dateComponents([.day], from: startOfYear, to: Date()).day ?? 0
        return daysSinceStart + 1
    }
    
    func getReadingsForMonth(_ month: Int) -> [BibleReading] {
        return readings.filter { reading in
            let monthString = getMonthFromDate(reading.date)
            return monthString == month
        }
    }
    
    func isReadingCompleted(_ day: Int) -> Bool {
        return completedReadings.contains(day)
    }
    
    func toggleReadingCompletion(_ day: Int) {
        if completedReadings.contains(day) {
            completedReadings.remove(day)
        } else {
            completedReadings.insert(day)
        }
        saveCompletedReadings()
    }
    
    func markReadingAsCompleted(_ day: Int) {
        completedReadings.insert(day)
        saveCompletedReadings()
    }
    
    func markReadingAsUncompleted(_ day: Int) {
        completedReadings.remove(day)
        saveCompletedReadings()
    }
    
    func markAllToDate() {
        let currentDay = getCurrentDayNumber()
        for day in 1...currentDay {
            completedReadings.insert(day)
        }
        saveCompletedReadings()
    }
    
    func getCompletionProgress() -> (completed: Int, total: Int) {
        return (completedReadings.count, readings.count)
    }
    
    func getCurrentStreak() -> Int {
        let currentDay = getCurrentDayNumber()
        
        var streak = 0
        var day = currentDay
        
        // Count backwards from today to find consecutive completed days
        while day > 0 && completedReadings.contains(day) {
            streak += 1
            day -= 1
        }
        
        return streak
    }
    
    private func loadCompletedReadings() {
        if let data = UserDefaults.standard.data(forKey: completedReadingsKey),
           let completed = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            completedReadings = completed
        }
    }
    
    private func saveCompletedReadings() {
        if let data = try? JSONEncoder().encode(completedReadings) {
            UserDefaults.standard.set(data, forKey: completedReadingsKey)
        }
    }
    
    private func getMonthFromDate(_ dateString: String) -> Int {
        let months = [
            "January": 1, "February": 2, "March": 3, "April": 4,
            "May": 5, "June": 6, "July": 7, "August": 8,
            "September": 9, "October": 10, "November": 11, "December": 12
        ]
        
        for (monthName, monthNumber) in months {
            if dateString.hasPrefix(monthName) {
                return monthNumber
            }
        }
        return 1
    }
} 