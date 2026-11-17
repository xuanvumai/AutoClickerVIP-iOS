
import SwiftUI
import UIKit

struct TargetApp: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let scheme: String

    static let all: [TargetApp] = [
        .init(id: "ff", name: "Free Fire",
              icon: "gamecontroller.fill", scheme: "freefire://"),
        .init(id: "tiktok", name: "TikTok",
              icon: "music.note", scheme: "snssdk1233://"),
        .init(id: "facebook", name: "Facebook",
              icon: "person.2.fill", scheme: "fb://"),
        .init(id: "youtube", name: "YouTube",
              icon: "play.rectangle.fill", scheme: "youtube://"),
        .init(id: "instagram", name: "Instagram",
              icon: "camera.fill", scheme: "instagram://")
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

struct ContentView: View {
    @State private var selectedApp = TargetApp.all[0]
    @State private var mode: ClickMode = .multi
    @State private var interval = 500.0
    @State private var limit = 100
    @State private var count = 0
    @State private var running = false
    @State private var showApps = false
    @State private var showSettings = false

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

                    Button {
                        showApps = true
                    } label: {
                        Image(systemName: "square.grid.2x2")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
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

                Button {
                    openSelectedApp()
                } label: {
                    Label("MỞ ỨNG DỤNG ĐÃ CHỌN",
                          systemImage: "arrow.up.forward.app")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(purple.opacity(0.3),
                                    in: RoundedRectangle(cornerRadius: 15))
                }

                Button {
                    running.toggle()
                    if !running {
                        count = 0
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(purple.opacity(0.18))
                            .frame(width: 290, height: 290)

                        Circle()
                            .fill(purple)
                            .frame(width: 245, height: 245)

                        VStack(spacing: 10) {
                            Text(running ? "STOP" : "START")
                                .font(.system(size: 38,
                                              weight: .heavy))

                            Text("Enable \(mode.rawValue)")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)

                Text("Click counter: \(count) / \(limit)")
                    .font(.headline)
                    .foregroundStyle(.white)

                Button {
                    showSettings = true
                } label: {
                    Label("CÀI ĐẶT TỐC ĐỘ",
                          systemImage: "gearshape")
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
                List(TargetApp.all) { app in
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
                    Section("Tốc độ click") {
                        Text("\(Int(interval)) ms")
                        Slider(value: $interval,
                               in: 100...5000,
                               step: 50)
                    }

                    Section("Số lần click") {
                        Stepper("Giới hạn: \(limit)",
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
        guard let url = URL(string: selectedApp.scheme) else {
            return
        }

        UIApplication.shared.open(url)
    }
}
