
import SwiftUI
import UIKit

// MARK: - DATA

struct TapPoint: Identifiable, Codable {
    var id: UUID = UUID()
    var x: Double
    var y: Double
}

struct TargetApp: Identifiable {
    let id: String
    let name: String
    let icon: String
    let url: String
}

// MARK: - MODEL

@MainActor
final class AutoClickModel: ObservableObject {

    @Published var points: [TapPoint] = []
    @Published var selectedPoint: UUID?
    @Published var selectedApp: TargetApp?

    @Published var isRunning = false
    @Published var clickCount = 0
    @Published var interval: Double = 1.0

    @Published var customURL = ""
    @Published var showApps = false

    let apps: [TargetApp] = [
        TargetApp(
            id: "freefire",
            name: "Free Fire MAX",
            icon: "flame.fill",
            url: "https://ff.garena.com/"
        ),
        TargetApp(
            id: "tiktok",
            name: "TikTok",
            icon: "music.note",
            url: "https://www.tiktok.com/"
        ),
        TargetApp(
            id: "facebook",
            name: "Facebook",
            icon: "person.2.fill",
            url: "https://www.facebook.com/"
        ),
        TargetApp(
            id: "youtube",
            name: "YouTube",
            icon: "play.rectangle.fill",
            url: "https://www.youtube.com/"
        ),
        TargetApp(
            id: "messenger",
            name: "Messenger",
            icon: "message.fill",
            url: "https://www.messenger.com/"
        ),
        TargetApp(
            id: "instagram",
            name: "Instagram",
            icon: "camera.fill",
            url: "https://www.instagram.com/"
        ),
        TargetApp(
            id: "zalo",
            name: "Zalo",
            icon: "bubble.left.fill",
            url: "https://zalo.me/"
        ),
        TargetApp(
            id: "safari",
            name: "Safari",
            icon: "safari.fill",
            url: "https://www.apple.com/"
        ),
        TargetApp(
            id: "discord",
            name: "Discord",
            icon: "gamecontroller.fill",
            url: "https://discord.com/app"
        ),
        TargetApp(
            id: "telegram",
            name: "Telegram",
            icon: "paperplane.fill",
            url: "https://telegram.org/"
        )
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

    func addCenterPoint() {
        let point = TapPoint(x: 0.5, y: 0.5)
        points.append(point)
        selectedPoint = point.id
    }

    func deleteSelected() {
        guard let id = selectedPoint else { return }

        points.removeAll { $0.id == id }
        selectedPoint = nil
    }

    func deleteAll() {
        points.removeAll()
        selectedPoint = nil
        stop()
    }

    func start() {
        guard !points.isEmpty else { return }
        isRunning = true
    }

    func stop() {
        isRunning = false
    }

    func openSelectedApp() {
        guard let app = selectedApp,
              let url = URL(string: app.url) else {
            return
        }

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

        guard let url = URL(string: formatted) else {
            return
        }

        UIApplication.shared.open(url)
    }

    func savePoints() {
        guard let data = try? JSONEncoder().encode(points) else {
            return
        }

        UserDefaults.standard.set(data, forKey: "savedPoints")
    }

    func loadPoints() {
        guard let data = UserDefaults.standard.data(
            forKey: "savedPoints"
        ),
        let saved = try? JSONDecoder().decode(
            [TapPoint].self,
            from: data
        ) else {
            return
        }

        points = saved
    }
}

// MARK: - MAIN VIEW

struct ContentView: View {

    @StateObject private var model = AutoClickModel()

    @State private var menuOffset: CGSize = .zero
    @State private var dragStart: CGSize = .zero

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                Color(
                    red: 0.035,
                    green: 0.04,
                    blue: 0.10
                )
                .ignoresSafeArea()

                gridBackground

                VStack(spacing: 12) {

                    header

                    Text("CHẠM VÀO MÀN HÌNH ĐỂ THÊM ĐIỂM")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.45))

                    canvas(size: geometry.size)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Text("AUTOCLICK VIP • iOS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.3))
                        .padding(.bottom, 10)
                }

