//
//  ContentView.swift
//  NiuMaShiZhong
//
//  Created by Randy on 3/1/2025.
//

import SwiftUI

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    static let languageKey = "AppleLanguages"
    
    static func setLanguage(_ languageCode: String) {
        UserDefaults.standard.set([languageCode], forKey: Self.languageKey)
        UserDefaults.standard.synchronize()
    }
}

extension UserDefaults {
    static let workConfigKey = "WorkConfig"
    
    func saveWorkConfig(_ config: WorkConfig) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(config) {
            UserDefaults.standard.set(encoded, forKey: Self.workConfigKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    func loadWorkConfig() -> WorkConfig? {
        if let savedConfig = UserDefaults.standard.data(forKey: Self.workConfigKey),
           let decoder = try? JSONDecoder().decode(WorkConfig.self, from: savedConfig) {
            return decoder
        }
        return nil
    }
}

struct ContentView: View {
    @State private var workConfig: WorkConfig = UserDefaults.standard.loadWorkConfig() ?? WorkConfig(
        monthlySalary: 30000,
        workStartTime: Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
        workEndTime: Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date(),
        workSchedule: .fiveDay,
        joinDate: Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 1)) ?? Date()
    )
    
    @State private var currentTime = Date()
    @State private var showingLanguageSettings = false
    @State private var showingRestartAlert = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark ?
                            UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0) :
                            UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1.0)
                    }),
                    Color(UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark ?
                            UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1.0) :
                            UIColor(red: 0.96, green: 0.94, blue: 0.92, alpha: 1.0)
                    })
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // 顶部标题栏
                    HStack {
                        Text("app_name".localized)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                        Button(action: {
                            showingLanguageSettings = true
                        }) {
                            Image(systemName: "globe")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 8)
                    
                    // 当前时间
                    Text(currentTime.formatted(.dateTime.hour().minute().second()))
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                        .contentTransition(.numericText())
                        .onReceive(timer) { input in
                            withAnimation(.spring(duration: 0.5)) {
                                currentTime = input
                            }
                        }
                    
                    // 其他卡片保持原有结构，调整视觉效果
                    Group {
                        InfoCard(workConfig: $workConfig)
                            .transition(.scale.combined(with: .opacity))
                        
                        TimeCard(workConfig: workConfig, currentTime: currentTime)
                            .transition(.slide)
                        
                        EarningsCard(title: "today_earnings".localized,
                                   amount: workConfig.calculateTodayEarnings())
                        
                        EarningsCard(title: "month_earnings".localized,
                                   amount: workConfig.calculateMonthEarnings())
                        
                        EarningsCard(title: "year_earnings".localized,
                                   amount: workConfig.calculateYearEarnings())
                    }
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 8, x: 0, y: 4)
                    
                    Spacer(minLength: 32)
                }
                .padding(.horizontal)
                .animation(.spring(duration: 0.6), value: workConfig)
            }
        }
        .sheet(isPresented: $showingLanguageSettings) {
            ConfigView(showingRestartAlert: $showingRestartAlert)
                .transition(.move(edge: .bottom))
        }
        .alert("restart_required".localized, isPresented: $showingRestartAlert) {
            Button("done".localized, role: .cancel) {}
        }
        .onChange(of: workConfig) { newConfig in
            UserDefaults.standard.saveWorkConfig(newConfig)
        }
    }
}

struct InfoCard: View {
    @Binding var workConfig: WorkConfig
    @State private var showingWorkTimePicker = false
    @State private var showingSalaryPicker = false
    @State private var showingJoinDatePicker = false
    
