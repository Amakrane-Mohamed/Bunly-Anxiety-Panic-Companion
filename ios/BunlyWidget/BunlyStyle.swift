import SwiftUI

enum BunlyColor {
  static let cream = Color(red: 253 / 255, green: 242 / 255, blue: 230 / 255)
  static let wash = Color(red: 243 / 255, green: 238 / 255, blue: 252 / 255)
  static let ink = Color(red: 61 / 255, green: 43 / 255, blue: 107 / 255)
  static let brand = Color(red: 108 / 255, green: 79 / 255, blue: 208 / 255)
  static let sos = Color(red: 232 / 255, green: 91 / 255, blue: 82 / 255)
  static let sosLip = Color(red: 176 / 255, green: 58 / 255, blue: 74 / 255)
  static let gold = Color(red: 242 / 255, green: 169 / 255, blue: 59 / 255)
}

struct HomeWidgetBackground: ViewModifier {
  func body(content: Content) -> some View {
    if #available(iOS 17.0, *) {
      content.containerBackground(for: .widget) {
        wash
      }
    } else {
      content.background(wash)
    }
  }

  private var wash: some View {
    LinearGradient(
      colors: [BunlyColor.wash, BunlyColor.cream],
      startPoint: .top,
      endPoint: .bottom
    )
  }
}
