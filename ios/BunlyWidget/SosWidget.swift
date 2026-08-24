import SwiftUI
import WidgetKit

struct SosProvider: TimelineProvider {
  func placeholder(in context: Context) -> SosEntry {
    SosEntry(date: Date(), snapshot: .placeholder)
  }

  func getSnapshot(in context: Context, completion: @escaping (SosEntry) -> Void) {
    completion(SosEntry(date: Date(), snapshot: WidgetSnapshot.current()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<SosEntry>) -> Void) {
    completion(Timeline(entries: [SosEntry(date: Date(), snapshot: WidgetSnapshot.current())], policy: .never))
  }
}

struct SosEntry: TimelineEntry {
  let date: Date
  let snapshot: WidgetSnapshot
}

struct SosWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "BunlySOS", provider: SosProvider()) { entry in
      SosView(entry: entry)
    }
    .configurationDisplayName("SOS")
    .description("One tap into help if a wave is here. Home Screen and Lock Screen.")
    .supportedFamilies([
      .systemSmall,
      .accessoryCircular,
      .accessoryRectangular,
      .accessoryInline,
    ])
  }
}

struct SosView: View {
  @Environment(\.widgetFamily) private var family
  var entry: SosEntry

  private var snap: WidgetSnapshot { entry.snapshot }
  private var look: WidgetLook { .named(snap.look) }
  private var soft: Bool { snap.isSoftSos }

  var body: some View {
    Group {
      switch family {
      case .accessoryCircular:
        lockCircular
      case .accessoryRectangular:
        lockRectangular
      case .accessoryInline:
        Label(soft ? "I'm here" : "SOS · I'm here", systemImage: "heart.fill")
      default:
        home
      }
    }
    .widgetURL(URL(string: "bunly://sos"))
  }

  private var home: some View {
    VStack(spacing: 10) {
      Spacer(minLength: 0)
      ZStack {
        Circle()
          .fill(soft ? BunlyColor.brand.opacity(0.18) : BunlyColor.sosDeep)
          .frame(width: 76, height: 76)
          .offset(y: soft ? 0 : 4)
        Circle()
          .fill(soft ? BunlyColor.brand : BunlyColor.sos)
          .frame(width: 72, height: 72)
        VStack(spacing: 1) {
          Image(systemName: "heart.fill")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
          Text(soft ? "Here" : "SOS")
            .font(.system(size: 13, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
        }
      }
      Text(soft ? "If a wave is here" : "A wave is here")
        .font(.system(size: 13, weight: .semibold, design: .rounded))
        .foregroundStyle(look.ink)
      Text("Tap. I'm with you.")
        .font(.system(size: 11, weight: .medium, design: .rounded))
        .foregroundStyle(look.muted)
      Spacer(minLength: 0)
    }
    .padding(14)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .modifier(HomeWidgetBackground(look: look))
    .accessibilityLabel(soft ? "I'm here. Open Bunly help." : "SOS. Help with a panic attack.")
  }

  private var lockCircular: some View {
    ZStack {
      AccessoryWidgetBackground()
      VStack(spacing: 1) {
        Image(systemName: "heart.fill")
          .font(.system(size: 16, weight: .bold))
        Text(soft ? "Here" : "SOS")
          .font(.system(size: 10, weight: .heavy, design: .rounded))
      }
    }
    .accessibilityLabel(soft ? "I'm here. Open Bunly help." : "SOS. Open Bunly help.")
  }

  private var lockRectangular: some View {
    HStack(spacing: 10) {
      Image(systemName: "heart.fill")
      VStack(alignment: .leading, spacing: 1) {
        Text(soft ? "I'm here" : "Bunly SOS")
          .font(.headline)
        Text("Tap if a wave is here.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      Spacer(minLength: 0)
    }
    .accessibilityLabel("Bunly SOS. Tap for help.")
  }
}
