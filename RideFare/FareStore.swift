import Foundation

struct FareRule: Identifiable, Codable {
    var id: String
    var name: String
    var baseFare: Double            // 起步价
    var baseDistance: Double        // 起步里程
    var unitPrice: Double           // 后续每公里价格
    var longDistanceThreshold: Double // 远途费起算公里数
    var longDistanceSurcharge: Double // 远途费每公里加价
    var longDistanceCap: Double       // 远途费封顶金额
}

class FareStore: ObservableObject {
    @Published var rules: [FareRule] {
        didSet {
            if let encoded = try? JSONEncoder().encode(rules) {
                UserDefaults.standard.set(encoded, forKey: "FareRules")
            }
        }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: "FareRules"),
           let decoded = try? JSONDecoder().decode([FareRule].self, from: data) {
            self.rules = decoded
        } else {
            // 默认初始设置
            self.rules = [
                FareRule(id: "before19", name: "19点前", baseFare: 20, baseDistance: 5, unitPrice: 3, longDistanceThreshold: 30, longDistanceSurcharge: 0, longDistanceCap: 160),
                FareRule(id: "before24", name: "24点前", baseFare: 25, baseDistance: 5, unitPrice: 3.5, longDistanceThreshold: 30, longDistanceSurcharge: 0, longDistanceCap: 160),
                FareRule(id: "after24", name: "24点后", baseFare: 30, baseDistance: 5, unitPrice: 4, longDistanceThreshold: 30, longDistanceSurcharge: 0.8, longDistanceCap: 160)
            ]
        }
    }
}