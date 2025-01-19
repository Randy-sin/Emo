import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("搜索日记", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
        )
        .padding(.horizontal)
    }
} 