import SwiftUI

struct TodayView: View {
    @ObservedObject var dataManager: BibleDataManager
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if dataManager.isLoading {
                        ProgressView("Loading today's reading...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let errorMessage = dataManager.errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            Text("Error")
                                .font(.headline)
                            Text(errorMessage)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let todayReading = dataManager.getCurrentDayReading() {
                        todayReadingContent(todayReading)
                    } else {
                        VStack {
                            Image(systemName: "book.closed")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                            Text("No reading for today")
                                .font(.headline)
                            Text("Check the calendar for available readings")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Today's Reading")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func todayReadingContent(_ reading: BibleReading) -> some View {
        VStack(spacing: 24) {
            // Improved Progress section
            improvedProgressSection
            
            // Today's reading card
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Day \(reading.day)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text(reading.date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if dataManager.isReadingCompleted(reading.day) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.green)
                    }
                }
                
                Text(reading.text)
                    .font(.body)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                
                // Show summary if available
                if let summary = reading.summary, !summary.isEmpty {
                    Divider()
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "text.bubble")
                            .foregroundColor(.accentColor)
                        Text(summary)
                            .font(.callout)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.top, 4)
                }
                
                HStack {
                    Button("Mark as \(dataManager.isReadingCompleted(reading.day) ? "Unread" : "Read")") {
                        dataManager.toggleReadingCompletion(reading.day)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Spacer()
                    
                    Button("View Calendar") {
                        selectedTab = 1
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var improvedProgressSection: some View {
        let progress = dataManager.getCompletionProgress()
        let percentage = progress.total > 0 ? Double(progress.completed) / Double(progress.total) : 0.0
        let streak = dataManager.getCurrentStreak()
        let currentDay = dataManager.getCurrentDayNumber()
        let daysBehind = currentDay - progress.completed
        
        return VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Your Progress")
                    .font(.headline)
                Spacer()
            }
            .padding(.bottom, 4)
            
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                            .frame(width: 70, height: 70)
                        Circle()
                            .trim(from: 0, to: CGFloat(percentage))
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 70, height: 70)
                        Text("\(Int(percentage * 100))%")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(width: 90)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(.green)
                        Text("Days Read: ")
                            .font(.subheadline)
                        Text("\(progress.completed)/\(progress.total)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Current Streak: ")
                            .font(.subheadline)
                        Text("\(streak) days")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                }
                Spacer()
            }
            
            // Status indicator
            HStack {
                Image(systemName: daysBehind > 0 ? "clock.badge.exclamationmark" : "checkmark.circle.fill")
                    .foregroundColor(daysBehind > 0 ? .orange : .green)
                Text(daysBehind > 0 ? "Ești în urmă cu \(daysBehind) zile" : "Ești la zi!")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(daysBehind > 0 ? .orange : .green)
                Spacer()
            }
            .padding(.horizontal, 4)
            
            ProgressView(value: percentage)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 8)
                .cornerRadius(4)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

struct ProgressCard: View {
    let title: String
    let value: String
    let total: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if total != "days" {
                Text("of \(total)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }
} 