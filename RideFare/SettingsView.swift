import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: FareStore
    
    var body: some View {
        Form {
            Section(header: Text("通用设置")) {
                VStack {
                    HStack {
                        Text("折扣系数")
                        Spacer()
                        Text(String(format: "%.2f", store.discount))
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $store.discount, in: 0.01...1.0, step: 0.01)
                }
            }
            
            Section(header: Text("计费规则")) {
                ForEach($store.rules) { $rule in
                    NavigationLink(destination: RuleEditView(rule: $rule)) {
                        HStack {
                            Text(rule.name)
                            Spacer()
                            Text("\(String(format: "%.1f", rule.unitPrice))元/公里")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("设置")
    }
}

struct RuleEditView: View {
    @Binding var rule: FareRule
    
    var body: some View {
        Form {
            Section(header: Text("基础计费")) {
                HStack {
                    Text("起步价 (元)")
                    Spacer()
                    TextField("金额", value: $rule.baseFare, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("起步里程 (公里)")
                    Spacer()
                    TextField("里程", value: $rule.baseDistance, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("单价 (元/公里)")
                    Spacer()
                    TextField("金额", value: $rule.unitPrice, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section(header: Text("远途费设置")) {
                HStack {
                    Text("起算里程 (公里)")
                    Spacer()
                    TextField("里程", value: $rule.longDistanceThreshold, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("附加费 (元/公里)")
                    Spacer()
                    TextField("金额", value: $rule.longDistanceSurcharge, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("封顶金额 (元)")
                    Spacer()
                    TextField("金额", value: $rule.longDistanceCap, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .navigationTitle(rule.name)
    }
}