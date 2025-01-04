//
//  WidgetForNiuMaLiveActivity.swift
//  WidgetForNiuMa
//
//  Created by Randy on 4/1/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WidgetForNiuMaAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct WidgetForNiuMaLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WidgetForNiuMaAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension WidgetForNiuMaAttributes {
    fileprivate static var preview: WidgetForNiuMaAttributes {
        WidgetForNiuMaAttributes(name: "World")
    }
}

extension WidgetForNiuMaAttributes.ContentState {
    fileprivate static var smiley: WidgetForNiuMaAttributes.ContentState {
        WidgetForNiuMaAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: WidgetForNiuMaAttributes.ContentState {
         WidgetForNiuMaAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: WidgetForNiuMaAttributes.preview) {
   WidgetForNiuMaLiveActivity()
} contentStates: {
    WidgetForNiuMaAttributes.ContentState.smiley
    WidgetForNiuMaAttributes.ContentState.starEyes
}
