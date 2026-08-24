import Foundation

struct WidgetSnapshot: Equatable {
  var hearts: Int
  var streak: Int
  var line: String
  var practicedToday: Bool
  var checkedInToday: Bool
  var look: String
  var pose: String
  var voice: String
  var showHearts: Bool
  var showStreak: Bool
  var customLine: String
  var futureNote: String
  var sosStyle: String
  var name: String
  var week: String

  static let groupId = "group.com.bunlyapp.bunly"

  static var placeholder: WidgetSnapshot {
    WidgetSnapshot(
      hearts: 5,
      streak: 3,
      line: "I'm here if a wave comes.",
      practicedToday: false,
      checkedInToday: false,
      look: "cream",
      pose: "sitting",
      voice: "bondly",
      showHearts: true,
      showStreak: true,
      customLine: "",
      futureNote: "",
      sosStyle: "sos",
      name: "",
      week: "1110000"
    )
  }

  static func current() -> WidgetSnapshot {
    let defaults = UserDefaults(suiteName: groupId)
    let hearts = defaults?.object(forKey: "hearts") as? Int
    let storedLine = defaults?.string(forKey: "line")?
      .trimmingCharacters(in: .whitespacesAndNewlines)

    return WidgetSnapshot(
      hearts: (hearts ?? 5).clamped(to: 0...5),
      streak: defaults?.integer(forKey: "streak") ?? 0,
      line: storedLine ?? "",
      practicedToday: defaults?.bool(forKey: "practicedToday") ?? false,
      checkedInToday: defaults?.bool(forKey: "checkedInToday") ?? false,
      look: defaults?.string(forKey: "look") ?? "cream",
      pose: defaults?.string(forKey: "pose") ?? "sitting",
      voice: defaults?.string(forKey: "voice") ?? "bondly",
      showHearts: defaults?.object(forKey: "showHearts") as? Bool ?? true,
      showStreak: defaults?.object(forKey: "showStreak") as? Bool ?? true,
      customLine: defaults?.string(forKey: "customLine") ?? "",
      futureNote: defaults?.string(forKey: "futureNote") ?? "",
      sosStyle: defaults?.string(forKey: "sosStyle") ?? "sos",
      name: defaults?.string(forKey: "name") ?? "",
      week: defaults?.string(forKey: "week") ?? "0000000"
    )
  }

  var displayLine: String {
    switch voice {
    case "note":
      let note = futureNote.trimmingCharacters(in: .whitespacesAndNewlines)
      return note.isEmpty ? fallbackLine : note
    case "yours":
      let custom = customLine.trimmingCharacters(in: .whitespacesAndNewlines)
      return custom.isEmpty ? fallbackLine : custom
    case "calm":
      return Self.calmLine
    default:
      return fallbackLine
    }
  }

  var fallbackLine: String {
    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? Self.calmLine : trimmed
  }

  var greeting: String {
    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty || trimmed == "friend" { return "Bondly" }
    return "Hi, \(trimmed)"
  }

  var weekMarks: [Bool] {
    let padded = (week + "0000000").prefix(7)
    return padded.map { $0 == "1" }
  }

  var isSoftSos: Bool { sosStyle == "here" }

  var checkInPrompt: String {
    let hour = Calendar.current.component(.hour, from: Date())
    if hour < 12 { return "How does this morning feel?" }
    if hour >= 18 { return "How does the evening feel?" }
    return "How does this moment feel?"
  }

  static var calmLine: String {
    let hour = Calendar.current.component(.hour, from: Date())
    if hour < 6 || hour >= 22 { return "Quiet is allowed. I'm still here." }
    if hour < 12 { return "I'm here if a wave comes." }
    if hour >= 18 { return "We can take this slowly." }
    return "I'm here with you."
  }
}

private extension Comparable {
  func clamped(to range: ClosedRange<Self>) -> Self {
    min(max(self, range.lowerBound), range.upperBound)
  }
}
