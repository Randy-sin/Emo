import SwiftUI

struct IPadContentView: View {
    @State var workConfig: WorkConfig
    
    @State private var currentTime = Date()
    @State private var showingLanguageSettings = false
    @State private var showingRestartAlert = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // 左侧信息面板
                VStack(spacing: 20) {
                    // 顶部标题和设置
                    HStack {
                        Text("app_name".localized)
                            .font(.system(size: 34, weight: .bold))
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
                    .padding(.top, 20)
                    
                    // 工作信息卡片
                    InfoCard(workConfig: $workConfig)
                        .frame(maxWidth: .infinity)
                        .transition(AnyTransition.opacity.combined(with: .scale))
                }
                .frame(width: geometry.size.width * 0.28)
                .padding(.horizontal)
                
                // 中间分隔线
                Rectangle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 1)
                    .padding(.vertical, 20)
                
                // 右侧主要内容区域
                VStack(spacing: 30) {
                    // 大型数字时钟
                    Text(currentTime.formatted(.dateTime.hour().minute().second()))
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top, 40)
                        .frame(maxWidth: .infinity)
                        .contentTransition(.numericText())
                    
                    // 倒计时卡片
                    TimeCard(workConfig: workConfig, currentTime: currentTime)
                        .frame(height: geometry.size.height * 0.25)
                        .padding(.horizontal)
                        .transition(.slide)
                    
                    // 收益信息网格
                    VStack(spacing: 25) {
                        // 计算所有收益值
                        let todayEarnings = workConfig.calculateTodayEarnings()
                        let monthEarnings = workConfig.calculateMonthEarnings()
                        let yearEarnings = workConfig.calculateYearEarnings()
                        let totalEarnings = workConfig.calculateTotalEarnings()
                        
                        // 上排两个卡片
                        HStack(spacing: 20) {
                            EarningsCard(title: "today_earnings".localized,
                                       amount: todayEarnings,
                                       currency: workConfig.currency)
                                .frame(maxWidth: .infinity)
                            
                            EarningsCard(title: "month_earnings".localized,
                                       amount: monthEarnings,
                                       currency: workConfig.currency)
                                .frame(maxWidth: .infinity)
                        }
                        
                        // 下排两个卡片
                        HStack(spacing: 20) {
                            EarningsCard(title: "year_earnings".localized,
                                       amount: yearEarnings,
                                       currency: workConfig.currency)
                                .frame(maxWidth: .infinity)
                            
                            EarningsCard(title: "total_earnings".localized,
                                       amount: totalEarnings,
                                       currency: workConfig.currency)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.trailing)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.spring(duration: 0.6), value: workConfig)
        }
        .background(
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
        )
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
        .onReceive(timer) { input in
            withAnimation(.spring(duration: 0.5)) {
                currentTime = input
            }
        }
    }
} 