import Core
import Combine
import Foundation

@MainActor
class OptionsViewModel: ObservableObject {
    private let rpc: RPC = .shared
    private let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var canPlayAlert = false

    init() {
        appState.$capabilities
            .receive(on: DispatchQueue.main)
            .compactMap(\.?.canPlayAlert)
            .assign(to: \.canPlayAlert, on: self)
            .store(in: &disposeBag)
    }

    func migrateSubGHz() {
        Task {
            for file in try await rpc.listDirectory(at: "/ext/subghz/saved") {
                guard case .file(let file) = file else {
                    continue
                }
                try await rpc.moveFile(
                    from: "/ext/subghz/saved/\(file.name)",
                    to: "/ext/subghz/\(file.name)")
            }
            try await rpc.deleteFile(at: "/ext/subghz/saved")
        }
    }

    func playAlert() {
        Task {
            try await rpc.playAlert()
        }
    }

    func rebootFlipper() {
        Task {
            try await rpc.reboot(to: .os)
        }
    }

    func resetApp() {
        appState.reset()
    }

    func unpairFlipper() {
        Task {
            try await rpc.deleteFile(at: .init(string: "/int/bt.keys"))
            try await rpc.reboot(to: .os)
        }
    }
}
