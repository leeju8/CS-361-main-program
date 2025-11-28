//
//  ContentView.swift
//  Pomodoro
//
//  Created by Justin Lee on 11/3/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showResetConfirmation: Bool = false
    @State private var skipResetConfirmation: Bool = false

    var body: some View {
        VStack {
            HStack {
                Button("pomodoro") {
                    selectedTab = 0
                }
                Button("stats") {
                    selectedTab = 1
                }
                Button("sign in") {
                    selectedTab = 2
                }
                Button("help") {
                    selectedTab = 3
                }
            }
            .frame(height: 30)
            .background(Color.gray, in: RoundedRectangle(cornerRadius: 8))
            
            if selectedTab == 0 {
                PomodoroView(
                    showResetConfirmation: $showResetConfirmation,
                    skipResetConfirmation: $skipResetConfirmation,
                )
            } else if selectedTab == 1 {
                StatsView()
            } else if selectedTab == 2{
                SignInView()
            } else {
                HelpView()
            }
        }
        .padding(.top, 30)
    }
}

#Preview {
    ContentView()
}
