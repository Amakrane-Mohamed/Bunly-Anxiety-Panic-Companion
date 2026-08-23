import SwiftUI
import WidgetKit

struct SosProvider: TimelineProvider {
  func placeholder(in context: Context) -> SosEntry {
    SosEntry(date: Date())
  }

  func getSnapshot(in context: Context, completion: @escaping (SosEntry) -> Void) {
    completion(SosEntry(date: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<SosEntry>) -> Void) {
    completion(Timeline(entries: [SosEntry(date: Date())], policy: .never))
  }
}

struct SosEntry: TimelineEntry {
  let date: Date
}

struct SosWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "BunlySOS", provider: SosProvider()) { entry in
      SosView(entry: entry)
    }
    .configurationDisplayName("SOS")
    .description("One tap into help if a wave is here.")
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

  var body: some View {
    Group {
      switch family {
      case .accessoryCircular:
        circular
      case .accessoryRectangular:
        rectangular
      case .accessoryInline:
        Label("SOS · I’m here", systemImage: "heart.fill")
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
          .fill(BunlyColor.sosLip)
          .frame(width: 72, height: 72)
          .offset(y: 4)
        Circle()
          .fill(BunlyColor.sos)
          .frame(width: 72, height: 72)
        Text("SOS")
          .font(.system(size: 16, weight: .heavy, design: .rounded))
          .foregroundStyle(.white)
      }
      Text("A wave is here")
        .font(.system(size: 13, weight: .semibold, design: .rounded))
        .foregroundStyle(BunlyColor.ink)
      Text("Tap. I’m with you.")
        .font(.system(size: 11, weight: .medium, design: .rounded))
        .foregroundStyle(BunlyColor.ink.opacity(0.55))
      Spacer(minLength: 0)
    }
    .padding(14)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .modifier(HomeWidgetBackground())
    .accessibilityLabel("SOS. Help with a panic attack.")
  }

  private var circular: some View {
    ZStack {
      AccessoryWidgetBackground()
      VStack(spacing: 1) {
        Image(systemName: "heart.fill")
          .font(.system(size: 16, weight: .bold))
        Text("SOS")
          .font(.system(size: 10, weight: .heavy, design: .rounded))
      }
    }
    .accessibilityLabel("SOS. Open Bunly help.")
  }

  private var rectangular: some View {
    HStack(spacing: 10) {
      Image(systemName: "heart.fill")
      VStack(alignment: .leading, spacing: 1) {
        Text("Bunly")
          .font(.headline)
        Text("I’m here. Tap for SOS.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      Spacer(minLength: 0)
    }
    .accessibilityLabel("Bunly SOS. I’m here. Tap for help.")
  }
}
