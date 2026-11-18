
import SwiftUI

struct ContentView: View {
    @State private var isRunning = false
    @State private var clickCount = 0
    @State private var clickLimit = 0
    @State private var interval = 100
    @State private var fastMode = false
    @State private var repeatMode = false
    @State private var timer: Timer?

    private let purple = Color(
        red: 0.65,
        green: 0.15,
        blue: 1.0
    )

    var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.02, blue: 0.08)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    header
                    statusPanel
                    settingsPanel
                    advancedPanel
                    statisticsPanel

                    Text("AUTOCLICK VIP • VERSION 1.0")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .padding(.top, 12)
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
        HStack {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 40))
                .foregroundStyle(purple)

            VStack(alignment: .leading) {
                Text("AutoClick VIP")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(.white)

                Text("Click tự động - Phiên bản VIP")
                    .font(.caption)
                    .foregroundStyle(.purple)
            }

            Spacer()

            Image(systemName: "crown.fill")
                .font(.system(size: 27))
                .foregroundStyle(.yellow)
        }
        .padding(.vertical)
    }

    private var statusPanel: some View {
        VStack(spacing: 18) {
            HStack {
                Circle()
                    .fill(isRunning ? .green : .orange)
                    .frame(width: 12, height: 12)

                Text(isRunning ? "Đang chạy" : "Đã tạm dừng")
                    .font(.headline)

                Spacer()

                Text("\(clickCount) Click")
                    .foregroundStyle(.purple)
            }

            Button {
                if isRunning {
                    stopClicking()
                } else {
                    startClicking()
                }
            } label: {
                Label(
                    isRunning ? "Tạm dừng" : "Bắt đầu",
                    systemImage: isRunning ? "pause.fill" : "play.fill"
                )
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(purple)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
        .padding()
        .background(.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(purple.opacity(0.7), lineWidth: 1)
        }
    }

    private var settingsPanel: some View {
        VStack(alignment: .leading, spacing: 20) {
            Label("Cài đặt Click", systemImage: "scope")
                .font(.title3.bold())
                .foregroundStyle(.purple)

            VStack(alignment: .leading) {
                Text("Số lần Click")
                Text("0 = Không giới hạn")
                    .font(.caption)
                    .foregroundStyle(.gray)

                Stepper(
                    "\(clickLimit)",
                    value: $clickLimit,
                    in: 0...100000
                )
            }

            Divider()

            VStack(alignment: .leading) {
                Text("Khoảng cách giữa các lần Click")
                Stepper(
                    "\(interval) ms",
                    value: $interval,
                    in: 10...5000,
                    step: 10
                )
            }
        }
        .padding()
        .background(.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var advancedPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("Tính năng nâng cao", systemImage: "bolt.fill")
                .font(.title3.bold())
                .foregroundStyle(.purple)

            Toggle("Click nhanh", isOn: $fastMode)
                .tint(purple)

            Toggle("Lặp lại tự động", isOn: $repeatMode)
                .tint(purple)

            Button("Đặt lại thống kê") {
                stopClicking()
                clickCount = 0
            }
            .foregroundStyle(.purple)
        }
        .padding()
        .background(.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var statisticsPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Thống kê", systemImage: "chart.bar.fill")
                .font(.title3.bold())
                .foregroundStyle(.purple)

            HStack {
                Spacer()

                VStack {
                    Text("\(clickCount)")
                        .font(.title.bold())
                        .foregroundStyle(.purple)

                    Text("Tổng Click")
                        .font(.caption)
                }

                Spacer()

                VStack {
                    Image(systemName: "timer")
                        .font(.title)
                        .foregroundStyle(.purple)

                    Text("\(interval) ms")
                        .font(.caption)
                }

                Spacer()
            }
            .padding(.vertical)
        }
        .padding()
        .background(.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func startClicking() {
        guard !isRunning else { return }

        isRunning = true

        let delay = fastMode ? min(interval, 50) : interval

        timer = Timer.scheduledTimer(
            withTimeInterval: Double(delay) / 1000.0,
            repeats: true
        ) { _ in
            clickCount += 1

            if clickLimit > 0 && clickCount >= clickLimit {
                if repeatMode {
                    clickCount = 0
                } else {
                    stopClicking()
                }
            }
        }
    }

    private func stopClicking() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
}
