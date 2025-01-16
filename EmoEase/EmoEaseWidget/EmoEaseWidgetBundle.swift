//
//  EmoEaseWidgetBundle.swift
//  EmoEaseWidget
//
//  Created by Randy on 16/1/2025.
//

import WidgetKit
import SwiftUI

@main
struct EmoEaseWidgetBundle: WidgetBundle {
    var body: some Widget {
        EmoEaseWidget()  // 早安日记 Widget
        EveningWidget()  // 晚安日记 Widget
    }
}
