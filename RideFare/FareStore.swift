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
                UserDefaults.standard.set(encoded, forKey: "FareRules_v2")
            }
        }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: "FareRules_v2"),
           let decoded = try? JSONDecoder().decode([FareRule].self, from: data) {
            self.rules = decoded
        } else {
            // 默认初始设置
            self.rules = [
                FareRule(id: "day", name: "07:00-19:59", baseFare: 22, baseDistance: 5, unitPrice: 4.5, longDistanceThreshold: 30, longDistanceSurcharge: 1, longDistanceCap: 200),
                FareRule(id: "evening", name: "20:00-23:59", baseFare: 25, baseDistance: 5, unitPrice: 4.5, longDistanceThreshold: 30, longDistanceSurcharge: 1, longDistanceCap: 200),
                FareRule(id: "night", name: "00:00-06:59", baseFare: 39, baseDistance: 5, unitPrice: 4.5, longDistanceThreshold: 30, longDistanceSurcharge: 1, longDistanceCap: 200)
            ]
        }
    }
}
