import Foundation

struct WidgetSnapshot: Equatable {
  var hearts: Int
  var streak: Int
  var line: String
  var practicedToday: Bool

  static let groupId = "group.com.bunlyapp.bunly"

  static var placeholder: WidgetSnapshot {
    WidgetSnapshot(
      hearts: 5,
      streak: 0,
      line: "I’m here if a wave comes.",
      practicedToday: false
    )
  }

  static func current() -> WidgetSnapshot {
    let defaults = UserDefaults(suiteName: groupId)
    let hearts = defaults?.object(forKey: "hearts") as? Int
    let line = defaults?.string(forKey: "line")?.trimmingCharacters(in: .whitespacesAndNewlines)

    return WidgetSnapshot(
      hearts: (hearts ?? 5).clamped(to: 0...5),
      streak: defaults?.integer(forKey: "streak") ?? 0,
      line: (line?.isEmpty == false) ? line! : Self.hourLine,
      practicedToday: defaults?.bool(forKey: "practicedToday") ?? false
    )
  }

  static func write(
    hearts: Int,
    streak: Int,
    line: String,
    practicedToday: Bool
  ) {
    let defaults = UserDefaults(suiteName: groupId)
    defaults?.set(hearts, forKey: "hearts")
    defaults?.set(streak, forKey: "streak")
    defaults?.set(line, forKey: "line")
    defaults?.set(practicedToday, forKey: "practicedToday")
  }

  static var hourLine: String {
    let hour = Calendar.current.component(.hour, from: Date())
    if hour < 6 || hour >= 22 {
      return "Quiet is allowed. I’m still here."
    }
    if hour < 12 {
      return "I’m here if a wave comes."
    }
    if hour >= 18 {
      return "We can take this slowly."
    }
    return "I’m here with you."
  }
}

private extension Comparable {
  func clamped(to range: ClosedRange<Self>) -> Self {
    min(max(self, range.lowerBound), range.upperBound)
  }
}
