
import SwiftUI

struct ContentView: View {
    @State private var isExpanded = true
    @State private var isRunning = false
    @State private var clickCount = 0
    @State private var clickLimit = 0
    @State private var interval = 100
    @State private var position = CGSize.zero
    @State private var timer: Timer?

    private let purple = Color(
        red: 0.58,
        green: 0.16,
        blue: 1.0
    )

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.035, green: 0.02, blue: 0.08)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(.yellow)

                    Text("AUTOCLICK VIP")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    Text("Floating Control Menu")
                        .foregroundStyle(.purple)

                    Spacer()

                    floatingMenu

                    Spacer()

                    Text("Menu nổi trong ứng dụng")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .overlay(alignment: .topLeading) {
                floatingMenu
                    .fixedSize()
                    .offset(position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                position = CGSize(
                                    width: value.translation.width,
                                    height: value.translation.height
                                )
                            }
                    )
                    .padding(.top, 15)
                    .padding(.leading, 10)
            }
        }
        .preferredColorScheme(.dark)
        .onDisappear {
            stopClicking()
        }
    }

    @ViewBuilder
    private var floatingMenu: some View {
        if isExpanded {
            VStack(spacing: 14) {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)

                    Text("AUTOCLICK VIP")
                        .font(.headline.bold())
                        .foregroundStyle(.white)

                    Spacer()

                    Button {
                        isExpanded = false
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(.white)
                    }
                }

                Divider().overlay(.purple)

                HStack {
                    Circle()
                        .fill(isRunning ? .green : .orange)
                        .frame(width: 9, height: 9)

                    Text(isRunning ? "ĐANG CHẠY" : "ĐANG DỪNG")
                        .font(.caption.bold())

                    Spacer()

                    Text("\(clickCount) Click")
                        .foregroundStyle(.purple)
                }

                Button {
                    isRunning ? stopClicking() : startClicking()
                } label: {
                    Label(
                        isRunning ? "TẠM DỪNG" : "BẮT ĐẦU",
                        systemImage: isRunning ? "pause.fill" : "play.fill"
                    )
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(purple)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("SỐ LẦN CLICK: \(clickLimit)")
                    Stepper(
                        "Giới hạn",
                        value: $clickLimit,
                        in: 0...10000
                    )

                    Divider()

                    Text("TỐC ĐỘ: \(interval) ms")
                    Stepper(
                        "Điều chỉnh tốc độ",
                        value: $interval,
                        in: 10...5000,
                        step: 10
                    )
                }
                .font(.caption)
                .foregroundStyle(.white)
            }
            .padding(16)
            .frame(width: 275)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.05, blue: 0.23),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(purple, lineWidth: 1.5)
            }
            .shadow(color: purple.opacity(0.5), radius: 15)
        } else {
            Button {
                isExpanded = true
            } label: {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 27))
                    .foregroundStyle(.white)
                    .frame(width: 62, height: 62)
                    .background(purple)
                    .clipShape(Circle())
                    .overlay {
                        Circle().stroke(.white.opacity(0.7), lineWidth: 1)
                    }
                    .shadow(color: purple.opacity(0.7), radius: 12)
            }
        }
    }

    private func startClicking() {
        guard !isRunning else { return }

        isRunning = true

        timer = Timer.scheduledTimer(
            withTimeInterval: Double(interval) / 1000,
            repeats: true
        ) { _ in
            clickCount += 1

            if clickLimit > 0 && clickCount >= clickLimit {
                stopClicking()
            }
        }
    }

    private func stopClicking() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
}
