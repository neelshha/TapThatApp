import AppKit
import Combine
import Foundation
import SwiftUI

class SettingsStore: ObservableObject {
    @AppStorage("showNames") var showNames: Bool = false
    @AppStorage("iconSize") var iconSize: Double = 48
    @AppStorage("ringRadius") var ringRadius: Double = 160
    @AppStorage("shortcutKeyCode") var shortcutKeyCode: Int = 49 {
        didSet {
            objectWillChange.send()
            shortcutDidChange.send(())
        }
    }
    @AppStorage("shortcutModifiersRaw") var shortcutModifiersRaw: Int = Int(NSEvent.ModifierFlags.option.rawValue) {
        didSet {
            objectWillChange.send()
            shortcutDidChange.send(())
        }
    }

    private let bookmarkDataKey = "selectedAppBookmarkDataList"
    private let legacyPathsKey = "selectedAppPaths"

    @Published private(set) var bookmarkDataList: [Data] = []
    let shortcutDidChange = PassthroughSubject<Void, Never>()

    var computedRadius: Double {
        ringRadius
    }

    var shortcutModifiers: NSEvent.ModifierFlags {
        NSEvent.ModifierFlags(rawValue: UInt(shortcutModifiersRaw))
    }

    func setShortcut(keyCode: Int, modifiers: NSEvent.ModifierFlags) {
        shortcutKeyCode = keyCode
        shortcutModifiersRaw = Int(modifiers.rawValue)
    }

    init() {
        loadBookmarks()
    }

    func loadBookmarks() {
        if let stored = UserDefaults.standard.data(forKey: bookmarkDataKey),
           let decoded = try? JSONDecoder().decode([Data].self, from: stored) {
            bookmarkDataList = decoded
        } else {
            bookmarkDataList = []
            migrateLegacyPathsIfNeeded()
        }
        pruneStaleBookmarks()
    }

    /// Removes bookmark data that no longer resolves or points at a missing app (e.g. app moved or deleted).
    private func pruneStaleBookmarks() {
        var valid: [Data] = []
        for data in bookmarkDataList {
            do {
                var stale = false
                let url = try URL(
                    resolvingBookmarkData: data,
                    options: [.withSecurityScope, .withoutUI],
                    relativeTo: nil,
                    bookmarkDataIsStale: &stale
                )
                if stale { continue }
                guard url.startAccessingSecurityScopedResource() else { continue }
                defer { url.stopAccessingSecurityScopedResource() }
                if FileManager.default.fileExists(atPath: url.path) {
                    valid.append(data)
                }
            } catch {
                continue
            }
        }
        if valid.count != bookmarkDataList.count {
            bookmarkDataList = valid
            persistBookmarks()
        }
    }

    /// Plain paths from pre–App Store builds do not work under sandbox; clear legacy storage.
    private func migrateLegacyPathsIfNeeded() {
        guard UserDefaults.standard.object(forKey: legacyPathsKey) != nil else { return }
        UserDefaults.standard.removeObject(forKey: legacyPathsKey)
    }

    private func persistBookmarks() {
        if let encoded = try? JSONEncoder().encode(bookmarkDataList) {
            UserDefaults.standard.set(encoded, forKey: bookmarkDataKey)
        }
        objectWillChange.send()
    }

    /// Call while `url` is security-scoped (e.g. inside NSOpenPanel handling after `startAccessingSecurityScopedResource()`).
    func addAppBookmark(for url: URL) throws {
        let bookmark = try url.bookmarkData(
            options: [.withSecurityScope],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        if bookmarkDataList.contains(bookmark) { return }
        bookmarkDataList.append(bookmark)
        persistBookmarks()
    }

    func removeApp(at index: Int) {
        guard bookmarkDataList.indices.contains(index) else { return }
        bookmarkDataList.remove(at: index)
        persistBookmarks()
    }

    func removeApps(at offsets: IndexSet) {
        bookmarkDataList.remove(atOffsets: offsets)
        persistBookmarks()
    }

    /// Resolves stored bookmarks. Call `stopAccess` for each pair when finished with the returned URLs.
    func resolveAppsForAccess() -> [(url: URL, stopAccess: () -> Void)] {
        var results: [(URL, () -> Void)] = []
        for data in bookmarkDataList {
            do {
                var stale = false
                let url = try URL(
                    resolvingBookmarkData: data,
                    options: [.withSecurityScope, .withoutUI],
                    relativeTo: nil,
                    bookmarkDataIsStale: &stale
                )
                if stale { continue }
                guard url.startAccessingSecurityScopedResource() else { continue }
                results.append((url, { url.stopAccessingSecurityScopedResource() }))
            } catch {
                continue
            }
        }
        return results
    }

    func appIcons(accessing iconSize: CGFloat) -> [AppIcon] {
        let pairs = resolveAppsForAccess()
        defer { pairs.forEach { $0.stopAccess() } }
        return pairs.compactMap { pair in
            let url = pair.url
            let path = url.path
            guard FileManager.default.fileExists(atPath: path) else { return nil }
            let name = url.deletingPathExtension().lastPathComponent
            let icon = NSWorkspace.shared.icon(forFile: path)
            icon.size = NSSize(width: iconSize, height: iconSize)
            return AppIcon(name: name, icon: icon, url: url)
        }
    }
}
