import SwiftUI

struct AIAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: EmotionViewModel
    @State private var text = ""
    @State private var result = ""
    @State private var isLoading = false
    @State private var currentStepIndex = 0
    @FocusState private var isFocused: Bool
    
    private let placeholderText = "今天发生了什么让你感到开心或烦恼的事情呢？\n和AI小助手分享你的心情..."
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Feature Introduction Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image("Bot")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                        Text("AI 情绪助手")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    Text("让AI助手帮你分析情绪,提供专业的心理建议")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.purple.opacity(0.1))
                )
                .padding(.horizontal)
                
                // Enhanced Text Input Area
                VStack(alignment: .leading, spacing: 12) {
                    Text("描述你的心情")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $text)
                            .frame(height: 120)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.purple.opacity(isFocused ? 0.3 : 0.1), lineWidth: 1)
                            )
                            .focused($isFocused)
                        
                        if text.isEmpty {
                            Text(placeholderText)
                                .foregroundColor(.secondary.opacity(0.8))
                                .font(.body)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Text("\(text.count)/200")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Analysis Result or Loading View
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("AI正在分析...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !result.isEmpty {
                    ScrollView {
                        Text(processMarkdownText(result))
                            .padding()
                    }
                }
                
                // Action Button
                Button(action: {
                    if result.isEmpty {
                        dismissKeyboard()
                        isLoading = true
                        Task {
                            do {
                                result = try await CozeService.shared.analyzeEmotion(text)
                                isLoading = false
                            } catch {
                                print("Analysis failed: \(error)")
                                isLoading = false
                            }
                        }
                    } else {
                        dismiss()
                    }
                }) {
                    Text(result.isEmpty ? "开始分析" : "关闭")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.purple)
                                .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                .padding(.horizontal)
                .disabled(text.isEmpty || isLoading)
                .opacity(text.isEmpty || isLoading ? 0.6 : 1)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("AI 心情分析")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.headline)
                    }
                }
            }
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
    }
    
    private func processMarkdownText(_ text: String) -> String {
        return text
    }
}

// 功能特点行组件
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.purple)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    } 
    } 
