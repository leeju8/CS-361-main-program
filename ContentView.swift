//
//  ContentView.swift
//  Pomodoro
//
//  Created by Justin Lee on 11/3/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            HStack {
                Button("pomodoro") {
                    selectedTab = 0
                }
                .frame(maxHeight: .infinity)
                
                Button("sign in") {
                    selectedTab = 1
                }
                Button("help") {
                    selectedTab = 2
                }
            }
            .frame(height: 30)
            .background(Color.gray, in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(.top, 30)
        
        
        if selectedTab == 0 {
            PomodoroView()
        } else if selectedTab == 1 {
            SignInView()
        } else {
            HelpView()
        }
    }
}

#Preview {
    ContentView()
}
