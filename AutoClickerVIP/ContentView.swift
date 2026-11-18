
import SwiftUI
import UIKit

struct TapPoint: Identifiable, Codable {
    var id = UUID()
    var x: Double
    var y: Double
}

struct TargetApp: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let url: String
}

@MainActor
final class AutoClickModel: ObservableObject {
    @Published var points: [TapPoint] = []
    @Published var selectedPoint: UUID?
    @Published var isRunning = false
    @Published var clickCount = 0
    @Published var interval = 1.0
    @Published var selectedApp: TargetApp?
    @Published var showApps = false
    @Published var customURL = ""

    let apps: [TargetApp] = [
        .init(name: "Free Fire MAX", icon: "flame.fill",
              url: "https://ff.garena.com/"),
        .init(name: "TikTok", icon: "music.note",
              url: "https://www.tiktok.com/"),
        .init(name: "Facebook", icon: "person.2.fill",
              url: "https://www.facebook.com/"),
        .init(name: "YouTube", icon: "play.rectangle.fill",
              url: "https://www.youtube.com/"),
        .init(name: "Messenger", icon: "message.fill",
              url: "https://www.messenger.com/"),
        .init(name: "Instagram", icon: "camera.fill",
              url: "https://www.instagram.com/"),
        .init(name: "Zalo", icon: "bubble.left.fill",
              url: "https://zalo.me/"),
        .init(name: "Safari", icon: "safari.fill",
              url: "https://www.apple.com/"),
        .init(name: "Discord", icon: "gamecontroller.fill",
              url: "https://discord.com/app"),
        .init(name: "Telegram", icon: "paperplane.fill",
              url: "https://telegram.org/")
    ]

    func addPoint(x: CGFloat, y: CGFloat,
                  width: CGFloat, height: CGFloat) {
        guard width > 0, height > 0 else { return }

        let point = TapPoint(
            x: Double(min(max(x / width, 0), 1)),
            y: Double(min(max(y / height, 0), 1))
        )

        points.append(point)
        selectedPoint = point.id
    }

    func deleteSelected() {
        guard let id = selectedPoint else { return }
        points.removeAll { $0.id == id }
        selectedPoint = nil
    }

    func openSelectedApp() {
        guard let app = selectedApp,
              let url = URL(string: app.url) else { return }

        UIApplication.shared.open(url)
    }

    func openCustomApp() {
        let value = customURL.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !value.isEmpty else { return }

        let formatted = value.contains("://")
            ? value
            : "https://" + value

        guard let url = URL(string: formatted) else { return }

        UIApplication.shared.open(url)
    }

    func reset() {
        isRunning = false
        clickCount = 0
        points.removeAll()
        selectedPoint = nil
    }
}

