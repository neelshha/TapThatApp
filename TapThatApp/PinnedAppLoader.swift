import Foundation
import AppKit

struct PinnedAppConfig: Codable {
    let name: String
    let path: String
}

class PinnedAppLoader {
    static let fileName = "pinned_apps.json"

    static func configFileURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let cmdpopFolder = appSupport.appendingPathComponent("CmdPop", isDirectory: true)

        if !FileManager.default.fileExists(atPath: cmdpopFolder.path) {
            try? FileManager.default.createDirectory(at: cmdpopFolder, withIntermediateDirectories: true)
        }

        return cmdpopFolder.appendingPathComponent(fileName)
    }

    static func loadPinnedApps() -> [AppIcon] {
        let url = configFileURL()

        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([PinnedAppConfig].self, from: data) else {
            let fallback = fetchDefaultApps()
            savePinnedApps(fallback.map { PinnedAppConfig(name: $0.name, path: $0.path) })
            return fallback
        }

        return decoded.compactMap { entry in
            let icon = NSWorkspace.shared.icon(forFile: entry.path)
            icon.size = NSSize(width: 48, height: 48)
            return AppIcon(name: entry.name, icon: icon, path: entry.path)
        }
    }

    static func savePinnedApps(_ apps: [PinnedAppConfig]) {
        let url = configFileURL()
        let data = try? JSONEncoder().encode(apps)
        try? data?.write(to: url)
    }

    static func fetchDefaultApps() -> [AppIcon] {
        let fileManager = FileManager.default
        let appsURL = URL(fileURLWithPath: "/Applications", isDirectory: true)

        guard let appURLs = try? fileManager.contentsOfDirectory(at: appsURL, includingPropertiesForKeys: nil)
            .filter({ $0.pathExtension == "app" }) else {
            return []
        }

        return appURLs.prefix(8).compactMap { url in
            guard
                let bundle = Bundle(url: url),
                let name = bundle.infoDictionary?["CFBundleName"] as? String ?? url.deletingPathExtension().lastPathComponent as String?
            else { return nil }

            let icon = NSWorkspace.shared.icon(forFile: url.path)
            icon.size = NSSize(width: 48, height: 48)

            return AppIcon(name: name, icon: icon, path: url.path)
        }
    }
}
