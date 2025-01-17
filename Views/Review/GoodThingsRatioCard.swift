import SwiftUI

struct GoodThingCategory: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let emoji: String
    let color: Color
    
    var ratio: Double {
        Double(count)
    }
}

struct GoodThingsRatioCard: View {
    @ObservedObject var viewModel: EmotionViewModel
    
    private var categories: [GoodThingCategory] {
        viewModel.getGoodThingsCategories()
    }
    
    private var totalCount: Int {
        categories.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Text("好事占比")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.pink)
                Text("*")
                    .foregroundStyle(.pink)
                
                Spacer()
                
                Text("上周一样")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 12)
            
            if !categories.isEmpty {
                Text("\(totalCount)件")
                    .font(.system(size: 28, weight: .medium))
                    .padding(.bottom, 16)
                
                // 内容区
                HStack(alignment: .center, spacing: 20) {
                    // 左侧列表
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(categories) { category in
                            HStack(spacing: 4) {
                                Text(category.emoji)
                                    .font(.system(size: 11))
                                Text(category.name)
                                    .font(.system(size: 11))
                                Text("\(category.count)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.leading, 4)
                    
                    Spacer()
                    
                    // 右侧饼图
                    ZStack {
                        PieChartView(data: categories)
                            .frame(width: 180, height: 180)
                    }
                    .padding(.trailing, -8)
                }
            } else {
                // 空状态显示
                VStack(spacing: 8) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text("记录美好时刻\n数据会在这里展示")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            }
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

struct PieChartView: View {
    let data: [GoodThingCategory]
    
    private var total: Double {
        data.reduce(0.0) { $0 + $1.ratio }
    }
    
    private func calculateAngle(for value: Double) -> Double {
        360 * (value / total)
    }
    
    private func getSegmentColor(_ index: Int) -> Color {
        let colors: [Color] = [
            Color(red: 1.0, green: 0.4, blue: 0.7),  // 深粉色
            Color(red: 1.0, green: 0.6, blue: 0.8),  // 中粉色
            Color(red: 1.0, green: 0.8, blue: 0.9),  // 浅粉色
            Color(red: 1.0, green: 0.9, blue: 0.95), // 更浅粉色
            Color(red: 1.0, green: 0.95, blue: 0.98) // 最浅粉色
        ]
        return colors[min(index, colors.count - 1)]
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: size/2, y: size/2)
            let radius = size/2
            
            ZStack {
                // 绘制圆环段
                ForEach(Array(data.enumerated()), id: \.element.id) { index, category in
                    let startAngle = data[..<index].reduce(into: 0.0) { sum, item in
                        sum += calculateAngle(for: item.ratio)
                    }
                    let endAngle = startAngle + calculateAngle(for: category.ratio)
                    
                    PieSegment(
                        startAngle: .degrees(startAngle - 90),
                        endAngle: .degrees(endAngle - 90),
                        color: getSegmentColor(index)
                    )
                }
                
                // 中心白色圆形
                Circle()
                    .fill(.white)
                    .frame(width: size * 0.55, height: size * 0.55)
                
                // 添加标签
                ForEach(Array(data.enumerated()), id: \.element.id) { index, category in
                    let percentage = (category.ratio / total) * 100
                    if percentage >= 15 {
                        let startAngle = data[..<index].reduce(into: 0.0) { sum, item in
                            sum += calculateAngle(for: item.ratio)
                        }
                        let segmentAngle = calculateAngle(for: category.ratio)
                        let angle = startAngle + (segmentAngle / 2) - 90
                        let distance = radius * 0.78
                        
                        let x = cos(angle * .pi / 180) * distance
                        let y = sin(angle * .pi / 180) * distance
                        
                        VStack(spacing: 1) {
                            Text(category.emoji)
                                .font(.system(size: 14))
                            Text("\(Int(percentage))%")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .position(
                            x: center.x + x,
                            y: center.y + y
                        )
                    }
                }
            }
            .frame(width: size, height: size)
        }
    }
}

struct PieSegment: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            
            Path { path in
                path.move(to: CGPoint(x: radius, y: radius))
                path.addArc(
                    center: CGPoint(x: radius, y: radius),
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

#Preview {
    VStack {
        GoodThingsRatioCard(viewModel: EmotionViewModel())
    }
    .padding()
    .background(Color(.systemGroupedBackground))
} 
