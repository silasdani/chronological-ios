import SwiftUI

struct CalendarView: View {
    @ObservedObject var dataManager: BibleDataManager
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedDay: Int?
    
    private let months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Month selector
                monthSelector
                
                // Calendar grid
                calendarGrid
                
                // Selected day details
                if let selectedDay = selectedDay,
                   let reading = dataManager.getReadingForDay(selectedDay) {
                    selectedDayDetails(reading)
                }
                
                Spacer()
            }
            .navigationTitle("Bible Reading Calendar")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button(action: {
                if selectedMonth > 1 {
                    selectedMonth -= 1
                } else {
                    selectedMonth = 12
                    selectedYear -= 1
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text("\(months[selectedMonth - 1]) " + String(selectedYear))
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                if selectedMonth < 12 {
                    selectedMonth += 1
                } else {
                    selectedMonth = 1
                    selectedYear += 1
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(uiColor: .systemGray6))
    }
    
    private var calendarGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                // Day headers
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(height: 25)
                }
                
                // Calendar days - simplified to show all readings for the month
                ForEach(getReadingsForSelectedMonth(), id: \.day) { reading in
                    CalendarDayView(
                        reading: reading,
                        isSelected: selectedDay == reading.day,
                        isToday: isToday(reading),
                        isCompleted: dataManager.isReadingCompleted(reading.day)
                    ) {
                        selectedDay = selectedDay == reading.day ? nil : reading.day
                    }
                }
            }
            .padding()
        }
    }
    
    private func getReadingsForSelectedMonth() -> [BibleReading] {
        return dataManager.readings.filter { reading in
            let monthString = getMonthFromDate(reading.date)
            return monthString == selectedMonth
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
    
    private func selectedDayDetails(_ reading: BibleReading) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Day \(reading.day)")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(reading.date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(reading.text)
                .font(.body)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            HStack {
                Button("Today") {
                    goToToday()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button(dataManager.isReadingCompleted(reading.day) ? "Mark as Unread" : "Mark as Read") {
                    dataManager.toggleReadingCompletion(reading.day)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func goToToday() {
        let calendar = Calendar.current
        selectedMonth = calendar.component(.month, from: Date())
        selectedYear = calendar.component(.year, from: Date())
        selectedDay = nil
    }
    
    private func isToday(_ reading: BibleReading) -> Bool {
        let calendar = Calendar.current
        let startOfYear = calendar.dateInterval(of: .year, for: Date())?.start ?? Date()
        let daysSinceStart = calendar.dateComponents([.day], from: startOfYear, to: Date()).day ?? 0
        let currentDay = daysSinceStart + 1
        
        return reading.day == currentDay
    }
}

struct CalendarDayView: View {
    let reading: BibleReading
    let isSelected: Bool
    let isToday: Bool
    let isCompleted: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(reading.day)")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(reading.text)
                    .font(.caption2)
                    .lineLimit(4)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 2)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return Color.green.opacity(0.2)
        } else if isSelected {
            return Color.blue.opacity(0.1)
        } else if isToday {
            return Color.orange.opacity(0.2)
        } else {
            return Color(uiColor: .systemBackground)
        }
    }
} 