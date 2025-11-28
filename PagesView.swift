//
//  PagesView.swift
//  Pomodoro
//
//  Created by Justin Lee on 11/3/25.
//

import SwiftUI

struct PomodoroView: View {
    @Binding var showResetConfirmation: Bool
    @Binding var skipResetConfirmation: Bool

    @State private var timeRemaining: Int = 1500 // 25 min
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil
    @State private var quote: String = ""
    @State private var date: String = ""
    @State private var takeBreak: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // MARK: Date Display
                Text(date).fontWeight(.semibold)
                
                // MARK: Inspirational Quote Display
                Text(quote)
                
                // MARK: Timer Display
                TextField("", text: Binding(
                    get: { formatTime(timeRemaining) },
                    set: { newValue in
                        timeRemaining = parseTime(from: newValue)
                    }
                ))
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .frame(width: 200)
                .textFieldStyle(.plain)
                .disabled(isRunning)
                .onSubmit {
                    startTimer()
                }
                
                // MARK: Buttons
                if isRunning {
                    HStack(spacing: 40) {
                        Button(action: handleReset) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 28, weight: .bold))
                                .frame(width: 60, height: 60)
                                .background(Color.gray, in: RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: pauseTimer) {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 28, weight: .bold))
                                .frame(width: 60, height: 60)
                                .background(Color.gray, in: RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Button(action: startTimer) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 28, weight: .bold))
                            .frame(width: 60, height: 60)
                            .background(Color.gray, in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
                
                // MARK: Break Recommendation Display
                
            }
            .padding(40)
            .frame(width: 500, height: 475)
            .background(Color.gray.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
            .padding(.bottom, 30)
            .task {
                await getQuote()
                await getDate()
            }
            
            // MARK: Confirmation Popup
            if showResetConfirmation {
                ResetConfirmationPopup(
                    confirm: {
                        resetTimer()
                        showResetConfirmation = false
                    },
                    cancel: {
                        showResetConfirmation = false
                    },
                    skipFuture: $skipResetConfirmation
                )
                .transition(.opacity)
            }
        }
    }
}

extension PomodoroView {
    // MARK: Timer Logic
    func startTimer() {
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                isRunning = false
            }
        }
    }
    
    func pauseTimer() {
        timer?.invalidate()
        isRunning = false
    }
    
    func handleReset() {
        if skipResetConfirmation {
            resetTimer()
        } else {
            showResetConfirmation = true
        }
    }
    
    func resetTimer() {
        timer?.invalidate()
        isRunning = false
        timeRemaining = 1500
    }
    
    // MARK: Time Formatting
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
    func parseTime(from input: String) -> Int {
        let parts = input.split(separator: ":").map { String($0) }
        guard parts.count == 2,
              let m = Int(parts[0]),
              let s = Int(parts[1]),
              m >= 0, s >= 0 else { return 0 }
        return m * 60 + s
    }
    
    // MARK: Inspirational Quote Logic
    struct QuoteResponse: Decodable {
        let id: Int
        let quote: String
    }
    
    func getQuote() async {
        guard let url = URL(string: "http://127.0.0.1:5000/api/quote") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(QuoteResponse.self, from: data)
            quote = decoded.quote
        } catch {
            print("Failed to get quote:", error)
        }
    }
    
    // MARK: Date Retreival Logic
    struct DateResponse: Decodable {
        let date: String
    }
    
    func getDate() async {
        guard let url = URL(string: "http://localhost:8081/date") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(DateResponse.self, from: data)
            date = decoded.date
        } catch {
            print("Failed to get date:", error)
        }
    }
    
    // MARK: Break Recommendation Logic
}

struct ResetConfirmationPopup: View {
    var confirm: () -> Void
    var cancel: () -> Void
    @Binding var skipFuture: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 40))
                .padding(.bottom, 4)
            
            Text("reset the timer?")
                .font(.title3)
                .bold()
            
            HStack(spacing: 10) {
                Button("yes") { confirm() }
                    .buttonStyle(ColoredButtonStyle(color: .blue))
                Button("no") { cancel() }
                    .buttonStyle(ColoredButtonStyle(color: .black))
            }
            
            Toggle("don’t show again", isOn: $skipFuture)
                .toggleStyle(.checkbox)
                .font(.caption)
                .padding(.top, 4)
        }
        .padding()
        .frame(width: 250)
        .background(Color.gray)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}

struct ColoredButtonStyle: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(6)
    }
}

struct StatsView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .ignoresSafeArea()
            VStack(spacing: 12) {
                    Text("pomodoro stats")
                        .font(.title)
                        .bold()
            }
            .padding(40)
            .frame(width: 500, height: 475)
            .background(Color.gray.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
            .padding(.bottom, 30)
        }
    }
}

struct SignInView: View {
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
            ZStack(alignment: .bottom) {
                Color.clear
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    // Username field
                    TextField("username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 40)
                        .padding(.horizontal, 20)

                    // Password field
                    SecureField("password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 40)
                        .padding(.horizontal, 20)

                    // Login button
                    Button {
                        print("Logging in with \(username)")
                    } label: {
                        Text("log in")
                            .fontWeight(.semibold)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                    }
                    .background(Color.blue)
                    .cornerRadius(6)

                    // Create account link
                    Button("create account") {
                        print("Create account tapped")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                    .padding(.top, 4)
                }
                .padding(40)
                .frame(width: 500, height: 475)
                .background(Color.gray.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                .padding(.bottom, 30)
            }
        }
}

struct HelpView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("what is pomodoro?")
                    .font(.title)
                    .bold()
                Text("Pomodoro is a technique that helps you stay focused and productive by using timed work sessions. Use the timer to work for 25 minutes, then take a 5-minute break. After four sessions, take a longer break to recharge. It’s a simple way to stay consistent, avoid burnout, and make progress one step at a time.")
                
                Text("The Pomodoro Technique also emphasizes tracking each completed session, known as a “pomodoro,” to build awareness of how you spend your time. This helps you estimate workload more accurately and identify when you tend to lose focus. Between sessions, short breaks are used to reset mentally without losing momentum, while longer breaks after multiple cycles prevent cognitive fatigue. Many people adapt the method by adjusting session length, break duration, or the number of cycles to match their personal rhythm. The core principle remains the same: work in short, deliberate intervals with structured recovery to maintain consistent, high-quality focus.")
            }
            .padding(40)
            .frame(width: 500, height: 475)
            .background(Color.gray.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
            .padding(.bottom, 30)
        }
    }
}

