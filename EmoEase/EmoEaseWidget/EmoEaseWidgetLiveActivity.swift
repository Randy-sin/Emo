//
//  EmoEaseWidgetLiveActivity.swift
//  EmoEaseWidget
//
//  Created by Randy on 16/1/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct EmoEaseWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct EmoEaseWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EmoEaseWidgetAttributes.self) { context in
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

extension EmoEaseWidgetAttributes {
    fileprivate static var preview: EmoEaseWidgetAttributes {
        EmoEaseWidgetAttributes(name: "World")
    }
}

extension EmoEaseWidgetAttributes.ContentState {
    fileprivate static var smiley: EmoEaseWidgetAttributes.ContentState {
        EmoEaseWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: EmoEaseWidgetAttributes.ContentState {
         EmoEaseWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: EmoEaseWidgetAttributes.preview) {
   EmoEaseWidgetLiveActivity()
} contentStates: {
    EmoEaseWidgetAttributes.ContentState.smiley
    EmoEaseWidgetAttributes.ContentState.starEyes
}
