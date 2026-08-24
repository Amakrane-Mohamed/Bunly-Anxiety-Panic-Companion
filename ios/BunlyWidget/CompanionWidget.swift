import SwiftUI
import WidgetKit

struct CompanionProvider: TimelineProvider {
  func placeholder(in context: Context) -> CompanionEntry {
    CompanionEntry(date: Date(), snapshot: .placeholder)
  }

  func getSnapshot(in context: Context, completion: @escaping (CompanionEntry) -> Void) {
    completion(CompanionEntry(date: Date(), snapshot: WidgetSnapshot.current()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<CompanionEntry>) -> Void) {
    let now = Date()
    let entry = CompanionEntry(date: now, snapshot: WidgetSnapshot.current())
    let next = Calendar.current.date(byAdding: .minute, value: 30, to: now) ?? now.addingTimeInterval(1800)
    completion(Timeline(entries: [entry], policy: .after(next)))
  }
}

struct CompanionEntry: TimelineEntry {
  let date: Date
  let snapshot: WidgetSnapshot
}

struct CompanionWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "BunlyCompanion", provider: CompanionProvider()) { entry in
      CompanionView(entry: entry)
    }
    .configurationDisplayName("Bondly")
    .description("Bondly on your Home Screen and Lock Screen. A line, hearts, and a way in.")
    .supportedFamilies([
      .systemSmall,
      .systemMedium,
      .systemLarge,
      .accessoryCircular,
      .accessoryRectangular,
      .accessoryInline,
    ])
  }
}

struct CompanionView: View {
  @Environment(\.widgetFamily) private var family
  var entry: CompanionEntry

  private var snap: WidgetSnapshot { entry.snapshot }
  private var look: WidgetLook { .named(snap.look) }
  private var todayIndex: Int { (Calendar.current.component(.weekday, from: Date()) + 5) % 7 }

  var body: some View {
    Group {
      switch family {
      case .systemMedium:
        medium
      case .systemLarge:
        large
      case .accessoryCircular:
        lockCircular
      case .accessoryRectangular:
        lockRectangular
      case .accessoryInline:
        Text(snap.displayLine)
      default:
        small
      }
    }
    .widgetURL(URL(string: "bunly://today"))
  }

  private var small: some View {
    VStack(spacing: 0) {
      HStack {
        Text("Bondly")
          .font(.system(size: 11, weight: .semibold, design: .rounded))
          .foregroundStyle(look.muted)
        Spacer()
        if snap.showHearts {
          hearts(compact: true)
        }
      }
      Spacer(minLength: 2)
      ZStack {
        Circle()
          .fill(look.glow)
          .frame(width: 84, height: 84)
        BondlyImage(pose: snap.pose, height: 78)
      }
      Spacer(minLength: 4)
      Text(snap.displayLine)
        .font(.system(size: 13, weight: .semibold, design: .rounded))
        .foregroundStyle(look.ink)
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .minimumScaleFactor(0.82)
    }
    .padding(14)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .modifier(HomeWidgetBackground(look: look))
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Bondly. \(snap.displayLine). \(snap.hearts) hearts.")
  }

  private var medium: some View {
    HStack(spacing: 12) {
      ZStack {
        Circle()
          .fill(look.glow)
          .frame(width: 108, height: 108)
        BondlyImage(pose: snap.pose, height: 108)
      }
      .frame(width: 108)

      VStack(alignment: .leading, spacing: 6) {
        Text(snap.greeting)
          .font(.system(size: 12, weight: .semibold, design: .rounded))
          .foregroundStyle(look.muted)
        Text(snap.displayLine)
          .font(.system(size: 16, weight: .semibold, design: .rounded))
          .foregroundStyle(look.ink)
          .lineLimit(3)
          .minimumScaleFactor(0.8)
        Spacer(minLength: 0)
        HStack(spacing: 6) {
          if snap.showHearts { hearts(compact: true) }
          if snap.showStreak { streak }
          Spacer(minLength: 4)
          Link(destination: URL(string: "bunly://sos")!) {
            SosCapsule(soft: snap.isSoftSos, compact: true)
          }
          .accessibilityLabel(snap.isSoftSos ? "I'm here. Help with a wave." : "SOS. Help with a panic attack.")
        }
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .modifier(HomeWidgetBackground(look: look))
    .accessibilityElement(children: .contain)
  }

  private var large: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .top, spacing: 12) {
        ZStack {
          Circle()
            .fill(look.glow)
            .frame(width: 92, height: 92)
          BondlyImage(pose: snap.pose, height: 92)
        }
        VStack(alignment: .leading, spacing: 6) {
          Text(snap.greeting)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(look.muted)
          Text(snap.displayLine)
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .foregroundStyle(look.ink)
            .lineLimit(3)
            .minimumScaleFactor(0.8)
        }
        Spacer(minLength: 0)
      }
      WeekDots(marks: snap.weekMarks, look: look, todayIndex: todayIndex)
      Spacer(minLength: 0)
      HStack(spacing: 8) {
        if snap.showHearts { hearts(compact: false) }
        if snap.showStreak { streak }
        Spacer()
        Link(destination: URL(string: "bunly://checkin")!) {
          Text(snap.checkedInToday ? "Checked in" : "Check in")
            .font(.system(size: 12, weight: .heavy, design: .rounded))
            .foregroundStyle(look.dark ? look.ink : BunlyColor.brand)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(look.chip, in: Capsule())
        }
        Link(destination: URL(string: "bunly://sos")!) {
          SosCapsule(soft: snap.isSoftSos)
        }
      }
    }
    .padding(18)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .modifier(HomeWidgetBackground(look: look))
  }

  private var lockCircular: some View {
    Gauge(value: Double(snap.hearts), in: 0...5) {
      Image(systemName: "heart.fill")
    } currentValueLabel: {
      Text("\(snap.hearts)")
        .font(.system(size: 16, weight: .bold, design: .rounded))
    }
    .gaugeStyle(.accessoryCircular)
    .accessibilityLabel("\(snap.hearts) of 5 hearts")
  }

  private var lockRectangular: some View {
    HStack(spacing: 8) {
      Image(systemName: "heart.fill")
      VStack(alignment: .leading, spacing: 1) {
        Text("Bondly")
          .font(.headline)
        Text(snap.displayLine)
          .font(.subheadline)
          .lineLimit(1)
          .minimumScaleFactor(0.8)
      }
      Spacer(minLength: 0)
    }
    .accessibilityLabel("Bondly. \(snap.displayLine)")
  }

  private func hearts(compact: Bool) -> some View {
    WidgetChip(
      icon: "heart.fill",
      iconColor: BunlyColor.heart,
      text: compact ? "\(snap.hearts)" : "\(snap.hearts) hearts",
      look: look
    )
    .accessibilityLabel("\(snap.hearts) of 5 hearts")
  }

  private var streak: some View {
    WidgetChip(
      icon: "flame.fill",
      iconColor: BunlyColor.gold,
      text: "\(snap.streak)",
      look: look
    )
    .accessibilityLabel("Streak \(snap.streak) days")
  }
}
