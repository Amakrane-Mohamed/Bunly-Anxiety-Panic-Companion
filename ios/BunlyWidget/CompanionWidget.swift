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
    .description("A quiet check-in from Bondly. Hearts, streak, and a line for right now.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct CompanionView: View {
  @Environment(\.widgetFamily) private var family
  var entry: CompanionEntry

  var body: some View {
    Group {
      switch family {
      case .systemMedium:
        medium
      default:
        small
      }
    }
    .widgetURL(URL(string: "bunly://today"))
    .modifier(HomeWidgetBackground())
  }

  private var small: some View {
    VStack(spacing: 0) {
      HStack {
        hearts
        Spacer()
        Text("Bunly")
          .font(.system(size: 12, weight: .semibold, design: .rounded))
          .foregroundStyle(BunlyColor.ink.opacity(0.55))
      }
      Spacer(minLength: 4)
      Image("BondlySitting")
        .resizable()
        .scaledToFit()
        .frame(maxHeight: 72)
        .accessibilityHidden(true)
      Spacer(minLength: 4)
      Text(entry.snapshot.line)
        .font(.system(size: 13, weight: .semibold, design: .rounded))
        .foregroundStyle(BunlyColor.ink)
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .minimumScaleFactor(0.85)
    }
    .padding(14)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Bondly. \(entry.snapshot.line). \(entry.snapshot.hearts) hearts.")
  }

  private var medium: some View {
    HStack(spacing: 14) {
      Image("BondlySitting")
        .resizable()
        .scaledToFit()
        .frame(width: 92)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 8) {
        Text("Bondly")
          .font(.system(size: 12, weight: .semibold, design: .rounded))
          .foregroundStyle(BunlyColor.ink.opacity(0.55))
        Text(entry.snapshot.line)
          .font(.system(size: 16, weight: .semibold, design: .rounded))
          .foregroundStyle(BunlyColor.ink)
          .lineLimit(3)
          .minimumScaleFactor(0.8)
        Spacer(minLength: 0)
        HStack(spacing: 8) {
          hearts
          streak
          Spacer(minLength: 4)
          Link(destination: URL(string: "bunly://sos")!) {
            Text("SOS")
              .font(.system(size: 12, weight: .heavy, design: .rounded))
              .foregroundStyle(.white)
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background(BunlyColor.sos, in: Capsule())
          }
          .accessibilityLabel("SOS. Help with a panic attack.")
        }
      }
    }
    .padding(16)
    .accessibilityElement(children: .contain)
  }

  private var hearts: some View {
    HStack(spacing: 3) {
      Image(systemName: "heart.fill")
        .font(.system(size: 11, weight: .bold))
        .foregroundStyle(BunlyColor.sos)
      Text("\(entry.snapshot.hearts)")
        .font(.system(size: 13, weight: .bold, design: .rounded))
        .foregroundStyle(BunlyColor.ink)
    }
    .accessibilityLabel("\(entry.snapshot.hearts) of 5 hearts")
  }

  private var streak: some View {
    HStack(spacing: 3) {
      Image(systemName: "flame.fill")
        .font(.system(size: 11, weight: .bold))
        .foregroundStyle(BunlyColor.gold)
      Text("\(entry.snapshot.streak)")
        .font(.system(size: 13, weight: .bold, design: .rounded))
        .foregroundStyle(BunlyColor.ink)
    }
    .accessibilityLabel("Streak \(entry.snapshot.streak) days")
  }
}
