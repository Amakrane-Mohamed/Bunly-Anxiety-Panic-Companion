import Flutter
import UIKit

/// Real UIKit bars overlaid on the Flutter window.
/// Uses `UINavigationBar` + `UITabBar` (the OS widgets), not a Flutter-drawn fake.
final class NativeChrome: NSObject, UITabBarDelegate {
  static let shared = NativeChrome()

  private var channel: FlutterMethodChannel?
  private var flutter: FlutterViewController?
  private var navigationBar: UINavigationBar?
  private var tabBar: UITabBar?
  private var navItems: [UINavigationItem] = []
  private var attached = false
  private var wantsNav = false
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
    case "setTitle":
      if let title = call.arguments as? String {
        currentItem?.title = title
      }
      result(nil)
    case "setVisible":
      let args = call.arguments as? [String: Any]
      setVisible(
        nav: boolValue(args?["nav"], fallback: true),
        tab: boolValue(args?["tab"], fallback: true)
      )
      result(nil)
    case "setBack":
      setBackVisible(boolValue(call.arguments, fallback: false))
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func attach(result: FlutterResult?) {
    if attached {
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

    let items = titles.map { title -> UINavigationItem in
      let item = UINavigationItem(title: title)
      item.largeTitleDisplayMode = .always
      item.hidesBackButton = true
      return item
    }
    navItems = items

    let navBar = UINavigationBar()
    navBar.prefersLargeTitles = true
    navBar.tintColor = purple
    navBar.setItems([items[0]], animated: false)
    navBar.translatesAutoresizingMaskIntoConstraints = false
    navigationBar = navBar

    let tabBar = UITabBar()
    tabBar.delegate = self
    tabBar.tintColor = purple
    tabBar.unselectedItemTintColor = .secondaryLabel
    tabBar.items = titles.enumerated().map { index, title in
      UITabBarItem(
        title: title,
        image: tabImage(index: index, selected: false),
        selectedImage: tabImage(index: index, selected: true)
      )
    }
    tabBar.selectedItem = tabBar.items?.first
    tabBar.translatesAutoresizingMaskIntoConstraints = false
    self.tabBar = tabBar

    window.addSubview(navBar)
    window.addSubview(tabBar)
    NSLayoutConstraint.activate([
      navBar.topAnchor.constraint(equalTo: window.topAnchor),
      navBar.leadingAnchor.constraint(equalTo: window.leadingAnchor),
      navBar.trailingAnchor.constraint(equalTo: window.trailingAnchor),
      tabBar.leadingAnchor.constraint(equalTo: window.leadingAnchor),
      tabBar.trailingAnchor.constraint(equalTo: window.trailingAnchor),
      tabBar.bottomAnchor.constraint(equalTo: window.bottomAnchor),
    ])

    setVisible(nav: wantsNav, tab: wantsTab)
    result?(nil)
  }

  private var currentItem: UINavigationItem? {
    navigationBar?.topItem ?? navItems.first
  }

  private func selectTab(_ index: Int) {
    guard index >= 0, index < navItems.count else { return }
    navigationBar?.setItems([navItems[index]], animated: false)
    if let items = tabBar?.items, index < items.count {
      tabBar?.selectedItem = items[index]
    }
    syncSafeArea()
  }

  private func setVisible(nav: Bool, tab: Bool) {
    wantsNav = nav
    wantsTab = tab
    guard attached else { return }
    navigationBar?.isHidden = !nav
    tabBar?.isHidden = !tab
    if let window = navigationBar?.window {
      if nav, let navigationBar { window.bringSubviewToFront(navigationBar) }
      if tab, let tabBar { window.bringSubviewToFront(tabBar) }
    }
    syncSafeArea()
    DispatchQueue.main.async { [weak self] in
      self?.syncSafeArea()
    }
  }

  private func syncSafeArea() {
    guard let flutter else { return }
    let windowInsets = flutter.view.window?.safeAreaInsets ?? flutter.view.safeAreaInsets
    var top: CGFloat = 0
    var bottom: CGFloat = 0
    if let navigationBar, !navigationBar.isHidden {
      top = max(0, navigationBar.frame.maxY - windowInsets.top)
    }
    if let tabBar, !tabBar.isHidden {
      bottom = max(0, tabBar.frame.height - windowInsets.bottom)
    }
    flutter.additionalSafeAreaInsets = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
  }

  private var selectedIndex: Int {
    guard let tabBar, let selected = tabBar.selectedItem else { return 0 }
    return tabBar.items?.firstIndex(of: selected) ?? 0
  }

  private func setBackVisible(_ show: Bool) {
    guard let item = currentItem else { return }
    if show {
      item.largeTitleDisplayMode = .never
      let previous = titles[selectedIndex]
      let back = UIBarButtonItem(
        image: UIImage(systemName: "chevron.backward")?.withConfiguration(
          UIImage.SymbolConfiguration(weight: .semibold)
        ),
        style: .plain,
        target: self,
        action: #selector(nativeBack)
      )
      back.accessibilityLabel = previous
      item.leftBarButtonItem = back
    } else {
      item.largeTitleDisplayMode = .always
      item.leftBarButtonItem = nil
      item.hidesBackButton = true
    }
    syncSafeArea()
  }

  @objc private func nativeBack() {
    channel?.invokeMethod("back", arguments: nil)
  }

  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    guard let index = tabBar.items?.firstIndex(of: item) else { return }
    navigationBar?.setItems([navItems[index]], animated: true)
    channel?.invokeMethod("tabSelected", arguments: index)
    syncSafeArea()
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
