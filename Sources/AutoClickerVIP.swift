
import SwiftUI
import UIKit

struct TargetApp: Identifiable {
    let id: String
    let name: String
    let icon: String
    let url: String

    static let apps = [
        TargetApp(id: "ff", name: "Free Fire",
                  icon: "gamecontroller.fill", url: "freefire://"),
        TargetApp(id: "tt", name: "TikTok",
                  icon: "music.note", url: "snssdk1233://"),
        TargetApp(id: "fb", name: "Facebook",
                  icon: "person.2.fill", url: "fb://"),
        TargetApp(id: "yt", name: "YouTube",
                  icon: "play.rectangle.fill", url: "youtube://"),
        TargetApp(id: "ig", name: "Instagram",
                  icon: "camera.fill", url: "instagram://"),
        TargetApp(id: "safari", name: "Safari",
                  icon: "safari.fill", url: "https://apple.com")
    ]
}

enum ClickMode: String, CaseIterable, Identifiable {
    case single = "Single Click"
    case multi = "Multi Click"
    case slide = "Slide Up"
    case auto = "Auto Tool"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .single: return "cursorarrow.click"
        case .multi: return "hand.tap"
        case .slide: return "arrow.up"
        case .auto: return "a.circle"
        }
    }
}

@main
struct AutoClickerVIPApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var selectedApp = TargetApp.apps[0]
    @State private var mode: ClickMode = .multi
    @State private var speed = 500.0
    @State private var limit = 100
    @State private var count = 0
    @State private var running = false
    @State private var showApps = false
    @State private var showSettings = false
    @State private var status = "Ready"

    private let purple = Color(
        red: 0.43, green: 0.25, blue: 0.98
    )

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 22) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Auto Clicker")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.white)

                        Text("VIP • iOS")
                            .foregroundStyle(.gray)
                    }

                    Spacer()

                    Image(systemName: "hand.tap.fill")
                        .font(.largeTitle)
                        .foregroundStyle(purple)
                }

                Button {
                    showApps = true
                } label: {
                    HStack {
                        Image(systemName: selectedApp.icon)
                            .foregroundStyle(purple)

                        Text(selectedApp.name)
                            .foregroundStyle(.white)

                        Spacer()

                        Text("CHỌN APP")
                            .foregroundStyle(purple)
                    }
                    .padding()
                    .background(
                        Color.white.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: 15)
                    )
                }

                Button(action: openSelectedApp) {
                    Label("MỞ ỨNG DỤNG",
                          systemImage: "arrow.up.forward.app")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            purple.opacity(0.3),
                            in: RoundedRectangle(cornerRadius: 15)
                        )
                }

                Button {
                    running.toggle()
                    status = running ? "Demo đang chạy" : "Đã dừng"
                } label: {
                    ZStack {
                        Circle()
                            .fill(purple.opacity(0.18))
                            .frame(width: 285, height: 285)

                        Circle()
                            .fill(purple)
                            .frame(width: 235, height: 235)

                        VStack(spacing: 10) {
                            Text(running ? "STOP" : "START")
                                .font(.system(size: 38, weight: .heavy))

                            Text(mode.rawValue)
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)

                Text(status)
                    .foregroundStyle(.gray)

                Text("Bộ đếm: \(count) / \(limit)")
                    .foregroundStyle(.white)
                    .font(.headline.monospacedDigit())

                Button {
                    showSettings = true
                } label: {
                    Label("CÀI ĐẶT",
                          systemImage: "gearshape.fill")
                        .foregroundStyle(.white)
                }

                Spacer()

                HStack {
                    ForEach(ClickMode.allCases) { item in
                        Button {
                            mode = item
                        } label: {
                            VStack(spacing: 7) {
                                Image(systemName: item.icon)
                                Text(item.rawValue)
                                    .font(.system(size: 10))
                            }
                            .foregroundStyle(
                                mode == item ? purple : .gray
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showApps) {
            NavigationStack {
                List(TargetApp.apps) { app in
                    Button {
                        selectedApp = app
                        showApps = false
                    } label: {
                        Label(app.name, systemImage: app.icon)
                    }
                }
                .navigationTitle("Chọn ứng dụng")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Đóng") {
                            showApps = false
                        }
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                Form {
                    Section("Tốc độ") {
                        Text("\(Int(speed)) ms")
                        Slider(value: $speed,
                               in: 100...5000,
                               step: 50)
                    }

                    Section("Giới hạn") {
                        Stepper("Số lần: \(limit)",
                                value: $limit,
                                in: 1...10000)
                    }

                    Button("Đặt lại bộ đếm") {
                        count = 0
                    }
                }
                .navigationTitle("Cài đặt")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Xong") {
                            showSettings = false
                        }
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private func openSelectedApp() {
        guard let url = URL(string: selectedApp.url) else {
            return
        }

        UIApplication.shared.open(url) { success in
            status = success
                ? "Đã mở ứng dụng"
                : "Không thể mở ứng dụng"
        }
    }
}
