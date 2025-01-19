import Foundation
import Network

/**
 CozeService 类负责与 Coze API 进行交互，主要用于分析情感文本。

 该类包含以下主要功能：
 - 初始化时设置网络状态监测。
 - 提供分析情感的异步方法，该方法接受文本输入并返回分析结果。
 - 处理网络连接问题和 API 请求错误。
 */
class CozeService {
    // 单例模式，确保整个应用程序中只有一个 CozeService 实例
    static let shared = CozeService()
    
    // API 密钥，用于授权访问 Coze API
    private let apiKey = "pat_cAoshllGL3O6j3nyRAEtrZvwMaNt2Xs9jNkWL2vn9hDdKR1LbKPETRcTajTe2mSC"
    
    // 工作流 ID，指定要使用的 Coze 工作流
    private let workflowId = "7456379638806937612"
    
    // Coze API 的基本 URL，用于发送分析请求
    private let baseURL = "https://api.coze.cn/v1/workflow/run"
    
    // 网络路径监视器，用于实时监测网络状态
    private let monitor = NWPathMonitor()
    
    // 布尔值，指示当前网络是否可用
    private var isNetworkAvailable = false
    
    // 私有初始化方法，确保单例模式
    private init() {
        // 初始化时设置网络监测
        setupNetworkMonitoring()
    }
    
    /**
     CozeResponse 结构体用于解析 Coze API 的响应数据。

     该结构体包含以下属性：
     - code: 响应状态码。
     - cost: 请求成本。
     - data: 包含分析结果的 JSON 字符串。
     - debug_url: 调试 URL。
     - msg: 响应消息。
     - token: 令牌。
     - decodedData: 解析后的分析结果。
     */
    struct CozeResponse: Codable {
        let code: Int
        let cost: String
        let data: String
        let debug_url: String
        let msg: String
        let token: Int
        
        /**
         DataContent 结构体用于解析 data 属性中的 JSON 数据。

         该结构体包含以下属性：
         - output: 分析结果的输出文本。
         */
        struct DataContent: Codable {
            let output: String
        }
        
        // 计算属性，用于解析 data 属性中的 JSON 数据
        var decodedData: DataContent? {
            guard let jsonData = data.data(using: .utf8) else { return nil }
            return try? JSONDecoder().decode(DataContent.self, from: jsonData)
        }
    }
    
    /**
     CozeData 结构体用于编码请求参数中的数据部分。

     该结构体包含以下属性：
     - result: 要分析的文本。
     */
    struct CozeData: Codable {
        let result: String
        
        // 编码键，用于指定 JSON 键名
        enum CodingKeys: String, CodingKey {
            case result = "result"
        }
    }
    
    /**
     CozeError 结构体用于表示 Coze API 请求过程中可能发生的错误。

     该结构体包含以下属性：
     - message: 错误消息。
     - code: 错误状态码。
     */
    struct CozeError: Error {
        let message: String
        let code: Int
        
        // 静态属性，表示网络不可用错误
        static let networkUnavailable = CozeError(message: "网络连接不可用，请检查网络设置后重试", code: -1009)
        
        // 静态属性，表示无效的 URL 错误
        static let invalidURL = CozeError(message: "API 地址无效", code: -1)
        
        // 静态属性，表示无效的响应错误
        static let invalidResponse = CozeError(message: "服务器响应无效", code: -2)
    }
    
