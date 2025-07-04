import SwiftUI

struct SummariesView: View {
  @ObservedObject var dataManager: BibleDataManager

  var body: some View {
    ScrollView {
      VStack(spacing: 12) {
        ForEach(dataManager.readings.filter { ($0.summary ?? "").isEmpty == false }) { reading in
          HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
              Text(reading.date)
                .font(.caption)
                .foregroundColor(.secondary)
              Text(reading.text)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .accessibilityLabel("Reference: \(reading.text)")
              if let summary = reading.summary, !summary.isEmpty {
                Text(summary)
                  .font(.callout)
                  .foregroundColor(.primary)
                  .multilineTextAlignment(.leading)
              }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            Spacer(minLength: 0)
          }
          .background(Color(uiColor: .systemGray6))
          .cornerRadius(12)
          .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
          .accessibilityElement(children: .combine)
        }
      }
      .padding()
    }
    .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    .navigationTitle("Summaries")
    .navigationBarTitleDisplayMode(.large)
  }
}

// Preview for Xcode canvas
struct SummariesView_Previews: PreviewProvider {
  static var previews: some View {
    let manager = BibleDataManager()
    SummariesView(dataManager: manager)
      .preferredColorScheme(.light)
    SummariesView(dataManager: manager)
      .preferredColorScheme(.dark)
  }
}
