# TimeScripture Reading Reminder

A beautiful iOS app that helps you follow a chronological Bible reading plan throughout the year. The app displays daily Bible readings in the order they occurred historically and provides daily reminders to keep you on track.

## Features

### 📅 Calendar View

- **Monthly Calendar Display**: View all readings for each month in a clean, calendar-like interface
- **Daily Reading Details**: Tap on any day to see the specific passages to read
- **Today's Highlight**: Current day is highlighted in orange for easy identification
- **Navigation**: Swipe between months to explore the entire year's reading plan
- **Improved Tile Display**: Reading text is more readable, with up to 4 lines and better scaling
- **Year Display**: Year is always shown as 2025 (no comma or locale formatting)

### 📖 Today's Reading

- **Current Day Focus**: Dedicated view showing today's reading with beautiful typography
- **Reading Progress**: Track your daily reading completion
- **Progress Section**: See percentage complete, days read, current streak, and a status indicator (e.g., "Ești la zi!" or "Ești în urmă cu X zile")
- **Quick Actions**: Mark readings as completed with a single tap
- **Jump to Calendar**: Instantly switch to the calendar tab

### 🔔 Smart Notifications

- **Customizable Reminders**: Set your preferred time for daily Bible reading reminders
- **Push Notifications**: Receive reminders that include today's reading passage
- **Badge Reset**: Notification badge is cleared automatically when you open the app or tap a notification
- **Permission Management**: Easy toggle to enable/disable notifications
- **Time Settings**: Choose the perfect time that fits your schedule

### ⚡️ Productivity Tools

- **Mark All to Date**: In Settings, instantly mark all readings up to today as completed
- **Catch Up**: See at a glance if you're behind and by how many days

### 🎨 Modern Design

- **SwiftUI Interface**: Built with the latest iOS design principles
- **Dark Mode Support**: Automatically adapts to your system appearance
- **Accessibility**: Full VoiceOver support and accessibility features
- **Responsive Layout**: Optimized for all iPhone and iPad sizes

## Technical Features

- **SwiftUI**: Modern declarative UI framework
- **UserNotifications**: Local push notification support
- **JSON Data**: Structured reading plan data
- **MVVM Architecture**: Clean separation of concerns
- **ObservableObject**: Reactive data binding
- **AppDelegate**: Handles notification badge reset and notification actions

## Getting Started

1. **Open the Project**: Open `TimeScripture.xcodeproj` in Xcode
2. **Select Target**: Choose your preferred iOS Simulator or device
3. **Build & Run**: Press Cmd+R to build and run the app
4. **Grant Permissions**: Allow notifications when prompted for the best experience

## Data Structure

The app uses a JSON file (`ChronologicalBible.json`) containing the reading plan:

```json
{
  "days": [
    {
      "day": 1,
      "date": "January 1",
      "text": "Geneza 1-7"
    },
    {
      "day": 2,
      "date": "January 2",
      "text": "Geneza 8-11"
    }
  ]
}
```

## Architecture

- **Models**: Data structures for Bible readings and app state
- **Views**: SwiftUI views for different app screens
- **ViewModels**: Observable objects managing app logic
- **Managers**: Services for data loading and notifications

## Tips

- Use the **Mark All to Date** button in Settings if you want to catch up quickly.
- Check the progress section for your current streak and whether you are on track ("Ești la zi!") or behind ("Ești în urmă cu X zile").
- Tap the calendar icon to explore any day's reading and mark it as complete.
- Notification badge will always reset when you open the app or tap a notification.

## Changelog

### 2025-07-04

- Added progress status: "Ești la zi!" or "Ești în urmă cu X zile"
- Added Mark All to Date button in Settings
- Improved calendar tile readability and year formatting
- Push notifications now include today's reading
- Notification badge resets automatically
- UI/UX improvements throughout

## Requirements

- iOS 18.5+
- Xcode 16.0+
- Swift 6.0+

## License

© 2025 Chronological Bible Reader

---

_Built with ❤️ for daily Bible reading_