struct ContentView: View {
    @StateObject private var model = AutoClickModel()
    @State private var menuOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.035, green: 0.04, blue: 0.10)
                    .ignoresSafeArea()

                gridBackground

                VStack(spacing: 12) {
                    header

                    Text("CHẠM VÀO MÀN HÌNH ĐỂ THÊM ĐIỂM")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.4))

                    ZStack {
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { value in
                                        model.addPoint(
                                            x: value.location.x,
                                            y: value.location.y,
                                            width: geometry.size.width,
                                            height: geometry.size.height
                                        )
                                    }
                            )

                        ForEach(model.points) { point in
                            pointView(point, size: geometry.size)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                    Text("AUTОCLICK VIP • iOS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.3))
                        .padding(.bottom, 12)
                }

                floatingPanel
                    .offset(menuOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                menuOffset = value.translation
                            }
                    )
                    .position(
                        x: geometry.size.width - 63,
                        y: geometry.size.height * 0.50
                    )
            }
        }
        .sheet(isPresented: $model.showApps) {
            appPicker
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .task(id: model.isRunning) {
            while model.isRunning {
                let delay = UInt64(
                    max(model.interval, 0.05) * 1_000_000_000
                )

                do {
                    try await Task.sleep(nanoseconds: delay)
                } catch {
                    break
                }

                if !Task.isCancelled && model.isRunning {
                    model.clickCount += 1
                }
            }
        }
    }

    private var gridBackground: some View {
        GeometryReader { geo in
            Path { path in
                stride(from: CGFloat.zero,
                       through: geo.size.width,
                       by: 55).forEach { x in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geo.size.height))
                }

                stride(from: CGFloat.zero,
                       through: geo.size.height,
                       by: 55).forEach { y in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
            }
            .stroke(.white.opacity(0.025), lineWidth: 1)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("AUTOCLICK")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(.white)

                Text("VIP CONTROL PANEL")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(.purple)
            }

            Spacer()

            Button {
                model.showApps = true
            } label: {
                Label(
                    model.selectedApp?.name ?? "CHỌN APP",
                    systemImage: "square.grid.2x2.fill"
                )
                .font(.system(size: 11, weight: .bold))
                .padding(12)
                .background(.purple.opacity(0.2))
                .clipShape(Capsule())
            }
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 18)
        .padding(.top, 15)
    }

    private func pointView(
        _ point: TapPoint,
        size: CGSize
    ) -> some View {
        let selected = model.selectedPoint == point.id

        return ZStack {
            Circle()
                .stroke(.purple.opacity(0.9), lineWidth: 2)
                .frame(width: 65, height: 65)

            Circle()
                .stroke(.purple.opacity(0.5), lineWidth: 1)
                .frame(width: 40, height: 40)

            Circle()
                .fill(.purple)
                .frame(width: 12, height: 12)

            Text("\(model.points.firstIndex(where: {
                $0.id == point.id
            }).map { $0 + 1 } ?? 1)")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 27, height: 27)
                .background(.purple)
                .clipShape(Circle())
                .offset(x: 29, y: -29)

            if selected {
                Circle()
                    .fill(.red)
                    .frame(width: 23, height: 23)
                    .overlay {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: -29, y: -29)
            }
        }
        .position(
            x: point.x * size.width,
            y: point.y * size.height
        )
        .contentShape(Circle().size(width: 75, height: 75))
        .onTapGesture {
            model.selectedPoint = point.id
        }
    }

    private var floatingPanel: some View {
        VStack(spacing: 13) {
            Capsule()
                .fill(.gray.opacity(0.4))
                .frame(width: 25, height: 4)

            Button {
                model.deleteSelected()
            } label: {
                Image(systemName: "trash.fill")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(.red.gradient)
                    .clipShape(Circle())
            }

            VStack(spacing: 5) {
                HStack {
                    stat("PTS", "\(model.points.count)")
                    stat("CLK", "\(model.clickCount)")
                }

                Text(model.isRunning ? "RUNNING" : "SELECTING")
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.5)
                    .foregroundStyle(.purple)
            }
            .padding(8)
            .background(.gray.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Button {
                model.isRunning.toggle()
            } label: {
                Image(systemName: model.isRunning
                      ? "pause.fill" : "play.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 76, height: 76)
                    .background(
                        model.isRunning
                        ? Color.orange.gradient
                        : Color.cyan.gradient
                    )
                    .clipShape(Circle())
                    .shadow(color: .cyan.opacity(0.3), radius: 12)
            }

            HStack(spacing: 7) {
                Button {
                    model.interval = max(0.05, model.interval - 0.1)
                } label: {
                    Image(systemName: "chevron.left")
                }

                Text(model.interval < 1
                     ? String(format: "%.1fs", model.interval)
                     : String(format: "%.0fs", model.interval))
                    .font(.system(size: 13, weight: .bold))
                    .monospacedDigit()

                Button {
                    model.interval = min(10, model.interval + 0.1)
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(.white)
            .padding(9)
            .background(.gray.opacity(0.15))
            .clipShape(Capsule())

            Button {
                model.addPoint(
                    x: UIScreen.main.bounds.width / 2,
                    y: UIScreen.main.bounds.height / 2,
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height
                )
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(.purple.gradient)
                    .clipShape(Circle())
            }
        }
        .padding(10)
        .frame(width: 110)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.8))
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(.purple.opacity(0.3), lineWidth: 1)
        }
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.primary)
                .monospacedDigit()
        }
    }

    private var appPicker: some View {
        NavigationStack {
            List {
                Section("ỨNG DỤNG PHỔ BIẾN") {
                    ForEach(model.apps) { app in
                        Button {
                            model.selectedApp = app
                            model.showApps = false
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: app.icon)
                                    .font(.title2)
                                    .foregroundStyle(.purple)
                                    .frame(width: 35)

                                Text(app.name)
                                    .foregroundStyle(.primary)

                                Spacer()

                                if model.selectedApp?.name == app.name {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.purple)
                                }
                            }
                        }
                    }
                }

                Section("ỨNG DỤNG TÙY CHỈNH") {
                    TextField(
                        "URL hoặc liên kết ứng dụng",
                        text: $model.customURL
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    Button("Mở liên kết tùy chỉnh") {
                        model.openCustomApp()
                        model.showApps = false
                    }
                }
            }
            .navigationTitle("Chọn ứng dụng")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") {
                        model.showApps = false
                    }
                }
            }
        }
    }
}