                floatingPanel
                    .offset(menuOffset)
                    .position(
                        x: geometry.size.width - 65,
                        y: geometry.size.height * 0.55
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                menuOffset = CGSize(
                                    width: dragStart.width + value.translation.width,
                                    height: dragStart.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                dragStart = menuOffset
                            }
                    )
            }
        }
        .sheet(isPresented: $model.showApps) {
            appPicker
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            model.loadPoints()
        }
        .onChange(of: model.points) { _ in
            model.savePoints()
        }
        .task(id: model.isRunning) {
            guard model.isRunning else { return }

            while !Task.isCancelled && model.isRunning {

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

    // MARK: - GRID

    private var gridBackground: some View {

        GeometryReader { geo in

            Path { path in

                stride(
                    from: CGFloat.zero,
                    through: geo.size.width,
                    by: 55
                ).forEach { x in

                    path.move(to: CGPoint(x: x, y: 0))

                    path.addLine(
                        to: CGPoint(x: x, y: geo.size.height)
                    )
                }

                stride(
                    from: CGFloat.zero,
                    through: geo.size.height,
                    by: 55
                ).forEach { y in

                    path.move(to: CGPoint(x: 0, y: y))

                    path.addLine(
                        to: CGPoint(x: geo.size.width, y: y)
                    )
                }
            }
            .stroke(.white.opacity(0.025), lineWidth: 1)
        }
        .ignoresSafeArea()
    }

    // MARK: - HEADER

    private var header: some View {

        HStack {

            VStack(alignment: .leading, spacing: 4) {

                Text("AUTOCLICK")
                    .font(.system(size: 23, weight: .black))
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
                    "CHỌN APP",
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

    // MARK: - CANVAS

    private func canvas(size: CGSize) -> some View {

        GeometryReader { geo in

            ZStack {

                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in

                                model.addPoint(
                                    x: value.location.x,
                                    y: value.location.y,
                                    width: geo.size.width,
                                    height: geo.size.height
                                )
                            }
                    )

                ForEach(Array(model.points.enumerated()), id: \.element.id) {
                    index, point in

                    pointView(
                        point: point,
                        number: index + 1,
                        size: geo.size
                    )
                }
            }
        }
    }

    // MARK: - POINT VIEW

    private func pointView(
        point: TapPoint,
        number: Int,
        size: CGSize
    ) -> some View {

        let selected = model.selectedPoint == point.id

        return ZStack {

            Circle()
                .stroke(
                    Color.purple.opacity(0.9),
                    lineWidth: 2
                )
                .frame(width: 65, height: 65)

            Circle()
                .stroke(
                    Color.purple.opacity(0.5),
                    lineWidth: 1
                )
                .frame(width: 40, height: 40)

            Circle()
                .fill(Color.purple)
                .frame(width: 12, height: 12)

            Text("\(number)")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 27, height: 27)
                .background(Color.purple)
                .clipShape(Circle())
                .offset(x: 29, y: -29)

            if selected {

                Circle()
                    .fill(Color.red)
                    .frame(width: 23, height: 23)
                    .overlay {

                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: -29, y: -29)
            }
        }
        .frame(width: 75, height: 75)
        .contentShape(Circle())
        .position(
            x: point.x * size.width,
            y: point.y * size.height
        )
        .onTapGesture {
            model.selectedPoint = point.id
        }
    }

    // MARK: - FLOATING PANEL

    private var floatingPanel: some View {

        VStack(spacing: 12) {

            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 25, height: 4)

            Button {
                model.deleteSelected()
            } label: {

                Image(systemName: "trash.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.red.gradient)
                    .clipShape(Circle())
            }

            VStack(spacing: 6) {

                HStack(spacing: 13) {

                    stat("PTS", "\(model.points.count)")

                    stat("CLK", "\(model.clickCount)")
                }

                Text(model.isRunning ? "RUNNING" : "SELECTING")
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.5)
                    .foregroundStyle(.purple)
            }
            .padding(7)
            .background(.gray.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {

                if model.isRunning {
                    model.stop()
                } else {
                    model.start()
                }

            } label: {

                Image(
                    systemName: model.isRunning
                    ? "pause.fill"
                    : "play.fill"
                )
                .font(.system(size: 25, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 74, height: 74)
                .background(
                    model.isRunning
                    ? Color.orange.gradient
                    : Color.cyan.gradient
                )
                .clipShape(Circle())
            }

            HStack(spacing: 8) {

                Button {
                    model.interval = max(
                        0.05,
                        model.interval - 0.1
                    )
                } label: {
                    Image(systemName: "chevron.left")
                }

                Text(
                    String(format: "%.2gs", model.interval)
                )
                .font(.system(size: 12, weight: .bold))
                .monospacedDigit()

                Button {
                    model.interval = min(
                        10,
                        model.interval + 0.1
                    )
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(.white)
            .padding(8)
            .background(.gray.opacity(0.15))
            .clipShape(Capsule())

            Button {
                model.addCenterPoint()
            } label: {

                Image(systemName: "plus")
                    .font(.system(size: 23, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.purple.gradient)
                    .clipShape(Circle())
            }

            Button {
                model.deleteAll()
            } label: {

                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .frame(width: 110)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.08))
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(
                    Color.purple.opacity(0.3),
                    lineWidth: 1
                )
        }
    }

    private func stat(_ title: String, _ value: String) -> some View {

        VStack(spacing: 3) {

            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
    }

    // MARK: - APP PICKER

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

                                if model.selectedApp?.id == app.id {

                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.purple)
                                }
                            }
                        }
                    }
                }

                Section("ỨNG DỤNG TÙY CHỈNH") {

                    TextField(
                        "Nhập URL hoặc liên kết ứng dụng",
                        text: $model.customURL
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    Button("Mở liên kết tùy chỉnh") {

                        model.openCustomApp()
                        model.showApps = false
                    }
                }

                Section {

                    Button {

                        model.openSelectedApp()

                    } label: {

                        Label(
                            "MỞ ỨNG DỤNG ĐÃ CHỌN",
                            systemImage: "arrow.up.right.square"
                        )
                        .foregroundStyle(.purple)
                    }
                    .disabled(model.selectedApp == nil)
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
