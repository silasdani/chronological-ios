import Foundation

struct BibleReading: Codable, Identifiable {
    var id: Int { day } // Use day as unique id
    let day: Int
    let date: String
    let text: String
    let summary: String?
    
    init(day: Int, date: String, text: String, summary: String? = nil) {
        self.day = day
        self.date = date
        self.text = text
        self.summary = summary
    }
} 