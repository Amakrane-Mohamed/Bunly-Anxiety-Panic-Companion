import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    expandIPadWindow(scene)
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    expandIPadWindow(scene)
  }

  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    super.scene(scene, openURLContexts: URLContexts)
    if let url = URLContexts.first?.url {
      WidgetBridge.handle(url)
    }
  }

  @available(iOS 26.0, *)
  override func preferredWindowingControlStyle(
    for windowScene: UIWindowScene
  ) -> UIWindowScene.WindowingControlStyle {
    .minimal
  }

  private func expandIPadWindow(_ scene: UIScene) {
    guard runningOnIPad, let windowScene = scene as? UIWindowScene else { return }

    let screen = windowScene.screen.bounds.size
    let restrictions = windowScene.sizeRestrictions
    restrictions?.minimumSize = CGSize(width: 768, height: 1024)
    restrictions?.maximumSize = CGSize(
      width: max(screen.width, 2000),
      height: max(screen.height, 2000),
    )
    if #available(iOS 16.0, *) {
      restrictions?.allowsFullScreen = true
      windowScene.requestGeometryUpdate(
        .iOS(systemFrame: windowScene.screen.bounds),
      )
    }
  }

  private var runningOnIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
      || UIDevice.current.model.hasPrefix("iPad")
  }
}
