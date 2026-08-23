import Flutter
import UIKit
import WidgetKit

enum WidgetBridge {
  static let groupId = "group.com.bunlyapp.bunly"
  static let channelName = "bunly/widget"

  private static var channel: FlutterMethodChannel?
  private static var pendingHost: String?

  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    Self.channel = channel
    channel.setMethodCallHandler { call, result in
      guard call.method == "update", let args = call.arguments as? [String: Any] else {
        result(FlutterMethodNotImplemented)
        return
      }
      write(args)
      WidgetCenter.shared.reloadAllTimelines()
      result(nil)
    }
    if let pendingHost {
      channel.invokeMethod("opened", arguments: pendingHost)
      Self.pendingHost = nil
    }
  }

  static func handle(_ url: URL) {
    let host = url.host ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    guard !host.isEmpty else { return }
    if let channel {
      channel.invokeMethod("opened", arguments: host)
    } else {
      pendingHost = host
    }
  }

  private static func write(_ args: [String: Any]) {
    let defaults = UserDefaults(suiteName: groupId)
    defaults?.set(args["hearts"] as? Int ?? 5, forKey: "hearts")
    defaults?.set(args["streak"] as? Int ?? 0, forKey: "streak")
    defaults?.set(args["line"] as? String ?? "", forKey: "line")
    defaults?.set(args["practicedToday"] as? Bool ?? false, forKey: "practicedToday")
  }
}
