//
//  PomodoroApp.swift
//  Pomodoro
//
//  Created by Justin Lee on 11/3/25.
//

import SwiftUI

@main
struct PomodoroApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 600, height: 400)
        }
        .windowResizability(.contentSize)
    }
}