    /**
     设置网络监测，实时监测网络状态并更新 isNetworkAvailable 属性。

     该方法在初始化时调用，用于初始化网络路径监视器，并设置路径更新处理程序。
     */
    private func setupNetworkMonitoring() {
        print("Setting up network monitoring...")
        
        // 设置路径更新处理程序
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
                print("Network status changed: \(path.status == .satisfied ? "Connected" : "Disconnected")")
                print("Network path details:")
                print("- Status: \(path.status)")
                print("- Available interfaces: \(path.availableInterfaces.map { $0.name })")
                print("- Is expensive: \(path.isExpensive)")
                print("- Is constrained: \(path.isConstrained)")
                
                if path.status != .satisfied {
                    print("Network issues:")
                    if path.isConstrained {
                        print("- Network is constrained")
                    }
                    if path.isExpensive {
                        print("- Network is expensive")
                    }
                    print("- Available interfaces: \(path.availableInterfaces)")
                }
            }
        }
        
        // 使用专门的串行队列
        let queue = DispatchQueue(label: "NetworkMonitor", qos: .utility)
        monitor.start(queue: queue)
        
        // 立即检查当前网络状态
        let currentPath = monitor.currentPath
        isNetworkAvailable = currentPath.status == .satisfied
        print("Initial network check:")
        print("- Status: \(currentPath.status)")
        print("- Is satisfied: \(currentPath.status == .satisfied)")
        print("- Available interfaces: \(currentPath.availableInterfaces.map { $0.name })")
    }
    
    /**
     异步方法，用于分析情感文本并返回分析结果。

     - Parameter text: 要分析的文本。
     - Returns: 分析结果的输出文本。
     - Throws: 如果网络不可用、API 请求失败或解析响应数据失败，则抛出相应的错误。
     */
    func analyzeEmotion(_ text: String) async throws -> String {
        print("\n=== Starting emotion analysis ===")
        let currentNetworkStatus = monitor.currentPath.status == .satisfied
        print("Current network status: \(currentNetworkStatus ? "Connected" : "Disconnected")")
        print("Network monitor status: \(monitor.currentPath.status == .satisfied ? "Satisfied" : "Unsatisfied")")
        print("Available interfaces: \(monitor.currentPath.availableInterfaces.map { $0.name })")
        
        // 检查网络状态 - 使用实时状态
        guard monitor.currentPath.status == .satisfied else {
            print("Network check failed - current path status is not satisfied")
            throw CozeError.networkUnavailable
        }
        
        guard let url = URL(string: baseURL) else {
            throw CozeError.invalidURL
        }
        
        // 准备请求参数
        let parameters: [String: Any] = [
            "workflow_id": workflowId,
            "parameters": [
                "BOT_USER_INPUT": String(text)  // 确保是字符串类型
            ]
        ]
        
        print("Request parameters: \(parameters)")  // 添加请求参数日志
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30 // 设置30秒超时
        
        // 编码请求体
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted])
            request.httpBody = jsonData
            
            // 打印 JSON 字符串，用于调试
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Request JSON: \(jsonString)")
            }
        } catch {
            throw CozeError(message: "请求参数编码失败：\(error.localizedDescription)", code: -4)
        }
        
        do {
            // 发送请求
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // 打印响应数据，用于调试
            if let responseString = String(data: data, encoding: .utf8) {
                print("API Response: \(responseString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw CozeError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let cozeResponse = try JSONDecoder().decode(CozeResponse.self, from: data)
                    
                    if cozeResponse.code != 0 {
                        throw CozeError(message: cozeResponse.msg, code: cozeResponse.code)
                    }
                    
                    guard let dataContent = cozeResponse.decodedData else {
                        throw CozeError(message: "无法解析分析结果", code: -3)
                    }
                    
                    return dataContent.output
                } catch {
                    print("Decoding Error: \(error)")
                    throw CozeError(message: "解析响应数据失败：\(error.localizedDescription)", code: -5)
                }
                
            case 401:
                throw CozeError(message: "API 认证失败，请检查 API Key", code: 401)
            case 429:
                throw CozeError(message: "请求过于频繁，请稍后重试", code: 429)
            case 500...599:
                throw CozeError(message: "服务器出现错误，请稍后重试", code: httpResponse.statusCode)
            default:
                throw CozeError(message: "请求失败 (HTTP \(httpResponse.statusCode))", code: httpResponse.statusCode)
            }
        } catch let error as CozeError {
            throw error
        } catch {
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    throw CozeError.networkUnavailable
                case .timedOut:
                    throw CozeError(message: "请求超时，请稍后重试", code: -1001)
                default:
                    throw CozeError(message: "网络请求失败：\(urlError.localizedDescription)", code: urlError.code.rawValue)
                }
            }
            throw CozeError(message: "未知错误：\(error.localizedDescription)", code: -999)
        }
    }
    
    deinit {
        monitor.cancel()
    }
} 