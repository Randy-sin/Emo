import SwiftUI

struct GuideView: View {
    @Binding var workConfig: WorkConfig
    @Binding var hasCompletedGuide: Bool
    
    @State private var showingWorkTimePicker = false
    @State private var showingJoinDatePicker = false
    @State private var showingSalaryPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题
            VStack(alignment: .leading, spacing: 8) {
                Text("天价牛马们！")
                    .font(.system(size: 34, weight: .bold))
                Text("你们准备好了吗？")
                    .font(.system(size: 34, weight: .bold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 40)
            
            // 牛马图标 - 居中放大作为主视觉
            Image("OxIcon")
                .resizable()
                .scaledToFit()
                .frame(width: min(UIScreen.main.bounds.width * 1.2, UIScreen.main.bounds.height * 0.45))
                .padding(.vertical, 20)
            
            // 配置选项 - 使用更现代的卡片设计
            VStack(spacing: 16) {
                // 币种选择
                HStack {
                    Text("币种")
                        .foregroundColor(.primary)
                        .font(.system(size: 17))
                    Spacer()
                    Menu {
                        Button("人民币 (¥)") {
                            withAnimation {
                                workConfig.currency = .cny
                            }
                        }
                        Button("美元 ($)") {
                            withAnimation {
                                workConfig.currency = .usd
                            }
                        }
                    } label: {
                        Text(workConfig.currency.rawValue)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.orange.opacity(0.15))
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemGray6))
                )
                
                configRow(title: "工作时间", value: "\(workConfig.workStartTime.formatted(.dateTime.hour().minute())) - \(workConfig.workEndTime.formatted(.dateTime.hour().minute()))", action: { showingWorkTimePicker = true })
                
                configRow(title: "入职时间", value: workConfig.joinDate.formatted(.iso8601.year().month().day()), action: { showingJoinDatePicker = true })
                
                configRow(title: "月薪", value: "\(workConfig.currency.rawValue)\(Int(workConfig.monthlySalary))", action: { showingSalaryPicker = true })
                
                // 工作制度选择
                HStack {
                    Text("工作制度")
                        .foregroundColor(.primary)
                        .font(.system(size: 17))
                    Spacer()
                    Menu {
                        ForEach([
                            ("五天工作制", WorkSchedule.fiveDay),
                            ("六天工作制", WorkSchedule.sixDay),
                            ("大小周工作制", WorkSchedule.alternating)
                        ], id: \.0) { item in
                            Button(item.0) {
                                withAnimation {
                                    workConfig.workSchedule = item.1
                                }
                            }
                        }
                    } label: {
                        Text(workConfig.workSchedule.description)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.orange.opacity(0.15))
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemGray6))
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // 开始按钮 - 使用渐变色和阴影提升视觉效果
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    UserDefaults.standard.saveWorkConfig(workConfig)
                    hasCompletedGuide = true
                    UserDefaults.standard.set(true, forKey: "HasCompletedGuide")
                }
            }) {
                Text("开始计算收益")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [Color.orange, Color.orange.opacity(0.8)],
                                     startPoint: .leading,
                                     endPoint: .trailing)
                    )
                    .cornerRadius(15)
                    .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showingWorkTimePicker) {
            WorkTimePickerView(workConfig: $workConfig)
                .presentationDetents([.height(700)])
        }
        .sheet(isPresented: $showingSalaryPicker) {
            NavigationView {
                SalaryPickerView(salary: $workConfig.monthlySalary)
            }
            .presentationDetents([.height(600)])
        }
        .sheet(isPresented: $showingJoinDatePicker) {
            NavigationView {
                JoinDatePickerView(joinDate: $workConfig.joinDate)
                    .navigationTitle("设置入职时间")
                    .navigationBarItems(trailing: Button("完成") {
                        showingJoinDatePicker = false
                    })
            }
            .presentationDetents([.height(500)])
        }
    }
    
    // 配置行组件
    private func configRow(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                    .font(.system(size: 17))
                Spacer()
                Text(value)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.orange.opacity(0.15))
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6))
            )
        }
    }
} 