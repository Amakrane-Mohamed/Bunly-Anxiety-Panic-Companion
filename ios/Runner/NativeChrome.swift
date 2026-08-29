import Flutter
import UIKit

/// Real iOS tab bar only. No navigation bar overlay.
final class NativeChrome: NSObject, UITabBarDelegate {
  static let shared = NativeChrome()

  private var channel: FlutterMethodChannel?
  private var flutter: FlutterViewController?
  private var tabBar: UITabBar?
  private var attached = false
  private var wantsTab = false
  private var retries = 0

  private let titles = ["Today", "Insights", "Journey", "You"]
  private let purple = UIColor(red: 107 / 255, green: 76 / 255, blue: 154 / 255, alpha: 1)

  func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "bunly/native_chrome", binaryMessenger: messenger)
    self.channel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "attach":
      attach(result: result)
    case "setTab":
      if let index = intValue(call.arguments) {
        selectTab(index)
      }
      result(nil)
    case "setVisible":
      let args = call.arguments as? [String: Any]
      setVisible(tab: boolValue(args?["tab"], fallback: true))
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func attach(result: FlutterResult?) {
    if attached {
      if let window = currentWindow() {
        stripNavigationBars(from: window)
      }
      setVisible(tab: wantsTab)
      result?(nil)
      return
    }

    let flutter = currentFlutterController()
    let window = flutter?.view.window ?? currentWindow()
    guard let flutter, let window, flutter.view.window != nil else {
      retries += 1
      if retries > 60 {
        result?(nil)
        return
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
        self?.attach(result: result)
      }
      return
    }

    attached = true
    self.flutter = flutter
    stripNavigationBars(from: window)

    let appearance = UITabBarAppearance()
    appearance.configureWithDefaultBackground()

    let tabBar = LayoutTabBar()
    tabBar.delegate = self
    tabBar.tintColor = purple
    tabBar.unselectedItemTintColor = .secondaryLabel
    tabBar.standardAppearance = appearance
    tabBar.scrollEdgeAppearance = appearance
    tabBar.items = titles.enumerated().map { index, title in
      UITabBarItem(
        title: title,
        image: tabImage(index: index, selected: false),
        selectedImage: tabImage(index: index, selected: true)
      )
    }
    tabBar.selectedItem = tabBar.items?.first
    tabBar.isHidden = true
    tabBar.translatesAutoresizingMaskIntoConstraints = false
    tabBar.onLayout = { [weak self] in
      self?.syncSafeArea()
    }
    self.tabBar = tabBar

    window.addSubview(tabBar)
    NSLayoutConstraint.activate([
      tabBar.leadingAnchor.constraint(equalTo: window.leadingAnchor),
      tabBar.trailingAnchor.constraint(equalTo: window.trailingAnchor),
      tabBar.bottomAnchor.constraint(equalTo: window.bottomAnchor),
    ])

    setVisible(tab: wantsTab)
    result?(nil)
  }

  private func selectTab(_ index: Int) {
    guard let items = tabBar?.items, index >= 0, index < items.count else { return }
    tabBar?.selectedItem = items[index]
  }

  private func setVisible(tab: Bool) {
    wantsTab = tab
    guard attached else { return }
    if let window = tabBar?.window ?? currentWindow() {
      stripNavigationBars(from: window)
    }
    tabBar?.isHidden = !tab
    if tab, let tabBar, let window = tabBar.window {
      window.bringSubviewToFront(tabBar)
    }
    syncSafeArea()
    DispatchQueue.main.async { [weak self] in
      self?.syncSafeArea()
    }
  }

  private func stripNavigationBars(from view: UIView) {
    for subview in view.subviews {
      if subview is UINavigationBar {
        subview.isHidden = true
        subview.removeFromSuperview()
      } else {
        stripNavigationBars(from: subview)
      }
    }
  }

  private func syncSafeArea() {
    guard let flutter else { return }

    var bottom: CGFloat = 0
    let safe = flutter.view.window?.safeAreaInsets ?? flutter.view.safeAreaInsets
    if let tabBar, !tabBar.isHidden {
      let height = tabBar.bounds.height > 0 ? tabBar.bounds.height : tabBar.frame.height
      bottom = max(0, height - safe.bottom)
    }
    let insets = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
    if flutter.additionalSafeAreaInsets != insets {
      flutter.additionalSafeAreaInsets = insets
    }
  }

  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    guard let index = tabBar.items?.firstIndex(of: item) else { return }
    channel?.invokeMethod("tabSelected", arguments: index)
  }

  private func tabImage(index: Int, selected: Bool) -> UIImage? {
    let names = [
      selected ? "sun.max.fill" : "sun.max",
      selected ? "chart.bar.fill" : "chart.bar",
      selected ? "map.fill" : "map",
      selected ? "person.fill" : "person",
    ]
    return UIImage(systemName: names[index])
  }

  private func intValue(_ value: Any?) -> Int? {
    if let int = value as? Int { return int }
    if let number = value as? NSNumber { return number.intValue }
    return nil
  }

  private func boolValue(_ value: Any?, fallback: Bool) -> Bool {
    if let bool = value as? Bool { return bool }
    if let number = value as? NSNumber { return number.boolValue }
    return fallback
  }

  private func currentWindow() -> UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first { $0.isKeyWindow } ?? UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first
  }

  private func currentFlutterController() -> FlutterViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    for scene in scenes {
      for window in scene.windows {
        if let flutter = window.rootViewController as? FlutterViewController {
          return flutter
        }
        if let flutter = findFlutter(in: window.rootViewController) {
          return flutter
        }
      }
    }
    return flutter
  }

  private func findFlutter(in controller: UIViewController?) -> FlutterViewController? {
    guard let controller else { return nil }
    if let flutter = controller as? FlutterViewController {
      return flutter
    }
    for child in controller.children {
      if let flutter = findFlutter(in: child) {
        return flutter
      }
    }
    return findFlutter(in: controller.presentedViewController)
  }
}

private final class LayoutTabBar: UITabBar {
  var onLayout: (() -> Void)?

  override func layoutSubviews() {
    super.layoutSubviews()
    onLayout?()
  }
}