    var body: some View {
        VStack(spacing: 12) {
            // 工作时间
            Button(action: { showingWorkTimePicker = true }) {
                HStack {
                    Text("work_time".localized)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(workConfig.workStartTime.formatted(.dateTime.hour().minute())) - \(workConfig.workEndTime.formatted(.dateTime.hour().minute()))")
                        .foregroundColor(.primary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
            }
            .buttonStyle(ScaleButtonStyle())
            
            // 入职时间
            Button(action: { showingJoinDatePicker = true }) {
                HStack {
                    Text("join_date".localized)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(workConfig.joinDate.formatted(.iso8601.year().month().day()))
                        .foregroundColor(.primary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
            }
            .buttonStyle(ScaleButtonStyle())
            
            // 月薪
            Button(action: { showingSalaryPicker = true }) {
                HStack {
                    Text("monthly_salary".localized)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("¥\(Int(workConfig.monthlySalary))")
                        .foregroundColor(.primary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
            }
            .buttonStyle(ScaleButtonStyle())
            
            // 工作制度
            Menu {
                ForEach([
                    ("five_day_schedule".localized, WorkSchedule.fiveDay),
                    ("six_day_schedule".localized, WorkSchedule.sixDay),
                    ("alt_week_schedule".localized, WorkSchedule.alternating)
                ], id: \.0) { item in
                    Button(item.0) {
                        withAnimation(.spring(duration: 0.3)) {
                            workConfig.workSchedule = item.1
                        }
                    }
                }
            } label: {
                HStack {
                    Text("work_schedule_title".localized)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(workConfig.workSchedule.description)
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15)
            .fill(Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ?
                    UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0) :
                    .systemBackground
            }))
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 10))
        .sheet(isPresented: $showingWorkTimePicker) {
            WorkTimePickerView(workConfig: $workConfig)
                .presentationDetents([.height(700)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingSalaryPicker) {
            NavigationView {
                SalaryPickerView(salary: $workConfig.monthlySalary)
                    .navigationTitle("set_salary".localized)
                    .navigationBarItems(trailing: Button("done".localized) {
                        showingSalaryPicker = false
                    })
            }
            .presentationDetents([.height(600)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingJoinDatePicker) {
            NavigationView {
                JoinDatePickerView(joinDate: $workConfig.joinDate)
                    .navigationTitle("set_join_date".localized)
                    .navigationBarItems(trailing: Button("done".localized) {
                        showingJoinDatePicker = false
                    })
            }
            .presentationDetents([.height(500)])
            .presentationDragIndicator(.visible)
        }
    }
}

struct WorkTimePickerView: View {
    @Binding var workConfig: WorkConfig
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // 顶部导航栏
            HStack {
                Text("set_work_time".localized)
                    .font(.system(size: 34, weight: .bold))
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Text("done".localized)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 60) {
                // 上班时间选择器
                VStack(alignment: .leading, spacing: 10) {
                    Text("start_time".localized)
                        .foregroundColor(.gray)
                        .padding(.leading)
                    DatePicker("",
                              selection: $workConfig.workStartTime,
                              displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                }
                
                // 下班时间选择器
                VStack(alignment: .leading, spacing: 10) {
                    Text("end_time".localized)
                        .foregroundColor(.gray)
                        .padding(.leading)
                    DatePicker("",
                              selection: $workConfig.workEndTime,
                              displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
        }
        .background(Color(uiColor: .systemBackground))
    }
}

struct SalaryPickerView: View {
    @Binding var salary: Double
    @Environment(\.dismiss) var dismiss
    @State private var inputText: String
    @FocusState private var isEditing: Bool
    @State private var showingError = false
    
    init(salary: Binding<Double>) {
        self._salary = salary
        self._inputText = State(initialValue: String(format: "%.0f", salary.wrappedValue))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 金额显示
            Text("¥\(inputText)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "CD853F"))
                .padding(.top, 20)
                .contentTransition(.numericText())
            
            // 输入框
            TextField("", text: $inputText)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 24))
                .foregroundColor(.clear)
                .frame(height: 0)
                .focused($isEditing)
                .onChange(of: inputText) { newValue in
                    // 只允许输入数字
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != newValue {
                        inputText = filtered
                    }
                    // 限制最大长度为7位
                    if filtered.count > 7 {
                        inputText = String(filtered.prefix(7))
                    }
                }
            
            // 数字键盘
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                ForEach(1...9, id: \.self) { number in
                    Button(action: {
                        appendNumber(String(number))
                    }) {
                        Text(String(number))
                            .font(.system(size: 28, weight: .medium))
                            .frame(width: 80, height: 60)
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                    }
                }
                
                Button(action: {
                    if !inputText.isEmpty {
                        inputText.removeLast()
                    }
                }) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 24))
                        .frame(width: 80, height: 60)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                }
                
                Button(action: {
                    appendNumber("0")
                }) {
                    Text("0")
                        .font(.system(size: 28, weight: .medium))
                        .frame(width: 80, height: 60)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                }
                
                Button(action: {
                    // 生成0-100000的随机数
                    let randomSalary = Int.random(in: 0...100000)
                    inputText = String(randomSalary)
                    saveSalary()
                }) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                        .frame(width: 80, height: 60)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .alert("invalid_salary".localized, isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("salary_range_error".localized)
        }
        .navigationTitle("set_salary".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("done".localized) {
                    saveSalary()
                }
            }
        }
    }
    
    private func appendNumber(_ number: String) {
        if inputText == "0" {
            inputText = number
        } else {
            inputText += number
        }
    }
    
    private func saveSalary() {
        guard let newSalary = Double(inputText), newSalary > 0, newSalary <= 9999999 else {
            showingError = true
            return
        }
        
        withAnimation(.spring(duration: 0.3)) {
            salary = newSalary
        }
        dismiss()
    }
}

struct JoinDatePickerView: View {
    @Binding var joinDate: Date
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            DatePicker("选择入职时间",
                      selection: $joinDate,
                      displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .padding()
                .labelsHidden()
                .frame(maxHeight: 400)
            
            Text("\("selected_date".localized): \(joinDate.formatted(.iso8601.year().month().day()))")
                .foregroundColor(.gray)
                .padding(.bottom)
        }
    }
}

struct TimeCard: View {
    let workConfig: WorkConfig
    let currentTime: Date
    
    var body: some View {
        VStack(spacing: 8) {
            Text("time_until_off".localized)
                .font(.headline)
                .foregroundColor(.gray)
            
            if let timeLeft = workConfig.calculateTimeUntilOff() {
                HStack(spacing: 12) {
                    TimeBlock(value: timeLeft.hours, unit: "hour".localized)
                    TimeBlock(value: timeLeft.minutes, unit: "minute".localized)
                    TimeBlock(value: timeLeft.seconds, unit: "second".localized)
                }
                .frame(maxWidth: .infinity)
            } else {
                Text("already_off".localized)
                    .font(.title2)
                    .foregroundColor(.gray)
                    .frame(height: 70)
            }
            
            Text("\("next_work_time".localized)：\(workConfig.workStartTime.formatted(.dateTime.hour().minute()))")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}

struct TimeBlock: View {
    let value: Int
    let unit: String
    
    @State private var animatedScale: CGFloat = 0.8
    @State private var animatedOpacity: CGFloat = 0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "FFD700").opacity(0.15))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(width: 80, height: 70)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 5, x: 0, y: 2)
                .scaleEffect(animatedScale)
                .opacity(animatedOpacity)
            
            VStack(spacing: 4) {
                Text("\(value)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                    .minimumScaleFactor(0.5)
                Text(unit)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(width: 70)
        }
        .onAppear {
            withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                animatedScale = 1
                animatedOpacity = 1
            }
        }
    }
}

struct EarningsCard: View {
    let title: String
    let amount: Double
    
