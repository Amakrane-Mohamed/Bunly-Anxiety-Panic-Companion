import SwiftUI
import WidgetKit

struct CheckInProvider: TimelineProvider {
  func placeholder(in context: Context) -> CheckInEntry {
    CheckInEntry(date: Date(), snapshot: .placeholder)
  }

  func getSnapshot(in context: Context, completion: @escaping (CheckInEntry) -> Void) {
    completion(CheckInEntry(date: Date(), snapshot: WidgetSnapshot.current()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<CheckInEntry>) -> Void) {
    let now = Date()
    let entry = CheckInEntry(date: now, snapshot: WidgetSnapshot.current())
    let next = Calendar.current.date(byAdding: .minute, value: 15, to: now) ?? now.addingTimeInterval(900)
    completion(Timeline(entries: [entry], policy: .after(next)))
  }
}

struct CheckInEntry: TimelineEntry {
  let date: Date
  let snapshot: WidgetSnapshot
}

struct CheckInWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "BunlyCheckIn", provider: CheckInProvider()) { entry in
      CheckInView(entry: entry)
    }
    .configurationDisplayName("Check-in")
    .description("A quiet prompt to tell Bondly how this moment feels.")
    .supportedFamilies([
      .systemSmall,
      .systemMedium,
      .accessoryCircular,
      .accessoryRectangular,
    ])
  }
}

struct CheckInView: View {
  @Environment(\.widgetFamily) private var family
  var entry: CheckInEntry

  private var snap: WidgetSnapshot { entry.snapshot }
  private var look: WidgetLook { .named(snap.look) }
  private var done: Bool { snap.checkedInToday }

  var body: some View {
    Group {
      switch family {
      case .systemMedium:
        medium
      case .accessoryCircular:
        lockCircular
      case .accessoryRectangular:
        lockRectangular
      default:
        small
      }
    }
    .widgetURL(URL(string: "bunly://checkin"))
  }

  private var small: some View {
    VStack(spacing: 0) {
      HStack {
        Text("Check-in")
          .font(.system(size: 11, weight: .semibold, design: .rounded))
          .foregroundStyle(look.muted)
        Spacer()
        if done {
          Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(BunlyColor.brand)
            .font(.system(size: 14, weight: .bold))
        }
      }
      Spacer(minLength: 4)
      ZStack {
        Circle().fill(look.glow).frame(width: 78, height: 78)
        BondlyImage(pose: snap.pose, height: 72)
      }
      Spacer(minLength: 4)
      Text(done ? "You checked in. Thank you." : snap.checkInPrompt)
        .font(.system(size: 13, weight: .semibold, design: .rounded))
        .foregroundStyle(look.ink)
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .minimumScaleFactor(0.82)
    }
    .padding(14)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .modifier(HomeWidgetBackground(look: look))
    .accessibilityLabel(done ? "Checked in today." : "Check in. \(snap.checkInPrompt)")
  }

  private var medium: some View {
    HStack(spacing: 12) {
      ZStack {
        Circle().fill(look.glow).frame(width: 108, height: 108)
        BondlyImage(pose: snap.pose, height: 108)
      }
      .frame(width: 108)
      VStack(alignment: .leading, spacing: 6) {
        Text(snap.greeting)
          .font(.system(size: 12, weight: .semibold, design: .rounded))
          .foregroundStyle(look.muted)
        Text(done ? "You already checked in. That's enough." : snap.checkInPrompt)
          .font(.system(size: 16, weight: .semibold, design: .rounded))
          .foregroundStyle(look.ink)
          .lineLimit(3)
          .minimumScaleFactor(0.8)
        Spacer(minLength: 0)
        Text(done ? "Checked in" : "Check in")
          .font(.system(size: 12, weight: .heavy, design: .rounded))
          .foregroundStyle(.white)
          .padding(.horizontal, 12)
          .padding(.vertical, 7)
          .background(BunlyColor.brand, in: Capsule())
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .modifier(HomeWidgetBackground(look: look))
    .accessibilityLabel(done ? "Checked in today." : "Check in with Bondly.")
  }

  private var lockCircular: some View {
    ZStack {
      AccessoryWidgetBackground()
      VStack(spacing: 1) {
        Image(systemName: done ? "checkmark" : (Calendar.current.component(.hour, from: Date()) >= 18 ? "moon.fill" : "sun.max.fill"))
          .font(.system(size: 16, weight: .bold))
        Text(done ? "Done" : "Check")
          .font(.system(size: 10, weight: .heavy, design: .rounded))
      }
    }
    .accessibilityLabel(done ? "Checked in." : "Check in.")
  }

  private var lockRectangular: some View {
    HStack(spacing: 8) {
      Image(systemName: done ? "checkmark.circle.fill" : "sun.max.fill")
      VStack(alignment: .leading, spacing: 1) {
        Text(done ? "Checked in" : "Check in")
          .font(.headline)
        Text(done ? "Bondly has today's note." : "Bondly is listening.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .lineLimit(1)
      }
      Spacer(minLength: 0)
    }
    .accessibilityLabel(done ? "Checked in today." : "Check in with Bondly.")
  }
}
