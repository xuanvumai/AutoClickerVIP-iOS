
import SwiftUI

struct ContentView: View {
    @State private var isRunning = false
    @State private var clickCount = 0
    @State private var clickLimit = 0
    @State private var interval = 100
    @State private var fastMode = true
    @State private var repeatMode = false
    @State private var clickTask: Task<Void, Never>?

    private let purple = Color(red: 0.55, green: 0.15, blue: 1.0)

    var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.025, blue: 0.09)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    statusCard
                    settingsCard
                    advancedCard

                    Text("AutoClickerVIP • Version 1.0.0")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .padding(.bottom, 20)
                }
                .padding()
            }
        }
        .preferredColorScheme(.dark)
        .onDisappear {
            stopClicking()
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 38))
                .foregroundStyle(purple)

            VStack(alignment: .leading) {
                Text("AutoClick Pro")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(.white)

                Text("Click tự động - VIP")
                    .foregroundStyle(.purple)
            }

            Spacer()
        }
        .padding(.vertical, 15)
    }

    private var statusCard: some View {
        VStack(spacing: 18) {
            HStack {
                Circle()
                    .fill(isRunning ? .green : .orange)
                    .frame(width: 10, height: 10)

                Text(isRunning ? "Đang chạy" : "Đã tạm dừng")
                    .font(.headline)

                Spacer()

                Text("\(clickCount) Click")
                    .foregroundStyle(.purple)
                    .bold()
            }

            Button {
                isRunning ? stopClicking() : startClicking()
            } label: {
                HStack {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    Text(isRunning ? "Tạm dừng" : "Bắt đầu")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [purple, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding()
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(purple.opacity(0.7), lineWidth: 1)
        }
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("Cài đặt Click", systemImage: "scope")
                .font(.title3.bold())
                .foregroundStyle(.purple)

            VStack(alignment: .leading) {
                Text("Số lần Click (0 = vô hạn)")
                Stepper("\(clickLimit)", value: $clickLimit, in: 0...100000)
            }

            Divider()

            VStack(alignment: .leading) {
                Text("Thời gian giữa hai lần Click")
                Stepper("\(interval) ms", value: $interval, in: 10...5000, step: 10)
            }
        }
        .padding()
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var advancedCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("Tính năng nâng cao", systemImage: "bolt.fill")
                .font(.title3.bold())
                .foregroundStyle(.purple)

            Toggle("Click nhanh", isOn: $fastMode)
                .tint(purple)

            Toggle("Lặp lại tự động", isOn: $repeatMode)
                .tint(purple)

            Divider()

            Button("Đặt lại thống kê") {
                clickCount = 0
            }
            .foregroundStyle(.purple)
        }
        .padding()
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func startClicking() {
        guard !isRunning else { return }

        isRunning = true

        clickTask = Task {
            while !Task.isCancelled {
                let delay = fastMode ? min(interval, 50) : interval

                try? await Task.sleep(
                    nanoseconds: UInt64(delay) * 1_000_000
                )

                if Task.isCancelled { break }

                clickCount += 1

                if clickLimit > 0 && clickCount >= clickLimit {
                    if repeatMode {
                        clickCount = 0
                    } else {
                        break
                    }
                }
            }

            isRunning = false
            clickTask = nil
        }
    }

    private func stopClicking() {
        clickTask?.cancel()
        clickTask = nil
        isRunning = false
    }
}
