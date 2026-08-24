import SwiftUI

enum BunlyColor {
  static let cream = Color(red: 253 / 255, green: 242 / 255, blue: 230 / 255)
  static let wash = Color(red: 243 / 255, green: 238 / 255, blue: 252 / 255)
  static let ink = Color(red: 61 / 255, green: 43 / 255, blue: 107 / 255)
  static let brand = Color(red: 108 / 255, green: 79 / 255, blue: 208 / 255)
  static let sos = Color(red: 226 / 255, green: 87 / 255, blue: 76 / 255)
  static let sosDeep = Color(red: 176 / 255, green: 58 / 255, blue: 74 / 255)
  static let gold = Color(red: 242 / 255, green: 169 / 255, blue: 59 / 255)
  static let heart = Color(red: 229 / 255, green: 107 / 255, blue: 154 / 255)
}

struct WidgetLook {
  let id: String
  let top: Color
  let bottom: Color
  let ink: Color
  let muted: Color
  let chip: Color
  let glow: Color
  let dark: Bool

  static func named(_ raw: String) -> WidgetLook {
    switch raw {
    case "lilac":
      return WidgetLook(
        id: "lilac",
        top: Color(red: 247 / 255, green: 243 / 255, blue: 255 / 255),
        bottom: Color(red: 232 / 255, green: 223 / 255, blue: 252 / 255),
        ink: BunlyColor.ink,
        muted: BunlyColor.ink.opacity(0.55),
        chip: Color.white.opacity(0.72),
        glow: BunlyColor.brand.opacity(0.22),
        dark: false
      )
    case "night":
      return WidgetLook(
        id: "night",
        top: Color(red: 42 / 255, green: 28 / 255, blue: 74 / 255),
        bottom: Color(red: 24 / 255, green: 14 / 255, blue: 46 / 255),
        ink: Color(red: 244 / 255, green: 240 / 255, blue: 234 / 255),
        muted: Color(red: 244 / 255, green: 240 / 255, blue: 234 / 255).opacity(0.62),
        chip: Color.white.opacity(0.12),
        glow: Color(red: 185 / 255, green: 164 / 255, blue: 240 / 255).opacity(0.28),
        dark: true
      )
    case "gold":
      return WidgetLook(
        id: "gold",
        top: Color(red: 255 / 255, green: 248 / 255, blue: 234 / 255),
        bottom: Color(red: 247 / 255, green: 226 / 255, blue: 186 / 255),
        ink: BunlyColor.ink,
        muted: BunlyColor.ink.opacity(0.55),
        chip: Color.white.opacity(0.7),
        glow: BunlyColor.gold.opacity(0.28),
        dark: false
      )
    default:
      return WidgetLook(
        id: "cream",
        top: BunlyColor.wash,
        bottom: BunlyColor.cream,
        ink: BunlyColor.ink,
        muted: BunlyColor.ink.opacity(0.55),
        chip: Color.white.opacity(0.78),
        glow: BunlyColor.brand.opacity(0.16),
        dark: false
      )
    }
  }


  var fill: LinearGradient {
    LinearGradient(colors: [top, bottom], startPoint: .top, endPoint: .bottom)
  }
}

enum WidgetPose {
  static func imageName(_ raw: String) -> String {
    switch raw {
    case "hug": return "BondlyHug"
    case "calm": return "BondlyCalm"
    case "proud": return "BondlyProud"
    default: return "BondlySitting"
    }
  }
}

struct HomeWidgetBackground: ViewModifier {
  var look: WidgetLook = .named("cream")

  func body(content: Content) -> some View {
    if #available(iOS 17.0, *) {
      content.containerBackground(for: .widget) { look.fill }
    } else {
      content.background(look.fill)
    }
  }
}

struct BondlyImage: View {
  var pose: String
  var height: CGFloat

  var body: some View {
    Image(WidgetPose.imageName(pose))
      .resizable()
      .scaledToFit()
      .frame(height: height)
      .accessibilityHidden(true)
  }
}

struct WidgetChip: View {
  var icon: String
  var iconColor: Color
  var text: String
  var look: WidgetLook

  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: icon)
        .font(.system(size: 10, weight: .bold))
        .foregroundStyle(iconColor)
      Text(text)
        .font(.system(size: 12, weight: .bold, design: .rounded))
        .foregroundStyle(look.ink)
        .minimumScaleFactor(0.8)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 5)
    .background(look.chip, in: Capsule())
  }
}

struct SosCapsule: View {
  var soft: Bool
  var compact: Bool = false

  var body: some View {
    Text(soft ? "I'm here" : "SOS")
      .font(.system(size: compact ? 11 : 12, weight: .heavy, design: .rounded))
      .foregroundStyle(.white)
      .padding(.horizontal, compact ? 10 : 12)
      .padding(.vertical, compact ? 6 : 7)
      .background(soft ? BunlyColor.brand : BunlyColor.sos, in: Capsule())
  }
}

struct WeekDots: View {
  var marks: [Bool]
  var look: WidgetLook
  var todayIndex: Int

  private let names = ["M", "T", "W", "T", "F", "S", "S"]

  var body: some View {
    HStack(spacing: 6) {
      ForEach(0..<7, id: \.self) { index in
        VStack(spacing: 4) {
          Text(names[index])
            .font(.system(size: 9, weight: .bold, design: .rounded))
            .foregroundStyle(index == todayIndex ? look.ink : look.muted)
          Circle()
            .fill(marks.indices.contains(index) && marks[index] ? BunlyColor.brand : look.chip)
            .frame(width: 8, height: 8)
            .overlay {
              if index == todayIndex {
                Circle().stroke(look.ink.opacity(0.35), lineWidth: 1)
              }
            }
        }
        .frame(maxWidth: .infinity)
      }
    }
  }
}

