# Align 🗓️

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**Align** is a visual daily planner designed to help you organize your day through **Time Blocking**. Built entirely with **SwiftUI** and **SwiftData**, it features a modern, clean interface inspired by top-tier productivity apps.

## ✨ Key Features

* **Visual Timeline:** A vertical rail connects your daily tasks, providing a clear flow of your day without the clutter of a full grid.
* **Time Blocking:** Assign specific durations to tasks to visualize your capacity.
* **Smart Calendar:** Horizontal week view with native-feel swipe navigation (Page TabView) to switch days effortlessly.
* **Task Management:**
    * Complete tasks with satisfying haptic feedback.
    * Custom icons and gradient color themes.
    * Edit and reschedule tasks easily.
* **Notifications:** Local notifications remind you 5 minutes before a task starts.
* **Persistent Storage:** All data is saved locally using Apple's latest **SwiftData** framework.

## 🛠 Tech Stack

* **Language:** Swift 5
* **UI Framework:** SwiftUI
* **Database:** SwiftData (iOS 17+)
* **Architecture:** MVVM (Model-View-ViewModel)
* **Concurrency:** Swift Concurrency (Async/Await)

## 📂 Project Structure

Align follows a clean **MVVM** architecture for scalability and maintainability:

```text
AlignApp
├── Model
│   └── AlignTask.swift       # SwiftData Schema
├── ViewModel
│   └── HomeViewModel.swift   # Calendar logic & State management
├── View
│   ├── ContentView.swift     # Main container & Calendar Header
│   ├── DailyTaskList.swift   # Vertical ScrollView with Timeline Logic
│   ├── TaskFormView.swift    # Add/Edit Task Sheet
│   └── Components
│       └── GridTaskCard.swift # Custom UI Component for Tasks
├── Helpers
│   ├── Date+Extensions.swift
│   └── NotificationManager.swift
└── AlignApp.swift
```

## 🚀 Getting Started

### Prerequisites
* **Xcode 15.0** or later.
* **iOS 17.0** or later (Required for SwiftData).
* A Mac running macOS Sonoma or later.

### Installation

1.  **Clone the repository**
    Open your terminal and run:
    ```bash
    git clone https://github.com/citylighxts/Align.git
    ```

2.  **Open in Xcode**
    Navigate to the project folder and open `Align.xcodeproj`.

3.  **Build and Run**
    * Select an iOS Simulator (e.g., iPhone 15 Pro).
    * Press `Cmd + R` or click the Play button in Xcode.

> **Note:** Since this app uses local notifications, you will be prompted to allow notifications upon the first launch.

## 📸 Usage

* **Add a Task:** Tap the floating **`+`** button at the bottom right. Enter the task title, set the start/end time, and pick a color/icon theme.
* **Navigation:**
    * **Swipe horizontally** on the task list area to switch between days (like a native calendar app).
    * Tap a specific date on the **top calendar strip** to jump to that day.
    * Tap **"Today"** in the header to return to the current date.
* **Complete a Task:** Tap the **circle checkbox** on the right side of a task card. The task will turn green, and the title will be struck through.
* **Edit a Task:** Tap anywhere on the text area of a task card to open the edit sheet.
* **Delete a Task:** Long-press on a task card and select **Delete** from the context menu.

---

Built with ❤️ using **SwiftUI** & **SwiftData**.
