import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: FareStore

    var body: some View {
        Form {
            ForEach($store.rules) { $rule in
                Section(header: Text(rule.name)) {
                    HStack {
                        Text("起步价 (元)")
                        Spacer()
                        TextField("0", value: $rule.baseFare, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("起步里程 (公里)")
                        Spacer()
                        TextField("0", value: $rule.baseDistance, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("超起步单价 (元/公里)")
                        Spacer()
                        TextField("0", value: $rule.unitPrice, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("远途起算 (公里)")
                        Spacer()
                        TextField("0", value: $rule.longDistanceThreshold, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("远途附加 (元/公里)")
                        Spacer()
                        TextField("0", value: $rule.longDistanceSurcharge, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("远途费封顶 (元)")
                        Spacer()
                        TextField("0", value: $rule.longDistanceCap, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
        .navigationTitle("价格设置")
    }
}