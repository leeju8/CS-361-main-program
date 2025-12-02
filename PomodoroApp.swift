//
//  PomodoroApp.swift
//  Pomodoro
//
//  Created by Justin Lee on 11/3/25.
//

import SwiftUI
import Combine

class ProductivityModel: ObservableObject {
    @Published var totalSessions: Int = 0
}

@main
struct PomodoroApp: App {
    @StateObject var model = ProductivityModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 600, height: 575)
                .environmentObject(model)
        }
        .windowResizability(.contentSize)
    }
}