    @State private var animatedAmount: Double = 0
    @State private var lastAmount: Double = 0
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            Text("¥\(String(format: "%.2f", animatedAmount))")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "CD853F"))
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .onAppear {
            lastAmount = amount
            withAnimation(.spring(duration: 1.0)) {
                animatedAmount = amount
            }
        }
        .onChange(of: amount) { newValue in
            // 避免重复动画
            guard abs(newValue - lastAmount) > 0.01 else { return }
            lastAmount = newValue
            
            // 使用 RunLoop 的下一个周期更新，避免同一帧多次更新
            RunLoop.main.perform {
                withAnimation(.spring(duration: 0.5)) {
                    animatedAmount = newValue
                }
            }
        }
    }
}

struct ConfigView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showingRestartAlert: Bool
    
    let languages = [
        ("简体中文", "zh-Hans"),
        ("繁體中文", "zh-Hant"),
        ("English", "en")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(languages, id: \.0) { language in
                    Button(action: {
                        String.setLanguage(language.1)
                        showingRestartAlert = true
                        dismiss()
                    }) {
                        HStack {
                            Text(language.0)
                            Spacer()
                            if (UserDefaults.standard.array(forKey: String.languageKey) as? [String])?.first == language.1 {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("language_settings".localized)
            .navigationBarItems(trailing: Button("done".localized) {
                dismiss()
            })
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
